class TmpVote < ApplicationRecord
  belongs_to :ballot
  validates :ballot, presence: true
  validates :email, presence: true, format: {
    with: /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/,
    message: "must be a valid email address"
  }
  validates :data, presence: true
  validates :token, presence: true

  after_initialize :generate_token

  private

  def generate_token
    return if token.present?
    self.token = SecureRandom.urlsafe_base64
  end
end
