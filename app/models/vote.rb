class Vote < ApplicationRecord
  belongs_to :ballot
  belongs_to :profile, optional: true

  validates :ballot, presence: true
  validates :profile,
    presence: true,
    if: -> { !pending? }

  validates :profile,
    uniqueness: { scope: :ballot_id },
    if: -> { !pending? }

  validates :data, presence: true
  validates :pending_email,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    if: -> { pending_email.present? }

  validates :pending_token, presence: true, uniqueness: true, if: -> { pending? }

  after_initialize :generate_pending_token, if: -> { pending? }
  before_save :create_ballor_memebership

  def confirm! main_profile
    update!(profile: main_profile, pending: false, pending_token: nil)
  end

  def profile_user_email
    profile&.user&.email
  end

  private

  def generate_pending_token
    return if pending_token.present?
    self.pending_token = SecureRandom.urlsafe_base64
  end

  def create_ballor_memebership
    return unless profile
    return if BallotMembership.exists?(ballot: ballot, profile: profile)
    BallotMembership.create!(ballot: ballot, profile: profile)
  end
end
