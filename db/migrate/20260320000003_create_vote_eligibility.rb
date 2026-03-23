class CreateVoteEligibility < ActiveRecord::Migration[7.2]
  def change
    create_table :vote_eligibilities do |t|
      t.integer  :ballot_id,  null: false
      t.string   :phone_hash, null: false
      t.datetime :created_at, null: false
    end
    add_index :vote_eligibilities, [:ballot_id, :phone_hash], unique: true
  end
end
