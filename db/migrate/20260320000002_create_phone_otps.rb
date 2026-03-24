class CreatePhoneOtps < ActiveRecord::Migration[7.2]
  def change
    create_table :phone_otps do |t|
      t.integer  :ballot_id,           null: false
      t.string   :phone_hash,          null: false
      t.string   :code_digest,         null: false
      t.datetime :expires_at,          null: false
      t.integer  :attempts,            null: false, default: 0
      t.timestamps
    end
    add_index :phone_otps, :ballot_id
    add_index :phone_otps, [:ballot_id, :phone_hash]
  end
end
