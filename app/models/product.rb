class Product < ApplicationRecord
  has_many :price_histories, dependent: :destroy
  
  validates :title, presence: true
  validates :url, presence: true, uniqueness: true
  
  def current_price
    price_histories.recent.first&.price || price
  end
  
  def price_changed?(new_price)
    latest_price = price_histories.recent.first&.price
    return true if latest_price.nil?
    
    # Consider prices different if they vary by more than $0.01
    (latest_price - new_price).abs > 0.01
  end
  
  def record_price(new_price, recorded_at = Time.current)
    if price_changed?(new_price)
      price_histories.create!(
        price: new_price,
        recorded_at: recorded_at
      )
      
      # Update the legacy price field for backwards compatibility
      update_column(:price, new_price)
      
      true
    else
      false
    end
  end
  
  def price_trend(days = 30)
    histories = price_histories.where(recorded_at: days.days.ago..Time.current).order(:recorded_at)
    return :unknown if histories.count < 2
    
    first_price = histories.first.price
    last_price = histories.last.price
    
    if last_price > first_price
      :increasing
    elsif last_price < first_price
      :decreasing
    else
      :stable
    end
  end
  
  def price_change_percentage(days = 30)
    histories = price_histories.where(recorded_at: days.days.ago..Time.current).order(:recorded_at)
    return nil if histories.count < 2
    
    first_price = histories.first.price
    last_price = histories.last.price
    
    ((last_price - first_price) / first_price * 100).round(2)
  end
end
