class AddRememberTokenToUser < ActiveRecord::Migration[7.2]
  def change
    change_table :users do |t|
      t.string :remember_token, limit: 20
    end
  end
end
