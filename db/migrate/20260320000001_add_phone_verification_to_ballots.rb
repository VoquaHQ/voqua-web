class AddPhoneVerificationToBallots < ActiveRecord::Migration[7.2]
  def change
    add_column :ballots, :phone_verification, :boolean, default: false, null: false
    add_column :ballots, :allowed_country_code, :string
  end
end
