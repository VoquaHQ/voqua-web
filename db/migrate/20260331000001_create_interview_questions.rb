class CreateInterviewQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :questions do |t|
      t.integer :profile_id, null: false
      t.string :uuid, null: false
      t.text :body, null: false
      t.text :prompt, null: false
      t.timestamps
    end

    add_index :questions, :profile_id
    add_index :questions, :uuid, unique: true
    add_foreign_key :questions, :profiles
  end
end
