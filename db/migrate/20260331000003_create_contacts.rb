class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.string :phone, null: false
      t.timestamps
    end

    add_index :contacts, :phone, unique: true
  end
end
