class Watch < ApplicationRecord
  WATCH_TYPES = %w[search product category].freeze

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :watch_type, presence: true, inclusion: { in: WATCH_TYPES }
  validates :active, inclusion: { in: [ true, false ] }
  validates :exclude_bundles, inclusion: { in: [ true, false ] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_type, ->(type) { where(watch_type: type) }
  scope :ready_for_scraping, -> { active.where("next_scrape_at IS NULL OR next_scrape_at <= ?", Time.current) }
  scope :recently_scraped, -> { where("last_scraped_at > ?", 1.hour.ago) }

  before_create :set_next_scrape_time
  before_update :update_next_scrape_time, if: :saved_change_to_active?

  def display_name
    name.present? ? name : url_domain
  end

  def url_domain
    URI.parse(url).host
  rescue URI::InvalidURIError
    "Invalid URL"
  end

  def omit_terms_array
    return [] if omit_terms.blank?

    omit_terms.split(/[,\n]/).map(&:strip).reject(&:blank?)
  end

  def omit_terms_array=(terms)
    self.omit_terms = Array(terms).map(&:strip).reject(&:blank?).join(", ")
  end

  def needs_scraping?
    active? && (next_scrape_at.nil? || next_scrape_at <= Time.current)
  end

  def time_until_next_scrape
    return 0 if next_scrape_at.nil?

    [ (next_scrape_at - Time.current).to_i, 0 ].max
  end

  def scrape_frequency_hours
    case watch_type
    when "search"
      4 # Search pages change more frequently
    when "product"
      24 # Individual products change less frequently
    when "category"
      6 # Category pages moderate frequency
    else
      12
    end
  end

  def record_scrape_attempt(products_found_count = 0)
    update!(
      last_scraped_at: Time.current,
      products_found: products_found_count,
      scrape_count: scrape_count + 1,
      next_scrape_at: scrape_frequency_hours.hours.from_now
    )
  end

  def scrape_success_rate
    return 0 if scrape_count == 0

    # Simple success rate based on finding products
    successful_scrapes = scrape_count > 0 ? [ products_found, 1 ].min * scrape_count : 0
    (successful_scrapes.to_f / scrape_count * 100).round(1)
  end

  def status
    return "inactive" unless active?
    return "ready" if needs_scraping?
    return "recently_scraped" if last_scraped_at && last_scraped_at > 1.hour.ago

    "scheduled"
  end

  def status_color
    case status
    when "inactive" then "gray"
    when "ready" then "green"
    when "recently_scraped" then "blue"
    when "scheduled" then "yellow"
    else "gray"
    end
  end

  private

  def set_next_scrape_time
    self.next_scrape_at = Time.current if active?
  end

  def update_next_scrape_time
    if active?
      self.next_scrape_at = Time.current
    else
      self.next_scrape_at = nil
    end
  end
end
