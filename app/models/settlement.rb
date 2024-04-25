class Settlement < ApplicationRecord
  # associations
  belongs_to :payer, class_name: "User"
  belongs_to :payee, class_name: "User"
  has_many :journal_transactions, as: :source, dependent: destroy

  # validations
  validates :amunt, :paid_at, presence: true
  validates :amount, numericality: { greater_than: 0 }
end