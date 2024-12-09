class AddTokenExpiryTimeToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :token_expiry_time, :datetime
  end
end
