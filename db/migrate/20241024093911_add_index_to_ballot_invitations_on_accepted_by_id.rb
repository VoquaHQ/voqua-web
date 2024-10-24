class AddIndexToBallotInvitationsOnAcceptedById < ActiveRecord::Migration[7.2]
  def change
    add_index :ballot_invitations, [:ballot_id, :accepted_by_id], unique: true
  end
end
