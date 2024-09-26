class Ballot < ApplicationRecord
  belongs_to :user
  has_many :options, dependent: :destroy
  has_many :votes, through: :options

  validates :title, presence: true
  validates :description, presence: true
  validates :deadline, presence: true

  validate :deadline_in_future, on: :create

  private

  def deadline_in_future
    if deadline.present? && deadline <= Time.current
      errors.add(:deadline, "must be in the future")
    end
  end
end
