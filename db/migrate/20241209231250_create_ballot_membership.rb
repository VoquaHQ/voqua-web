class CreateBallotMembership < ActiveRecord::Migration[7.2]
  def change
    create_table :ballot_memberships do |t|
      t.references :ballot, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.timestamps
    end

    add_index :ballot_memberships, [:ballot_id, :profile_id], unique: true
  end
end
