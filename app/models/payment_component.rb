class PaymentComponent < ApplicationRecord
  enum category: { manual: 0, tax: 1, tip: 2 }, _suffix: true
  enum split: { equal: 0, custom: 1 }, _suffix: true

  # associations
  belongs_to :expense
  has_many :split_payments, dependent: :destroy
  has_many :journal_transactions, as: :source, dependent: :destroy

  # validations
  validates :amount, :description, :category, :split_type, presence: true
  validates :amount, numericality: { greater_than: 0 }
end