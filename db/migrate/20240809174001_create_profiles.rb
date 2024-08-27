class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.string :handle, null: false
      t.string :name
      t.string :description

      t.timestamps
    end

    add_index :profiles, :handle, unique: true
  end
end
