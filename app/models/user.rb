class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 254 }
  validates :password, length: { minimum: 12, maximum: 72 }, allow_nil: true
  validates :password_confirmation, presence: true, if: -> { password.present? }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
