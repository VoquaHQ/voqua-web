class CreateOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :options do |t|
      t.string :title
      t.text :description
      t.references :ballot, null: false, foreign_key: true

      t.timestamps
    end
  end
end
