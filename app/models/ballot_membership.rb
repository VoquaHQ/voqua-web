class BallotMembership < ActiveRecord::Base
  belongs_to :ballot
  belongs_to :profile

  validates :ballot, presence: true
  validates :profile, presence: true
  validates :profile_id, uniqueness: { scope: :ballot_id, message: "has already been added to this ballot" }
end
