class SplitPayment < ApplicationRecord
  # associations
  belongs_to :payment_component
  belongs_to :user

  # validations
  validates :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
