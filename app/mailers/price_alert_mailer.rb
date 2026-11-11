class PriceAlertMailer < ApplicationMailer
  def new_low(user, product, previous_low:, previous_price:)
    @user = user
    @product = product
    @previous_low = previous_low
    @previous_price = previous_price
    @savings = previous_price - product.price
    @unsubscribe_url = unsubscribe_url(token: user.generate_token_for(:unsubscribe))

    headers["List-Unsubscribe"] = "<#{@unsubscribe_url}>"
    mail to: user.email_address,
      subject: "New low: #{product.title.truncate(60)} is #{product.display_price}"
  end
end
