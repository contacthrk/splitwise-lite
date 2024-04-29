class StaticController < ApplicationController
  def dashboard
    @summary = ::Ledger::Summary.new(current_user).call
  end

  def person
    friend = User.find(params[:id])
    @entries = ::Ledger::Entries.new(account: friend, viewer: current_user).call
  end
end
