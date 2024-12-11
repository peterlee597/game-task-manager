class AssignLevelsToExistingUsers < ActiveRecord::Migration[6.0]
  def up
    User.find_each do |user|
      unless user.level
        # Directly create a Level record associated with the user
        Level.create(user_id: user.id, xp: 0, level: 1)
      end
    end
  end

  def down
    User.find_each do |user|
      user.level.destroy if user.level
    end
  end
end
