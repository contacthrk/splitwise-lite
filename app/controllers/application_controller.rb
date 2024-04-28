class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :fetch_users

  private

  def fetch_users
    @users = User.all
  end
end
