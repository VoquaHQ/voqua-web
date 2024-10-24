class Vote < ApplicationRecord
  belongs_to :ballot
  belongs_to :profile

  validates :ballot, presence: true
  validates :profile,
    presence: true,
    uniqueness: { scope: :ballot_id }

  validates :data, presence: true
end
