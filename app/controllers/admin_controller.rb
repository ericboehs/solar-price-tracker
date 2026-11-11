class AdminController < ApplicationController
  require_admin

  # The watches list is the admin home page.
  def index
    redirect_to admin_watches_path
  end
end
