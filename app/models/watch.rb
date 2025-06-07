class Watch < ApplicationRecord
  belongs_to :watchable, polymorphic: true, optional: true

  validates :name, presence: true
  validates :url, presence: true, if: -> { watchable.nil? }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, if: -> { url.present? }

  after_create :enqueue_scrape_job, if: :should_auto_scrape?

  scope :active, -> { where(active: true) }
  scope :searches, -> { where(watchable: nil) }
  scope :product_watches, -> { where(watchable_type: "Product") }

  def search_watch?
    watchable.nil?
  end

  def product_watch?
    watchable_type == "Product"
  end

  def watch_type
    return "Search" if search_watch?
    return "Product" if product_watch?
    watchable_type
  end

  def omit_terms
    return [] if omit_list.blank?
    omit_list.split(",").map(&:strip).reject(&:empty?)
  end

  def omit_terms=(terms)
    self.omit_list = Array(terms).join(", ")
  end

  def safe_url
    return nil unless url.present?
    return nil unless url.match?(/\Ahttps?:\/\//)
    url
  end

  private

  def should_auto_scrape?
    active? && search_watch?
  end

  def enqueue_scrape_job
    ScrapeWatchesJob.perform_later
  end
end
