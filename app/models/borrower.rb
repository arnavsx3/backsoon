class Borrower < ApplicationRecord
  belongs_to :user
  has_many :loans, dependent: :restrict_with_error

  normalizes :name, with: ->(name) { name.strip }
  normalizes :email, with: ->(email) { email.strip.downcase.presence }
  validates :name, presence: true, length: { maximum: 80 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 254 }, allow_blank: true
  validates :notes, length: { maximum: 1_000 }

  scope :alphabetical, -> { order(:name, :id) }
end
