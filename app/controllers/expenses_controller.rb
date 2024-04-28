class ExpensesController < ApplicationController
  def create
    @expense_save_manager = ::ExpenseManager::Save.new(current_user.expenses.new(expense_params))
    @expense_saved = @expense_save_manager.call

    flash[:notice] = 'Expense created successfully' if @expense_saved

    respond_to do |format|
      format.js
    end
  end

  private

  def expense_params
    params
      .require(:expense)
      .permit(
        :amount, :paid_at, :description, :notes, :payer_id, payment_components_attributes: [
          :id, :amount, :description, :category, :split, { split_payments_attributes: [:id, :user_id, :amount] }
        ]
      )
  end
end
