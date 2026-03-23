class AddPhoneVerifiedToVotes < ActiveRecord::Migration[7.2]
  def change
    add_column :votes, :phone_verified, :boolean, default: false, null: false
  end
end
