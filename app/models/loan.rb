class Loan < ApplicationRecord
  belongs_to :user
  belongs_to :item
  belongs_to :borrower

  validates :lent_on, :due_on, presence: true
  validates :notes, length: { maximum: 1_000 }
  validates :item_id, uniqueness: { conditions: -> { outstanding }, message: "is already out on loan" }, if: :outstanding?
  validate :records_belong_to_same_user
  validate :dates_are_consistent

  scope :outstanding, -> { where(returned_on: nil) }
  scope :returned, -> { where.not(returned_on: nil) }
  scope :overdue, -> { outstanding.where("due_on < ?", Date.current) }
  scope :recent_first, -> { order(lent_on: :desc, id: :desc) }

  def self.search(query)
    return all if query.blank?
    pattern = "%#{sanitize_sql_like(query.strip)}%"
    joins(:item, :borrower).where("items.name LIKE :query ESCAPE '\\' OR borrowers.name LIKE :query ESCAPE '\\'", query: pattern)
  end

  def outstanding? = returned_on.nil?
  def returned? = returned_on.present?
  def overdue? = outstanding? && due_on.present? && due_on < Date.current

  # The lock makes repeated return requests preserve the first recorded return date.
  def return!
    with_lock do
      update!(returned_on: Date.current) if outstanding?
    end
  end

  private
    def records_belong_to_same_user
      errors.add(:item, "must belong to your account") if item && item.user_id != user_id
      errors.add(:borrower, "must belong to your account") if borrower && borrower.user_id != user_id
    end

    def dates_are_consistent
      errors.add(:lent_on, "cannot be in the future") if lent_on && lent_on > Date.current
      errors.add(:due_on, "must be on or after the lending date") if lent_on && due_on && due_on < lent_on
      errors.add(:returned_on, "must be on or after the lending date") if lent_on && returned_on && returned_on < lent_on
      errors.add(:returned_on, "cannot be in the future") if returned_on && returned_on > Date.current
    end
end
