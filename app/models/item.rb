class Item < ApplicationRecord
  belongs_to :user
  has_many :loans, dependent: :restrict_with_error
  has_one :outstanding_loan, -> { outstanding }, class_name: "Loan"

  normalizes :name, with: ->(name) { name.strip }
  validates :name, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 1_000 }

  scope :alphabetical, -> { order(:name, :id) }
  scope :available, -> { where.not(id: Loan.outstanding.select(:item_id)) }
end
