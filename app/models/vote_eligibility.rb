class VoteEligibility < ApplicationRecord
  validates :ballot_id, presence: true
  validates :phone_hash, presence: true
  validates :phone_hash, uniqueness: { scope: :ballot_id }

  def self.already_voted?(ballot_id, phone_hash)
    where(ballot_id: ballot_id, phone_hash: phone_hash).exists?
  end
end
