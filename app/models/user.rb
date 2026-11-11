class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  scope :subscribed_to_price_alerts, -> { where(price_alerts: true) }

  # Signed, expiring-on-change token for one-click unsubscribe links in emails.
  generates_token_for :unsubscribe do
    price_alerts
  end

  # Admin functionality
  def admin?
    admin
  end

  def make_admin!
    update!(admin: true)
  end

  def remove_admin!
    update!(admin: false)
  end
end
