class PriceHistory < ApplicationRecord
  belongs_to :product

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :recorded_at, presence: true

  scope :ordered, -> { order(recorded_at: :asc) }
  scope :recent_first, -> { order(recorded_at: :desc) }
  scope :for_product, ->(product) { where(product: product) }
  scope :since, ->(date) { where("recorded_at >= ?", date) }
  scope :between, ->(start_date, end_date) { where(recorded_at: start_date..end_date) }

  def price_change_from_previous
    previous_entry = product.price_histories
                          .where("recorded_at < ?", recorded_at)
                          .order(recorded_at: :desc)
                          .first

    return nil unless previous_entry

    price - previous_entry.price
  end

  def price_change_percentage_from_previous
    change = price_change_from_previous
    return nil unless change

    previous_entry = product.price_histories
                          .where("recorded_at < ?", recorded_at)
                          .order(recorded_at: :desc)
                          .first

    return nil if previous_entry.price.zero?

    (change / previous_entry.price * 100).round(2)
  end
end
