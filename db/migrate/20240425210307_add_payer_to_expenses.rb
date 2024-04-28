class AddPayerToExpenses < ActiveRecord::Migration[6.1]
  def change
    add_reference :expenses, :payer, index: true, foreign_key: { to_table: :users }, null: false
  end
end
