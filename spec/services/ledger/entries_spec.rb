require 'rails_helper'

RSpec.describe Ledger::Entries, type: :model do
  describe '#call' do
    let!(:user1)  { Fabricate(:user) }
    let!(:user2)  { Fabricate(:user) }
    let!(:user3)  { Fabricate(:user) }
    let!(:user4)  { Fabricate(:user) }

    let(:account) { user2 }
    let(:viewer)  { user1 }

    subject(:entries) { described_class.new(account: user2, viewer: user1).call }

    let(:expense_save_manager1) do
      # expense paid by user1
      ExpenseManager::Save.new(
        user1.expenses.build,
        {
          amount: 0,
          paid_at: 4.days.ago.change(usec: 0),
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
      )
    end
    let(:expense_save_manager2) do
      # expense paid by user2
      ExpenseManager::Save.new(
        user1.expenses.build,
        {
          amount: 0,
          paid_at: 3.days.ago.change(usec: 0),
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
      )
    end
    let!(:settlement1) do
      Fabricate(:settlement, payer: user3, payee: user1, amount: 20, paid_at: 2.days.ago.change(usec: 0))
    end
    let!(:settlement2) do
      Fabricate(:settlement, payer: user1, payee: user4, amount: 20, paid_at: 1.day.ago.change(usec: 0))
    end

    before do
      expense_save_manager1.call
      expense_save_manager2.call
    end

    context 'when looking at other user entries' do
      it 'returns entries related to viewer' do
        expect(entries.length).to eq(2)
        expect(entries.first).to have_attributes(
          date: expense_save_manager2.expense.paid_at,
          narration: expense_save_manager2.expense.description,
          left_narration: "#{user2.name} paid",
          left_amount: expense_save_manager2.expense.amount,
          right_narration: "#{user2.name} lent you",
          right_amount: 30
        )
        expect(entries.last).to have_attributes(
          date: expense_save_manager1.expense.paid_at,
          narration: expense_save_manager1.expense.description,
          left_narration: 'you paid',
          left_amount: expense_save_manager1.expense.amount,
          right_narration: "you lent #{user2.name}",
          right_amount: 20
        )
      end
    end

    context 'when looking at self entries' do
      subject(:entries) { described_class.new(account: user1, viewer: user1).call }

      it 'returns entries related to viewer' do
        expect(entries.length).to eq(4)
        expect(entries[0]).to have_attributes(
          date: settlement2.paid_at,
          narration: "you paid #{user4.name}",
          left_narration: nil,
          left_amount: nil,
          right_narration: nil,
          right_amount: 20
        )
        expect(entries[1]).to have_attributes(
          date: settlement1.paid_at,
          narration: "#{user3.name} paid you",
          left_narration: nil,
          left_amount: nil,
          right_narration: nil,
          right_amount: 20
        )
        expect(entries[2]).to have_attributes(
          date: expense_save_manager2.expense.paid_at,
          narration: expense_save_manager2.expense.description,
          left_narration: "#{user2.name} paid",
          left_amount: expense_save_manager2.expense.amount,
          right_narration: "#{user2.name} lent you",
          right_amount: 30
        )
        expect(entries[3]).to have_attributes(
          date: expense_save_manager1.expense.paid_at,
          narration: expense_save_manager1.expense.description,
          left_narration: 'you paid',
          left_amount: expense_save_manager1.expense.amount,
          right_narration: 'you lent',
          right_amount: 40
        )
      end
    end
  end
end
