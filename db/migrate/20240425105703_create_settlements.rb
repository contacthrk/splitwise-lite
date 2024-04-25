class CreateSettlements < ActiveRecord::Migration[6.1]
  def change
    create_table :settlements do |t|
      t.belongs_to :payer, index: true, foreign_key: { to_table: :users }, null: false
      t.belongs_to :payee, index: true, foreign_key: { to_table: :users }, null: false

      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :paid_at, null: false
      t.text :notes

      t.timestamps
    end
  end
end
