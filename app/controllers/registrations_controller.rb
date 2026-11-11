class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action :require_open_registrations
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_url, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Welcome! You have signed up successfully."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @user.errors.add(:email_address, "has already been taken")
    render :new, status: :unprocessable_entity
  end

  private
    def require_open_registrations
      redirect_to new_session_path, alert: "Sign-ups are closed." unless registrations_open?
    end

    def registration_params
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    end
end
