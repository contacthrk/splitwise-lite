class CreatePaymentComponents < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_components do |t|
      t.belongs_to :expense, index: true, foreign_key: true, null: false

      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :description, null: false
      t.integer :category, null: false
      t.integer :split, null: false

      t.timestamps
    end
  end
end

