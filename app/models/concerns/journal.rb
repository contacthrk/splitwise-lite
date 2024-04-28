module Journal
  extend ActiveSupport::Concern

  included do
    has_many :journal_transactions, as: :source, dependent: :destroy

    def create_double_entries!(payer:, payee:, date:, amount:)
      journal_transactions.debit.create!(
        user: payer, account: payee, paid_at: date, amount: amount
      )
      journal_transactions.credit.create!(
        user: payee, account: payer, paid_at: date, amount: amount
      )
    end
  end
end
