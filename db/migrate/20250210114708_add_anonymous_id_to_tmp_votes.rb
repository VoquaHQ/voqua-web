class AddAnonymousIdToTmpVotes < ActiveRecord::Migration[7.2]
  def change
    add_column :tmp_votes, :browser_id, :string
    add_index :tmp_votes, :browser_id
  end
end
