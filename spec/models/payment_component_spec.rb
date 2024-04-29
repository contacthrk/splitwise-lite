require 'rails_helper'

RSpec.describe PaymentComponent, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:expense) }
    it { is_expected.to have_many(:split_payments).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:split) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }

    describe 'split payment count validation' do
      subject(:payment_component) { Fabricate.build(:payment_component) }

      let(:user1) { Fabricate(:user) }

      context 'when no split payment are present' do
        it 'adds error' do
          expect(payment_component).to be_invalid
          expect(payment_component.errors[:split_payments]).to include(
            'must be present (atleast one)'
          )
        end
      end

      context 'when split payment is present' do
        subject(:payment_component) do
          Fabricate.build(
            :payment_component,
            split_payments_attributes: [
              {
                user_id: user1.id,
                amount: 100
              }
            ]
          )
        end

        it "doesn't add error" do
          expect(payment_component).to be_invalid
          expect(payment_component.errors[:split_payments]).to be_empty
        end
      end
    end

    describe 'total amount validation' do
      subject(:payment_component) do
        Fabricate.build(
          :payment_component,
          amount: 100,
          split_payments_attributes: [
            {
              user_id: user1.id,
              amount: split_payment_amount
            }
          ]
        )
      end

      let(:user1) { Fabricate(:user) }
      let(:split_payment_amount) { 20 }

      context 'when payement component amount and split payment amount is not same' do
        it 'adds error' do
          expect(payment_component).to be_invalid
          expect(payment_component.errors[:amount]).to include(
            'is not matching with total amount'
          )
        end
      end

      context 'when payement component amount and split payment amount is same' do
        let(:split_payment_amount) { 100 }

        it "doesn't add error" do
          expect(payment_component).to be_invalid
          expect(payment_component.errors[:amount]).to be_empty
        end
      end
    end
  end
end
