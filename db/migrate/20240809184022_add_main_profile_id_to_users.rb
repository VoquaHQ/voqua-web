class AddMainProfileIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :main_profile_id, :bigint, null: false
    add_foreign_key :users, :profiles, column: :main_profile_id
    add_index :users, :main_profile_id, unique: true
  end
end
