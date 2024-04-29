module Ledger
  class Entries
    JOURNAL_ENTRY = Struct.new(:date, :narration, :left_narration, :left_amount,
                               :right_narration, :right_amount, :source, keyword_init: true)

    def initialize(account:, viewer:)
      @account = account
      @viewer = viewer
    end

    def call
      @entries = fetch_journal_entries.to_a
      consolidate_and_prepare_entries
    end

    private

    attr_reader :account, :viewer, :entries, :consolidated_entries

    def my_account?
      account.id == viewer.id
    end

    def fetch_journal_entries
      account.journal_transactions.includes(source: [:payer, :payee, { expense: :payer }])
             .order(paid_at: :desc, created_at: :desc)
    end

    def consolidate_and_prepare_entries
      entries.group_by { |r| r.source.is_a?(PaymentComponent) ? r.source.expense : r.source }
             .map { |k, v| prepare_journal_entry(k, v) }
    end

    def prepare_journal_entry(grp, members)
      case grp
      when Expense
        prepare_expense_entry(grp, members)
      when Settlement
        prepare_settlement_entry(grp)
      end
    end

    def prepare_settlement_entry(grp)
      JOURNAL_ENTRY.new(
        date: grp.paid_at,
        narration: settlement_narration(grp),
        left_narration: nil,
        left_amount: settlement_left_amount(grp),
        right_narration: nil,
        right_amount: settlement_right_amount(grp),
        source: grp
      )
    end

    def settlement_narration(rec)
      first_party = rec.payer_id == viewer.id ? 'you' : rec.payer.name
      second_party = rec.payee_id == viewer.id ? 'you' : rec.payee.name
      "#{first_party} paid #{second_party}"
    end

    def settlement_left_amount(rec)
      return if both_parties_involved_in_settlement?(rec)
      return if [rec.payee_id, rec.payer_id].include?(viewer.id)

      rec.amount
    end

    def settlement_right_amount(rec)
      rec.amount if both_parties_involved_in_settlement?(rec) || my_account?
    end

    def both_parties_involved_in_settlement?(rec)
      ([account.id, viewer.id] & [rec.payee_id, rec.payer_id]).length == 2
    end

    def prepare_expense_entry(grp, members)
      JOURNAL_ENTRY.new(
        date: grp.paid_at,
        narration: grp.description,
        left_narration: expense_left_narration(grp),
        left_amount: grp.amount,
        right_narration: expense_right_narration(grp, members),
        right_amount: expense_right_amount(grp, members),
        source: grp
      )
    end

    def expense_left_narration(grp)
      name = grp.payer_id == viewer.id ? 'you' : grp.payer.name
      "#{name} paid"
    end

    def expense_right_narration(grp, members)
      if my_account?
        grp.payer_id == viewer.id ? 'you lent' : "#{grp.payer.name} lent you"
      else
        return 'not involved' unless both_parties_involved_in_expense?(grp, members)

        grp.payer_id == viewer.id ? "you lent #{account.name}" : "#{account.name} lent you"
      end
    end

    def expense_right_amount(grp, members)
      if my_account?
        members.sum(&:amount)
      elsif both_parties_involved_in_expense?(grp, members)
        members.select { |r| r.account_id == viewer.id }.sum(&:amount)
      end
    end

    def both_parties_involved_in_expense?(grp, members)
      parties = [account.id, viewer.id]
      parties.include?(grp.payer_id) &&
        (members.map(&:account_id) & parties).present?
    end
  end
end
