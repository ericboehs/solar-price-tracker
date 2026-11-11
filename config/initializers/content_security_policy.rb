# Be sure to restart your server when you modify this file.

# Strict Content Security Policy: everything is served from this app except
# product images (SignatureSolar's BigCommerce CDN). No inline scripts or
# styles; importmap/Turbo tags get a per-request nonce automatically.
# See https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :none
    policy.base_uri    :self
    policy.connect_src :self
    policy.font_src    :self, :data
    policy.form_action :self
    policy.frame_ancestors :none
    policy.img_src :self, :data, "https://cdn11.bigcommerce.com", "https://signaturesolar.com"
    policy.manifest_src :self
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self

    # Dev tools (web-console, hotwire-spark live reload) need a websocket.
    policy.connect_src :self, "ws://localhost:*", "ws://127.0.0.1:*" if Rails.env.development?
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
  config.content_security_policy_nonce_auto = true
end
