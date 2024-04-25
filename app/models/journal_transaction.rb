class JournalTransaction < ApplicationRecord
  VAILD_SOURCES = ["PaymentComponent", "Settlement"].freeze

  enum transaction_type: { debit: -1, credit: 1 }

  # associations
  belongs_to :user
  belongs_to :account, class_name: "User"
  belongs_to :source, polymorphic: true

  # validations
  validates :amount, :paid_at, :transaction_type, presence: true
  validates :resource_type, inclusion: { in: VAILD_SOURCES }
end