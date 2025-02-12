class AddSlugToBallots < ActiveRecord::Migration[7.2]
  def up
    add_column :ballots, :slug, :string
    
    # Generate slugs for existing ballots
    Ballot.find_each do |ballot|
      ballot.update_column(:slug, SecureRandom.urlsafe_base64(12))
    end
    
    # Add null constraint after generating slugs
    change_column_null :ballots, :slug, false
    add_index :ballots, :slug, unique: true
  end

  def down
    remove_index :ballots, :slug
    remove_column :ballots, :slug
  end
end
