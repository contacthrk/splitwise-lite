class CreateJournalTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :journal_transactions do |t|
      t.belongs_to :user, index: true, foreign_key: true, null: false
      t.belongs_to :account, index: true, foreign_key: { to_table: :users }, null: false

      t.bigint  :source_id, null: false
      t.string  :source_type, null: false

      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :transaction_type, null: false
      t.datetime :paid_at, null: false

      t.timestamps
    end

    add_index :journal_transactions, [:user_id, :paid_at], name: 'index_jt_user_time'
    add_index :journal_transactions, [:user_id, :paid_at, :transaction_type], name: 'index_jt_user_time_type'
    add_index :journal_transactions, [:user_id, :account_id, :source_id, :source_type], unique: true, name: 'index_jt_user_account_source'
  end
end