class CreateSplitPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :split_payments do |t|
      t.belongs_to :payment_component, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false

      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :category, null: false

      t.timestamps
    end
  end
end
