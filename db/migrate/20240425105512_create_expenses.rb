class CreateExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :expenses do |t|
      t.belongs_to :creator, index: true, foreign_key: { to_table: :users }, null: false

      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :paid_at, null: false
      t.string :description, null: false
      t.text :notes

      t.timestamps
    end
  end
end
