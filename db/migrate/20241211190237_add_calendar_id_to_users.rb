class AddCalendarIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :calendar_id, :string
  end
end
