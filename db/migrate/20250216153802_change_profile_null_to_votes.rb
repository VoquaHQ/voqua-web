class ChangeProfileNullToVotes < ActiveRecord::Migration[7.2]
  def change
    change_column_null :votes, :profile_id, true
  end
end
