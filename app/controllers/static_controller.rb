class StaticController < ApplicationController
  def dashboard
    @users = User.all
    setup_new_expense
  end

  def person
  end

  private

  def setup_new_expense
    @expense = Expense.new(payer: current_user, amount: 0, paid_at: Time.current)
  end
end
