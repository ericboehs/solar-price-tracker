# One-click unsubscribe from price alert emails via a signed token (no sign-in).
# GET shows a confirm button so link scanners can't unsubscribe people.
class UnsubscribesController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user

  def show
  end

  def create
    @user.update!(price_alerts: false)
    redirect_to welcome_index_path, notice: "You're unsubscribed from price alert emails."
  end

  private
    def set_user
      @user = User.find_by_token_for(:unsubscribe, params[:token])
      redirect_to welcome_index_path, alert: "That unsubscribe link is invalid or already used." unless @user
    end
end
