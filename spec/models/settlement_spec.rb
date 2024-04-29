require 'rails_helper'

RSpec.describe Settlement, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:payer).class_name('User') }
    it { is_expected.to belong_to(:payee).class_name('User') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:paid_at) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }

    describe 'payer and payee validation' do
      subject(:settlement) do
        Fabricate.build(:settlement, payer: payer, payee: payee)
      end

      let(:user1) { Fabricate(:user) }
      let(:user2) { Fabricate(:user) }

      let(:payer) { user1 }
      let(:payee) { user2 }

      context 'when payer and payee are same' do
        let(:payee) { user1 }

        it 'adds error' do
          expect(settlement).to be_invalid
          expect(settlement.errors[:payee]).to include(
            'should be different from payer'
          )
        end
      end

      context 'when payer and payee are different' do
        it { is_expected.to be_valid }
      end
    end
  end

  describe 'callbacks' do
    subject!(:settlement) do
      Fabricate(:settlement, payer: user1, payee: user2)
    end

    let(:user1) { Fabricate(:user) }
    let(:user2) { Fabricate(:user) }

    it 'creates journal entries for settlement' do
      expect(settlement.journal_transactions.count).to eq(2)
      expect(settlement.journal_transactions.where(user: user1).first).to have_attributes(
        account: user2,
        amount: settlement.amount,
        transaction_type: 'debit',
        paid_at: settlement.paid_at
      )
      expect(settlement.journal_transactions.where(user: user2).first).to have_attributes(
        account: user1,
        amount: settlement.amount,
        transaction_type: 'credit',
        paid_at: settlement.paid_at
      )
    end
  end
end
