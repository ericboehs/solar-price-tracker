class Product < ApplicationRecord
  has_many :price_histories, dependent: :destroy

  validates :title, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :slug, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  before_validation :generate_slug_from_url, if: -> { url.present? && slug.blank? }

  scope :recently_scraped, -> { where("last_scraped_at > ?", 24.hours.ago) }
  scope :needs_scraping, -> { where(last_scraped_at: nil).or(where("last_scraped_at < ?", 24.hours.ago)) }

  def display_price
    "$#{'%.2f' % price}"
  end

  def scraped_recently?
    last_scraped_at.present? && last_scraped_at > 24.hours.ago
  end

  def latest_price_history
    price_histories.recent_first.first
  end

  def price_trend_30_days
    return nil unless price_histories.count >= 2

    thirty_days_ago = 30.days.ago
    oldest_in_period = price_histories.since(thirty_days_ago).ordered.first
    latest = latest_price_history

    return nil unless oldest_in_period && latest && oldest_in_period != latest

    price_change = latest.price - oldest_in_period.price
    percentage_change = (price_change / oldest_in_period.price * 100).round(2)

    {
      change: price_change,
      percentage: percentage_change,
      direction: price_change > 0 ? :up : :down
    }
  end

  def historical_low_price
    price_histories.minimum(:price) || price
  end

  def at_historical_low?
    current_price = latest_price_history&.price || price
    (current_price - historical_low_price).abs < 0.01
  end

  def record_price_change(new_price, recorded_at = Time.current)
    # Only record if price changed by more than $0.01
    latest = latest_price_history

    if latest
      # Compare against the latest price history, round to avoid floating point issues
      price_diff = (new_price - latest.price).abs.round(2)
      return false if price_diff <= 0.01
    end

    price_histories.create!(
      price: new_price,
      recorded_at: recorded_at
    )
  end

  private

  def generate_slug_from_url
    return unless url.present?

    # Extract product slug from SignatureSolar URL
    # Example: https://signaturesolar.com/eg4-lifepower4-lithium-battery-48v-100ah/
    uri = URI.parse(url)
    path_segments = uri.path.split("/").reject(&:blank?)
    self.slug = path_segments.last if path_segments.any?
  rescue URI::InvalidURIError, ArgumentError
    # Leave slug blank if URL can't be parsed
    nil
  end
end
