class CreateBallots < ActiveRecord::Migration[7.1]
  def change
    create_table :ballots do |t|
      t.string :name
      t.string :description
      t.datetime :ends_at
      t.references :profile, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
