class SplitPayment < ApplicationRecord
  enum category: { payer: 0, co_payer: 1 }

  # associations
  belongs_to :payment_component
  belongs_to :user

  # validations
  validates :amount, :category, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
