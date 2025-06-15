class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  allow_unauthenticated_access only: [ :root ]

  def root
    if authenticated?
      redirect_to products_path
    else
      redirect_to controller: :welcome, action: :index
    end
  end
end
