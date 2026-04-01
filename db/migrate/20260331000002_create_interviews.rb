class CreateInterviews < ActiveRecord::Migration[7.2]
  def change
    create_table :interviews do |t|
      t.integer :question_id, null: false
      t.text :first_answer
      t.text :follow_up_question
      t.text :follow_up_answer
      t.timestamps
    end

    add_index :interviews, :question_id
    add_foreign_key :interviews, :questions
  end
end
