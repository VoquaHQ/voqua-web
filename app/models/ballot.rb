class Ballot < ApplicationRecord
  belongs_to :profile

  has_many :questions, dependent: :destroy
  has_many :invitations, class_name: "BallotInvitation", dependent: :destroy
  has_many :memberships, class_name: "BallotMembership", dependent: :destroy

  has_many :members, through: :invitations, source: :accepted_by
  has_many :votes, dependent: :destroy
  has_many :tmp_votes, dependent: :destroy

  validates :name, presence: true
  validates :ends_at, presence: true
  validate :ends_at_must_be_in_future
  before_validation :adjust_ends_at_time

  def member?(user)
    memberships.exists?(profile_id: user.main_profile.id)
  end

  private

  def ends_at_must_be_in_future
    return unless ends_at.present?

    if ends_at.to_i <= Time.current.to_i
      errors.add(:ends_at, "must be in the future")
    end
  end

  def adjust_ends_at_time
    return unless ends_at.present?

    # Ensure we have minutes precision
    self.ends_at = ends_at.change(sec: 0)
  end
end
