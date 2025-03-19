class AddShowBetaToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :beta, :boolean, default: false
  end
end
