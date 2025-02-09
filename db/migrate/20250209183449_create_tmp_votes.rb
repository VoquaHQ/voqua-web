class CreateTmpVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :tmp_votes do |t|
      t.bigint :ballot_id, null: false
      t.string :email, null: false
      t.json :data, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :confirmed_at
      t.string :token, null: false

      t.index [:token], unique: true
    end
  end
end
