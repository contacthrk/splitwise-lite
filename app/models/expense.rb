class Expense < ApplicationRecord
  # associations
  belongs_to :creator, class_name: 'User'
  has_many :payment_components, dependent: :destroy

  # validations
  validates :amount, paid_at, :description, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
