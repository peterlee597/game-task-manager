class AddStartAndEndTimeToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :start_time, :datetime
    add_column :tasks, :end_time, :datetime
  end
end
