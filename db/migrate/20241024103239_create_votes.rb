class CreateVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :votes do |t|
      t.references :ballot, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.json :data

      t.timestamps
    end
  end
end
