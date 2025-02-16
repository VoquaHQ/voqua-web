class AddPendingToVotes < ActiveRecord::Migration[7.2]
  def change
    add_column :votes, :pending, :boolean, default: false
  end
end
