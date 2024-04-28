class StaticController < ApplicationController
  def dashboard
    @summary = BalanceSheet::Summary.new(current_user).call
  end

  def person
  end
end
