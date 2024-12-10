class RemoveAcceptedByFromBallotInvitations < ActiveRecord::Migration[7.2]
  def change
    remove_reference :ballot_invitations, :accepted_by, null: true, foreign_key: { to_table: :users }
  end
end
