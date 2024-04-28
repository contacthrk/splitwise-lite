class PaymentComponent < ApplicationRecord
  include Journal

  enum category: { manual: 0, tax: 1, tip: 2 }, _suffix: true
  enum split: { equal: 0, custom: 1 }, _suffix: true

  # associations
  belongs_to :expense
  has_many :split_payments, dependent: :destroy

  # validations
  validates :amount, :description, :category, :split, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validate :check_split_payments_total, :check_atleast_one_split_payment_exists

  accepts_nested_attributes_for :split_payments, allow_destroy: true

  delegate :paid_at, to: :expense

  private

  def check_split_payments_total
    return if split_payments.sum { |sp| sp.amount || 0 } == amount

    errors.add(:amount, 'is not matching with total amount')
  end

  def check_atleast_one_split_payment_exists
    return unless split_payments.empty?

    errors.add(:split_payments, 'must be present (atleast one)')
  end
end
