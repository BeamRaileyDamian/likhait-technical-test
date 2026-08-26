class Expense < ApplicationRecord
  belongs_to :category

  validates :date, presence: true
  validate :date_not_in_future

  private

  def date_not_in_future
    return if date.blank?

    if date > Date.current
      errors.add(:date, "can't be in the future")
    end
  end
end
