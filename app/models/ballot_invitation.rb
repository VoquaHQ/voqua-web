class BallotInvitation < ApplicationRecord
  belongs_to :ballot
  belongs_to :accepted_by, class_name: "User", optional: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :ballot_id }
  validates :accepted_by, uniqueness: { scope: :ballot_id }, if: -> { accepted_by.present? }

  before_save :generate_token

  def accept!(user)
    if accepted_by.present?
      errors.add(:accepted_by, "has already accepted this invitation")
      return false
    end

    if user.email != email
      errors.add(:email, "does not match the user's email")
      return false
    end

    update!(accepted_by: user, accepted_at: Time.current)
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end
end
