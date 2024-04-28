class Settlement < ApplicationRecord
  include Journal

  # associations
  belongs_to :payer, class_name: 'User'
  belongs_to :payee, class_name: 'User'

  # validations
  validates :amount, :paid_at, presence: true
  validates :amount, numericality: { greater_than: 0 }

  after_save :recreate_journal_entries!

  private

  def recreate_journal_entries!
    journal_transactions.each(&:destroy!)
    create_double_entries!(payer: payer, payee: payee, date: paid_at, amount: amount)
  end
end
