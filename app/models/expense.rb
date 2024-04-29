class Expense < ApplicationRecord
  # associations
  belongs_to :creator, class_name: 'User'
  belongs_to :payer, class_name: 'User'
  has_many :payment_components, -> { order(:category) }, dependent: :destroy, inverse_of: :expense

  # validations
  validates :paid_at, :description, presence: true
  validate :check_atleast_one_manual_payment_component_exists

  accepts_nested_attributes_for :payment_components, allow_destroy: true

  after_save :sync_amount_from_payment_components

  private

  # rubocop:disable Rails/SkipsModelValidations
  def sync_amount_from_payment_components
    update_columns(amount: payment_components.sum { |pc| pc.amount || 0 })
  end
  # rubocop:enable Rails/SkipsModelValidations

  def check_atleast_one_manual_payment_component_exists
    return if payment_components.find(&:manual_category?)

    errors.add(:payment_components, 'must be present (atleast one)')
  end
end
