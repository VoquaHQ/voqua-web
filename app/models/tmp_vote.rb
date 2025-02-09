class TmpVote < ApplicationRecord
  belongs_to :ballot
  validates :ballot, presence: true
  validates :email, presence: true
  validates :data, presence: true
  validates :token, presence: true

  after_initialize :generate_token

  private

  def generate_token
    return if token.present?
    self.token = SecureRandom.urlsafe_base64
  end
end
