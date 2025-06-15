class AdminController < ApplicationController
  require_admin

  def index
    render plain: "Admin area"
  end
end
