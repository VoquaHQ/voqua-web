class CreateQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :questions do |t|
      t.string :title
      t.string :description
      t.references :ballot, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
