class ChangeHandleToAllowNullInProfiles < ActiveRecord::Migration[7.2]
  def change
    change_column :profiles, :handle, :string, null: true
  end
end
