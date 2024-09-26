class Option < ApplicationRecord
  belongs_to :ballot
  has_many :votes, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true

  def total_votes
    votes_in_favor - votes_against
  end

  def votes_in_favor
    votes.where(in_favor: true).sum { |vote| Math.sqrt(vote.credits) }
  end

  def votes_against
    votes.where(in_favor: false).sum { |vote| Math.sqrt(vote.credits) }
  end

  def vote_percentage
    total = ballot.options.sum { |option| option.total_votes.abs }
    total > 0 ? (total_votes.abs / total * 100).round(2) : 0
  end
end
