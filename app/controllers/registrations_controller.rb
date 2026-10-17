class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 5, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again in a few minutes." }

  def new
    redirect_to root_path if authenticated?
    @user = User.new
  end

  def create
    @user = User.new(params.expect(user: [ :email_address, :password, :password_confirmation ]))
    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome to Backsoon. Make yourself at home.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @user.errors.add(:email_address, "has already been taken")
    render :new, status: :unprocessable_entity
  end
end
