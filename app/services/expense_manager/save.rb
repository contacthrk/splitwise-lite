module ExpenseManager
  class Save
    attr_reader :errors

    def initialize(rec)
      @expense = rec
      @errors = []
    end

    def call
      save_expense_and_create_journal_entries!
    rescue ActiveRecord::RecordInvalid
      @errors = @expense.errors.full_messages
      false
    rescue StandardError => e
      @errors = [e.message]
      false
    end

    private

    attr_reader :expense

    def save_expense_and_create_journal_entries!
      ActiveRecord::Base.transaction do
        expense.save!
        expense.payment_components.each do |pc|
          recreate_journal_entries!(pc)
        end
      end
      true
    end

    def recreate_journal_entries!(payment_component)
      # this is for edit case: where we would recreate journal transactions
      payment_component.journal_transactions.map(&:destroy!)

      payment_component.split_payments.each do |sp|
        # skip journal entry for payer's own expense as the expense a/c is out of the
        # system hence it doesn't require double entry
        # only accounts(users) that are part of the system would have double entry journal
        next if sp.user == expense.payer

        payment_component.create_double_entries!(
          payer: expense.payer,
          payee: sp.user,
          date: expense.paid_at,
          amount: sp.amount
        )
      end
    end
  end
end
