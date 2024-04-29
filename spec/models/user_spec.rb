require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Associations' do
    it { is_expected.to have_many(:expenses).with_foreign_key(:creator_id) }
    it { is_expected.to have_many(:paid_settlements).with_foreign_key(:payer_id).class_name('Settlement') }
    it { is_expected.to have_many(:received_settlements).with_foreign_key(:payee_id).class_name('Settlement') }
    it { is_expected.to have_many(:journal_transactions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
