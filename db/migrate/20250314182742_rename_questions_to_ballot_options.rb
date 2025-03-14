class RenameQuestionsToBallotOptions < ActiveRecord::Migration[7.2]
  def change
    rename_table :questions, :ballot_options
  end
end
