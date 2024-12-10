class BallotInvitation < ApplicationRecord
  belongs_to :ballot
  belongs_to :ballot_membership, class_name: "BallotMembership", optional: true, dependent: :destroy

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :ballot_id }
  validates :ballot_membership, uniqueness: { scope: :ballot_id }, if: -> { ballot_membership.present? }

  before_save :generate_token

  #FIXME: Destroy votes when invitation and membership are destroyed?

  def accept!(profile)
    if ballot_membership.present?
      errors.add(:ballot_membership, "has already accepted this invitation")
      return false
    end

    # if user.email != email
    #   errors.add(:email, "does not match the user's email")
    #   return false
    # end

    self.ballot_membership = BallotMembership.create!(ballot: ballot, profile: profile)
    self.accepted_at = Time.current
    save!
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end
end
