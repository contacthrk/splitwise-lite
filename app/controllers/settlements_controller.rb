class SettlementsController < ApplicationController
  before_action :fetch_settlement, only: :show

  def create
    @settlement = Settlement.new(settlement_params)

    flash[:notice] = 'Settlement created successfully' if @settlement.save

    respond_to do |format|
      format.js
    end
  end

  def show
    respond_to do |format|
      format.js
    end
  end

  private

  def fetch_settlement
    @settlement = Settlement.find(params[:id])
  end

  def settlement_params
    params
      .require(:settlement)
      .permit(:amount, :paid_at, :payer_id, :payee_id, :notes)
  end
end
