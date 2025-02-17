class SaveVoteToCreateBallotMemberships < ActiveRecord::Migration[7.2]
  def change
    Vote.all.each do |vote|
      vote.save
    end
  end
end
