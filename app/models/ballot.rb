class Ballot < ApplicationRecord
  belongs_to :profile
  has_many :questions, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :ends_at, presence: true
  validate :ends_at_must_be_in_the_future

  private

  def ends_at_must_be_in_the_future
    if ends_at.present? && ends_at <= Time.current
      errors.add(:ends_at, "must be in the future")
    end
  end
end
