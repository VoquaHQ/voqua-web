class AddPendingEmailToVotes < ActiveRecord::Migration[7.2]
  def change
    add_column :votes, :pending_email, :string
  end
end
