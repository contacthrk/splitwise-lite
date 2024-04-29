require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:creator).class_name('User') }
    it { is_expected.to belong_to(:payer).class_name('User') }
    it { is_expected.to have_many(:payment_components).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:paid_at) }
    it { is_expected.to validate_presence_of(:description) }

    describe 'payment component count validation' do
      subject(:expense) { Fabricate.build(:expense) }

      let(:user1) { Fabricate(:user) }

      context 'when no payment components are present' do
        it 'adds error' do
          expect(expense).to be_invalid
          expect(expense.errors[:payment_components]).to include(
            'must be present (atleast one)'
          )
        end
      end

      context 'when payment component is present' do
        subject(:expense) do
          Fabricate.build(
            :expense,
            payer: user1,
            creator: user1,
            payment_components_attributes: [
              {
                amount: 200,
                description: 'item 1',
                category: 'manual',
                split: 'equal',
                split_payments_attributes: [
                  {
                    user_id: user1.id,
                    amount: 200
                  }
                ]
              }
            ]
          )
        end

        it "doesn't add error" do
          expect(expense).to be_valid
        end
      end
    end
  end

  describe 'callbacks' do
    subject!(:expense) do
      Fabricate(
        :expense,
        payer: user1,
        creator: user1,
        payment_components_attributes: [
          {
            amount: 200,
            description: 'item 1',
            category: 'manual',
            split: 'equal',
            split_payments_attributes: [
              {
                user_id: user1.id,
                amount: 200
              }
            ]
          }
        ]
      )
    end

    let(:user1) { Fabricate(:user) }

    it 'syncs amount from payment components' do
      expect(expense).to be_persisted
      expect(expense.amount).to eq(200)
    end
  end
end
