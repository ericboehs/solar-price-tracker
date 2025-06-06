class PriceHistory < ApplicationRecord
  belongs_to :product
  
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :recorded_at, presence: true
  
  scope :recent, -> { order(recorded_at: :desc) }
  scope :for_date_range, ->(start_date, end_date) { where(recorded_at: start_date..end_date) }
  
  before_validation :set_recorded_at, on: :create
  
  private
  
  def set_recorded_at
    self.recorded_at ||= Time.current
  end
end
