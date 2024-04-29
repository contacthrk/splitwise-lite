require 'rails_helper'

RSpec.describe Ledger::Summary, type: :model do
  describe '#call' do
    let!(:user1) { Fabricate(:user) }
    let!(:user2) { Fabricate(:user) }
    let!(:user3) { Fabricate(:user) }
    let!(:user4) { Fabricate(:user) }

    subject(:summary) { described_class.new(user1).call }

    before do
      # expense paid by user1
      ExpenseManager::Save.new(
        user1.expenses.build,
        {
          amount: 0,
          paid_at: Time.current.change(usec: 0),
          description: 'test expense 1',
          payer_id: user1.id,
          payment_components_attributes: [
            {
              amount: 60,
              description: 'item 1',
              category: 'manual',
              split: 'equal',
              split_payments_attributes: [
                { user_id: user1.id, amount: 20 },
                { user_id: user2.id, amount: 20 },
                { user_id: user3.id, amount: 20 }
              ]
            }
          ]
        }
      ).call

      # expense paid by user2
      ExpenseManager::Save.new(
        user1.expenses.build,
        {
          amount: 0,
          paid_at: Time.current.change(usec: 0),
          description: 'test expense 2',
          payer_id: user2.id,
          payment_components_attributes: [
            {
              amount: 90,
              description: 'item 1',
              category: 'manual',
              split: 'custom',
              split_payments_attributes: [
                { user_id: user1.id, amount: 30 },
                { user_id: user2.id, amount: 20 },
                { user_id: user4.id, amount: 40 }
              ]
            }
          ]
        }
      ).call

      Fabricate(:settlement, payer: user3, payee: user1, amount: 20)
      Fabricate(:settlement, payer: user1, payee: user4, amount: 20)
    end

    it 'returns summary for borrowed and lended amounts' do
      expect(summary.creditors.length).to eq(1)
      expect(summary.creditors.first.account_id).to eq(user2.id)
      expect(summary.borrowed).to eq(10)

      expect(summary.debtors.length).to eq(1)
      expect(summary.debtors.first.account_id).to eq(user4.id)
      expect(summary.loaned).to eq(20)

      expect(summary.total).to eq(10)
    end
  end
end
