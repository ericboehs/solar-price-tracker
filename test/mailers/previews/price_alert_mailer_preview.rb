# Preview at http://localhost:3000/rails/mailers/price_alert_mailer/new_low
class PriceAlertMailerPreview < ActionMailer::Preview
  def new_low
    product = Product.first
    PriceAlertMailer.new_low(User.first, product, previous_low: product.price + 150, previous_price: product.price + 300)
  end
end
