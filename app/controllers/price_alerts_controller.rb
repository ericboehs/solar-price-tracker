class PriceAlertsController < ApplicationController
  def create
    current_user.update!(price_alerts: true)
    redirect_back_or_to products_path, notice: "You'll get an email when a product hits a new low."
  end

  def destroy
    current_user.update!(price_alerts: false)
    redirect_back_or_to products_path, notice: "Price alert emails are off."
  end
end
