class AddPendingTokenToVotes < ActiveRecord::Migration[7.2]
  def change
    add_column :votes, :pending_token, :string
    add_index :votes, :pending_token, unique: true
  end
end
