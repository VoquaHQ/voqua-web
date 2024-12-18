class AddIndexOnEmailToInvitations < ActiveRecord::Migration[7.2]
  def change
    add_index :ballot_invitations, [:email, :accepted_at], where: "accepted_at IS NULL"
  end
end
