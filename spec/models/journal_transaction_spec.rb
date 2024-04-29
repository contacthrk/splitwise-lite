require 'rails_helper'

RSpec.describe JournalTransaction, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:account).class_name('User') }
    it { is_expected.to belong_to(:source) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:paid_at) }
    it { is_expected.to validate_presence_of(:transaction_type) }
    it { is_expected.to validate_inclusion_of(:source_type).in_array(JournalTransaction::VAILD_SOURCES) }
  end
end
