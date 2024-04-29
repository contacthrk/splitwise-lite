class ExpensesController < ApplicationController
  before_action :fetch_expense, only: [:show, :destroy]

  def create
    @expense_save_manager = ::ExpenseManager::Save.new(current_user.expenses.new(expense_params))
    @expense_saved = @expense_save_manager.call

    flash[:notice] = 'Expense created successfully' if @expense_saved

    respond_to do |format|
      format.js
    end
  end

  def show
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @expense.destroy
    redirect_back fallback_location: root_path, notice: "Expense deleted successfully"
  end

  private

  def fetch_expense
    @expense = Expense.where(id: params[:id]).includes(payment_components: :split_payments).first
  end

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
