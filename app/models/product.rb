class Product < ApplicationRecord
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
