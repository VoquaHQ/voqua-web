class Ballot < ApplicationRecord
  belongs_to :profile

  has_many :options, class_name: "BallotOption", dependent: :destroy
  has_many :invitations, class_name: "BallotInvitation", dependent: :destroy
  has_many :memberships, class_name: "BallotMembership", dependent: :destroy

  before_validation :generate_slug, on: :create
  has_many :votes, dependent: :destroy
  has_many :tmp_votes, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :ends_at, presence: true
  validates :allowed_country_code, presence: true, if: :phone_verification?
  validate :ends_at_must_be_in_future
  validate :phone_verification_and_private_are_exclusive

  def phone_verification_and_private_are_exclusive
    if phone_verification? && private?
      errors.add(:phone_verification, "cannot be enabled on private ballots")
    end
  end
  before_validation :adjust_ends_at_time

  def member?(user)
    memberships.exists?(profile_id: user.main_profile.id)
  end

  def voted?(user)
    votes.exists?(profile_id: user.main_profile.id)
  end

  def phone_restricted?
    phone_verification?
  end

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?
    self.slug = SecureRandom.urlsafe_base64(12)
  end

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
