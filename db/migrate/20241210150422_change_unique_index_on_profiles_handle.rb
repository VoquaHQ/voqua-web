class ChangeUniqueIndexOnProfilesHandle < ActiveRecord::Migration[7.2]
  def change
    remove_index :profiles, :handle

    add_index :profiles, :handle, unique: true, where: "handle IS NOT NULL"
  end

end
