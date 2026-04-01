class Question < ApplicationRecord
  belongs_to :profile
  has_many :interviews, dependent: :destroy

  before_validation :generate_uuid, on: :create

  validates :uuid, presence: true, uniqueness: true
  validates :body, presence: true
  validates :prompt, presence: true

  def to_param
    uuid
  end

  private

  def generate_uuid
    return if uuid.present?
    self.uuid = SecureRandom.uuid
  end
end
