require 'ostruct'
module Ledger
  class Summary
    def initialize(rec)
      @user = rec
    end

    def call
      @account_aggregates = fetch_account_aggregates.to_a
      identify_debtors_and_creditors
      prepare
    end

    private

    attr_reader :user, :debtors, :creditors, :account_aggregates

    # returns an Ostruct with required balances and list of debtors and creditors
    # Debtors - are sorted in order with highest debt balance first as those are negative numbers
    # Creditors - need to sort in ruby to put on top who owes me the max amount
    def fetch_account_aggregates
      user.journal_transactions.select('SUM(transaction_type*amount) as balance', :account_id)
          .having('SUM(transaction_type*amount) != 0')
          .group(:account_id)
          .includes(:account)
          .order(:balance)
    end

    def identify_debtors_and_creditors
      @creditors, @debtors = @account_aggregates.partition { |x| x.balance.positive? }
      @creditors = @creditors.reverse
    end

    def prepare
      OpenStruct.new(creditors: creditors, debtors: debtors).tap do |r|
        r.borrowed = creditors.sum(&:balance)
        r.loaned = debtors.sum(&:balance).abs
        r.total = r.loaned - r.borrowed
      end
    end
  end
end
