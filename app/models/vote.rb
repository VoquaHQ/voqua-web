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
    presence: true,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    if: -> { pending? }

  validates :pending_token, presence: true, uniqueness: true, if: -> { pending? }

  after_initialize :generate_pending_token, if: -> { pending? }

  def confirm! main_profile
    update!(profile: main_profile, pending: false, pending_token: nil)
    BallotMembership.create!(ballot: ballot, profile: main_profile)
  end

  private

  def generate_pending_token
    return if pending_token.present?
    self.pending_token = SecureRandom.urlsafe_base64
  end
end
