class AddMembershipIdToBallotInvitations < ActiveRecord::Migration[7.2]
  def change
    add_reference :ballot_invitations, :ballot_membership, null: true, foreign_key: true
  end
end
