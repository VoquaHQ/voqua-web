class RemoveAcceptedByFromBallotInvitations < ActiveRecord::Migration[7.2]
  def change
    remove_index :ballot_invitations, [:ballot_id, :accepted_by_id]
    remove_reference :ballot_invitations, :accepted_by, null: true, foreign_key: { to_table: :users }
  end
end
