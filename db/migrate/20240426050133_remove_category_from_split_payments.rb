class RemoveCategoryFromSplitPayments < ActiveRecord::Migration[6.1]
  def change
    remove_column :split_payments, :category, :integer
  end
end
