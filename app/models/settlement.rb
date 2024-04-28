class Settlement < ApplicationRecord
  include Journal

  # associations
  belongs_to :payer, class_name: 'User'
  belongs_to :payee, class_name: 'User'

  # validations
  validates :amount, :paid_at, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validate :check_payer_and_payee_are_different

  after_save :recreate_journal_entries!

  private

  def check_payer_and_payee_are_different
    return if payer_id != payee_id

    errors.add(:payee, 'should be different from payer')
  end

  def recreate_journal_entries!
    journal_transactions.each(&:destroy!)
    create_double_entries!(payer: payer, payee: payee, date: paid_at, amount: amount)
  end
end
