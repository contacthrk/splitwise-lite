require 'rails_helper'

RSpec.describe SplitPayment, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:payment_component) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
  end
end
