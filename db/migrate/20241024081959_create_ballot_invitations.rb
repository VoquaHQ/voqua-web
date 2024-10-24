class CreateBallotInvitations < ActiveRecord::Migration[7.2]
  def change
    create_table :ballot_invitations do |t|
      t.references :ballot, null: false, foreign_key: true
      t.string :email
      t.string :token, null: false, index: { unique: true }
      t.references :accepted_by, null: true, foreign_key: { to_table: :users }
      t.datetime :accepted_at

      t.timestamps
    end
  end
end
