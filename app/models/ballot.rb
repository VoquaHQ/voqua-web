class Ballot < ApplicationRecord
  belongs_to :profile
  has_many :questions, dependent: :destroy
  has_many :invitations, class_name: "BallotInvitation", dependent: :destroy
  has_many :members, through: :invitations, source: :accepted_by

  validates :name, presence: true
  validates :description, presence: true
  validates :ends_at, presence: true
  validate :ends_at_must_be_in_the_future

  def invited?(user)
    profile.user_profiles.exists?(user: user) ||
      invitations.exists?(accepted_by: user)
  end

  private

  def ends_at_must_be_in_the_future
    if ends_at.present? && ends_at <= Time.current
      errors.add(:ends_at, "must be in the future")
    end
  end
end
