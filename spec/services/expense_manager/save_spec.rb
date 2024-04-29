require 'rails_helper'

RSpec.describe ExpenseManager::Save, type: :model do
  describe '#call' do
    let!(:user1) { Fabricate(:user) }
    let!(:user2) { Fabricate(:user) }
    let!(:user3) { Fabricate(:user) }

    let(:expense) { user1.expenses.build }

    let(:expense_main_attributes) do
      {
        amount: 0,
        paid_at: Time.current.change(usec: 0),
        description: 'test expense',
        payer_id: user1.id
      }
    end

    context 'success' do
      context 'when single payment component is present' do
        let(:payment_component_1_main_attributes) do
          {
            amount: 60,
            description: 'item 1',
            category: 'manual',
            split: 'equal'
          }
        end
        let(:payment_component_1_attributes) do
          payment_component_1_main_attributes.merge(
            split_payments_attributes: [
              {
                user_id: user1.id,
                amount: 20
              },
              {
                user_id: user2.id,
                amount: 20
              },
              {
                user_id: user3.id,
                amount: 20
              }
            ]
          )
        end

        let(:expense_attributes) do
          expense_main_attributes.merge(
            {
              payment_components_attributes: [
                payment_component_1_attributes
              ]
            }
          )
        end

        let(:expense_save_manager) { described_class.new(expense, expense_attributes) }
        let(:save_expense) { expense_save_manager.call }

        let(:first_payment_component) { expense_save_manager.expense.payment_components.first }

        it 'creates expense with payment components' do
          expect(save_expense).to be_truthy
          expect(expense_save_manager.expense).to be_persisted
          expect(expense_save_manager.expense).to have_attributes(
            expense_main_attributes.merge(amount: 60)
          )
          expect(expense_save_manager.expense.payment_components.count).to eq(1)
          expect(first_payment_component).to have_attributes(
            payment_component_1_main_attributes
          )
          expect(first_payment_component.split_payments.count).to eq(3)
          expect(
            first_payment_component.split_payments.first
          ).to have_attributes(
            user_id: user1.id,
            amount: 20
          )
          expect(
            first_payment_component.split_payments.second
          ).to have_attributes(
            user_id: user2.id,
            amount: 20
          )
          expect(
            first_payment_component.split_payments.third
          ).to have_attributes(
            user_id: user3.id,
            amount: 20
          )
        end

        it 'creates journal transactions' do
          expect(save_expense).to be_truthy
          expect(
            first_payment_component.journal_transactions.count
          ).to eq(4)
          expect(
            first_payment_component.journal_transactions.where(user: user1).count
          ).to eq(2)
          expect(
            first_payment_component.journal_transactions.where(user: user1, account: user2).first
          ).to have_attributes(
            amount: 20,
            transaction_type: 'debit',
            paid_at: expense_save_manager.expense.paid_at
          )
          expect(
            first_payment_component.journal_transactions.where(user: user1, account: user3).first
          ).to have_attributes(
            amount: 20,
            transaction_type: 'debit',
            paid_at: expense_save_manager.expense.paid_at
          )

          expect(
            first_payment_component.journal_transactions.where(user: user2).count
          ).to eq(1)
          expect(
            first_payment_component.journal_transactions.where(user: user2, account: user1).first
          ).to have_attributes(
            amount: 20,
            transaction_type: 'credit',
            paid_at: expense_save_manager.expense.paid_at
          )

          expect(
            first_payment_component.journal_transactions.where(user: user3).count
          ).to eq(1)
          expect(
            first_payment_component.journal_transactions.where(user: user3, account: user1).first
          ).to have_attributes(
            amount: 20,
            transaction_type: 'credit',
            paid_at: expense_save_manager.expense.paid_at
          )
        end

        context 'when custom split is used' do
          let(:payment_component_1_main_attributes) do
            {
              amount: 60,
              description: 'item 1',
              category: 'manual',
              split: 'custom'
            }
          end
          let(:payment_component_1_attributes) do
            payment_component_1_main_attributes.merge(
              split_payments_attributes: [
                {
                  user_id: user1.id,
                  amount: 10
                },
                {
                  user_id: user2.id,
                  amount: 30
                },
                {
                  user_id: user3.id,
                  amount: 20
                }
              ]
            )
          end

          it 'creates expense with payment components' do
            expect(save_expense).to be_truthy
            expect(expense_save_manager.expense).to be_persisted
            expect(expense_save_manager.expense).to have_attributes(
              expense_main_attributes.merge(amount: 60)
            )
            expect(expense_save_manager.expense.payment_components.count).to eq(1)
            expect(first_payment_component).to have_attributes(
              payment_component_1_main_attributes
            )
            expect(first_payment_component.split_payments.count).to eq(3)
            expect(
              first_payment_component.split_payments.first
            ).to have_attributes(
              user_id: user1.id,
              amount: 10
            )
            expect(
              first_payment_component.split_payments.second
            ).to have_attributes(
              user_id: user2.id,
              amount: 30
            )
            expect(
              first_payment_component.split_payments.third
            ).to have_attributes(
              user_id: user3.id,
              amount: 20
            )
          end

          it 'creates journal transactions' do
            expect(save_expense).to be_truthy
            expect(
              first_payment_component.journal_transactions.count
            ).to eq(4)
            expect(
              first_payment_component.journal_transactions.where(user: user1).count
            ).to eq(2)
            expect(
              first_payment_component.journal_transactions.where(user: user1, account: user2).first
            ).to have_attributes(
              amount: 30,
              transaction_type: 'debit',
              paid_at: expense_save_manager.expense.paid_at
            )
            expect(
              first_payment_component.journal_transactions.where(user: user1, account: user3).first
            ).to have_attributes(
              amount: 20,
              transaction_type: 'debit',
              paid_at: expense_save_manager.expense.paid_at
            )

            expect(
              first_payment_component.journal_transactions.where(user: user2).count
            ).to eq(1)
            expect(
              first_payment_component.journal_transactions.where(user: user2, account: user1).first
            ).to have_attributes(
              amount: 30,
              transaction_type: 'credit',
              paid_at: expense_save_manager.expense.paid_at
            )

            expect(
              first_payment_component.journal_transactions.where(user: user3).count
            ).to eq(1)
            expect(
              first_payment_component.journal_transactions.where(user: user3, account: user1).first
            ).to have_attributes(
              amount: 20,
              transaction_type: 'credit',
              paid_at: expense_save_manager.expense.paid_at
            )
          end
        end

        context 'when decimal amounts are used' do
          let(:payment_component_1_main_attributes) do
            {
              amount: 60,
              description: 'item 1',
              category: 'manual',
              split: 'custom'
            }
          end
          let(:payment_component_1_attributes) do
            payment_component_1_main_attributes.merge(
              split_payments_attributes: [
                {
                  user_id: user1.id,
                  amount: 10.5
                },
                {
                  user_id: user2.id,
                  amount: 29.5
                },
                {
                  user_id: user3.id,
                  amount: 20
                }
              ]
            )
          end

          it 'creates expense with payment components' do
            expect(save_expense).to be_truthy
            expect(expense_save_manager.expense).to be_persisted
            expect(expense_save_manager.expense).to have_attributes(
              expense_main_attributes.merge(amount: 60)
            )
            expect(expense_save_manager.expense.payment_components.count).to eq(1)
            expect(first_payment_component).to have_attributes(
              payment_component_1_main_attributes
            )
            expect(first_payment_component.split_payments.count).to eq(3)
            expect(
              first_payment_component.split_payments.first
            ).to have_attributes(
              user_id: user1.id,
              amount: 10.5
            )
            expect(
              first_payment_component.split_payments.second
            ).to have_attributes(
              user_id: user2.id,
              amount: 29.5
            )
            expect(
              first_payment_component.split_payments.third
            ).to have_attributes(
              user_id: user3.id,
              amount: 20
            )
          end

          it 'creates journal transactions' do
            expect(save_expense).to be_truthy
            expect(
              first_payment_component.journal_transactions.count
            ).to eq(4)
            expect(
              first_payment_component.journal_transactions.where(user: user1).count
            ).to eq(2)
            expect(
              first_payment_component.journal_transactions.where(user: user1, account: user2).first
            ).to have_attributes(
              amount: 29.5,
              transaction_type: 'debit',
              paid_at: expense_save_manager.expense.paid_at
            )
            expect(
              first_payment_component.journal_transactions.where(user: user1, account: user3).first
            ).to have_attributes(
              amount: 20,
              transaction_type: 'debit',
              paid_at: expense_save_manager.expense.paid_at
            )

            expect(
              first_payment_component.journal_transactions.where(user: user2).count
            ).to eq(1)
            expect(
              first_payment_component.journal_transactions.where(user: user2, account: user1).first
            ).to have_attributes(
              amount: 29.5,
              transaction_type: 'credit',
              paid_at: expense_save_manager.expense.paid_at
            )

            expect(
              first_payment_component.journal_transactions.where(user: user3).count
            ).to eq(1)
            expect(
              first_payment_component.journal_transactions.where(user: user3, account: user1).first
            ).to have_attributes(
              amount: 20,
              transaction_type: 'credit',
              paid_at: expense_save_manager.expense.paid_at
            )
          end
        end
      end

      context 'when mutiple payment components are used' do
        let(:payment_component_1_main_attributes) do
          {
            amount: 60,
            description: 'item 1',
            category: 'manual',
            split: 'equal'
          }
        end
        let(:payment_component_1_attributes) do
          payment_component_1_main_attributes.merge(
            split_payments_attributes: [
              {
                user_id: user1.id,
                amount: 20
              },
              {
                user_id: user2.id,
                amount: 20
              },
              {
                user_id: user3.id,
                amount: 20
              }
            ]
          )
        end

        let(:payment_component_2_main_attributes) do
          {
            amount: 40,
            description: 'item 2',
            category: 'manual',
            split: 'custom'
          }
        end
        let(:payment_component_2_attributes) do
          payment_component_2_main_attributes.merge(
            split_payments_attributes: [
              {
                user_id: user1.id,
                amount: 25.5
              },
              {
                user_id: user2.id,
                amount: 14.5
              }
            ]
          )
        end

        let(:expense_attributes) do
          expense_main_attributes.merge(
            {
              payment_components_attributes: [
                payment_component_1_attributes,
                payment_component_2_attributes
              ]
            }
          )
        end

        let(:expense_save_manager) { described_class.new(expense, expense_attributes) }
        let(:save_expense) { expense_save_manager.call }

        let(:first_payment_component) { expense_save_manager.expense.payment_components.first }
        let(:second_payment_component) { expense_save_manager.expense.payment_components.last }

        it 'creates expense with payment components' do
          expect(save_expense).to be_truthy
          expect(expense_save_manager.expense).to be_persisted
          expect(expense_save_manager.expense).to have_attributes(
            expense_main_attributes.merge(amount: 100)
          )
          expect(expense_save_manager.expense.payment_components.count).to eq(2)

          expect(first_payment_component).to have_attributes(
            payment_component_1_main_attributes
          )
          expect(first_payment_component.split_payments.count).to eq(3)
          expect(
            first_payment_component.split_payments.first
          ).to have_attributes(
            user_id: user1.id,
            amount: 20
          )
          expect(
            first_payment_component.split_payments.second
          ).to have_attributes(
            user_id: user2.id,
            amount: 20
          )
          expect(
            first_payment_component.split_payments.third
          ).to have_attributes(
            user_id: user3.id,
            amount: 20
          )

          expect(second_payment_component).to have_attributes(
            payment_component_2_main_attributes
          )
          expect(second_payment_component.split_payments.count).to eq(2)
          expect(
            second_payment_component.split_payments.first
          ).to have_attributes(
            user_id: user1.id,
            amount: 25.5
          )
          expect(
            second_payment_component.split_payments.second
          ).to have_attributes(
            user_id: user2.id,
            amount: 14.5
          )
        end

        it 'creates journal transactions' do
          expect(save_expense).to be_truthy
          expect(
            first_payment_component.journal_transactions.count
          ).to eq(4)
          expect(
            first_payment_component.journal_transactions.where(user: user1).count
          ).to eq(2)
          expect(
            first_payment_component.journal_transactions.where(user: user1, account: user2).first
          ).to have_attributes(
            amount: 20,
            transaction_type: 'debit',
            paid_at: expense_save_manager.expense.paid_at
          )
          expect(
            first_payment_component.journal_transactions.where(user: user1, account: user3).first
          ).to have_attributes(
            amount: 20,
            transaction_type: 'debit',
            paid_at: expense_save_manager.expense.paid_at
          )

          expect(
            first_payment_component.journal_transactions.where(user: user2).count
          ).to eq(1)
          expect(
            first_payment_component.journal_transactions.where(user: user2, account: user1).first
          ).to have_attributes(
            amount: 20,
            transaction_type: 'credit',
            paid_at: expense_save_manager.expense.paid_at
          )

          expect(
            first_payment_component.journal_transactions.where(user: user3).count
          ).to eq(1)
          expect(
            first_payment_component.journal_transactions.where(user: user3, account: user1).first
          ).to have_attributes(
            amount: 20,
            transaction_type: 'credit',
            paid_at: expense_save_manager.expense.paid_at
          )

          expect(
            second_payment_component.journal_transactions.count
          ).to eq(2)
          expect(
            second_payment_component.journal_transactions.where(user: user1).count
          ).to eq(1)
          expect(
            second_payment_component.journal_transactions.where(user: user1, account: user2).first
          ).to have_attributes(
            amount: 14.5,
            transaction_type: 'debit',
            paid_at: expense_save_manager.expense.paid_at
          )

          expect(
            second_payment_component.journal_transactions.where(user: user2).count
          ).to eq(1)
          expect(
            second_payment_component.journal_transactions.where(user: user2, account: user1).first
          ).to have_attributes(
            amount: 14.5,
            transaction_type: 'credit',
            paid_at: expense_save_manager.expense.paid_at
          )
        end
      end
    end

    context 'failure' do
      let(:expense_attributes) do
        expense_main_attributes
      end

      let(:expense_save_manager) { described_class.new(expense, expense_attributes) }
      let(:save_expense) { expense_save_manager.call }

      context 'when all expense details and no payment component is passed' do
        let(:expense_main_attributes) do
          {
            amount: 0,
            description: 'test expense',
            payer_id: user1.id
          }
        end

        it "doesn't create expense" do
          expect(save_expense).to be_falsy
          expect(expense_save_manager.errors).to include(
            "Paid at can't be blank",
            'Items must be present (atleast one)'
          )
        end
      end

      context 'when payment component amount is zero' do
        let(:payment_component_1_main_attributes) do
          {
            amount: 0,
            description: 'item 1',
            category: 'manual',
            split: 'equal'
          }
        end
        let(:payment_component_1_attributes) do
          payment_component_1_main_attributes.merge(
            split_payments_attributes: [
              {
                user_id: user1.id,
                amount: 20
              }
            ]
          )
        end

        let(:expense_attributes) do
          expense_main_attributes.merge(
            {
              payment_components_attributes: [
                payment_component_1_attributes
              ]
            }
          )
        end

        it "doesn't create expense" do
          expect(save_expense).to be_falsy
          expect(expense_save_manager.errors).to include(
            'Payment components amount must be greater than 0',
            'Payment components amount is not matching with total amount'
          )
        end
      end

      context 'when no split payment is passed in payment component' do
        let(:payment_component_1_main_attributes) do
          {
            amount: 20,
            description: 'item 1',
            category: 'manual',
            split: 'equal'
          }
        end
        let(:payment_component_1_attributes) do
          payment_component_1_main_attributes
        end

        let(:expense_attributes) do
          expense_main_attributes.merge(
            {
              payment_components_attributes: [
                payment_component_1_attributes
              ]
            }
          )
        end

        it "doesn't create expense" do
          expect(save_expense).to be_falsy
          expect(expense_save_manager.errors).to include(
            'Payment components amount is not matching with total amount',
            'Payment components split payments must be present (atleast one)'
          )
        end
      end

      context 'when split payment amount is zero' do
        let(:payment_component_1_main_attributes) do
          {
            amount: 20,
            description: 'item 1',
            category: 'manual',
            split: 'equal'
          }
        end
        let(:payment_component_1_attributes) do
          payment_component_1_main_attributes.merge(
            split_payments_attributes: [
              {
                user_id: user1.id,
                amount: 0
              }
            ]
          )
        end

        let(:expense_attributes) do
          expense_main_attributes.merge(
            {
              payment_components_attributes: [
                payment_component_1_attributes
              ]
            }
          )
        end

        it "doesn't create expense" do
          expect(save_expense).to be_falsy
          expect(expense_save_manager.errors).to include(
            'Payment components amount is not matching with total amount',
            'Payment components split payments amount must be greater than 0'
          )
        end
      end

      context "when no split payments amount doesn't match with payment components amount" do
        let(:payment_component_1_main_attributes) do
          {
            amount: 20,
            description: 'item 1',
            category: 'manual',
            split: 'equal'
          }
        end
        let(:payment_component_1_attributes) do
          payment_component_1_main_attributes.merge(
            split_payments_attributes: [
              {
                user_id: user1.id,
                amount: 10
              }
            ]
          )
        end

        let(:expense_attributes) do
          expense_main_attributes.merge(
            {
              payment_components_attributes: [
                payment_component_1_attributes
              ]
            }
          )
        end

        it "doesn't create expense" do
          expect(save_expense).to be_falsy
          expect(expense_save_manager.errors).to include(
            'Payment components amount is not matching with total amount'
          )
        end
      end
    end
  end
end
