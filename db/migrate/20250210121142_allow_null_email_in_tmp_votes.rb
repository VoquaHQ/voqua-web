class AllowNullEmailInTmpVotes < ActiveRecord::Migration[7.2]
  def up
    change_column_null :tmp_votes, :email, true
  end

  def down
    change_column_null :tmp_votes, :email, false
  end
end
