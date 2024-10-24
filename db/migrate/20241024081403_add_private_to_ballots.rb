class AddPrivateToBallots < ActiveRecord::Migration[7.2]
  def change
    add_column :ballots, :private, :boolean, default: false
  end
end
