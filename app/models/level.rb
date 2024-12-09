class Level < ApplicationRecord
  belongs_to :user

  # Set default values for new levels
  after_initialize :set_default_values, if: :new_record?

  def set_default_values
    self.xp ||= 0   # Default XP to 0
    self.level ||= 1  # Default level to 1
  end

  # Add XP to the user's level and check if they should level up
  def add_xp(amount)
    self.xp += amount
    level_up if xp >= xp_needed_for_level
    self.save # Make sure the level record is saved after adding XP
  end

  # Check if the user should level up based on the XP threshold
  def level_up
    # Only level up if the current level is less than 3 (as per your original code)
    if level < 3
      self.level += 1
    end
  end

  # Calculate the XP needed to level up to the next level
  def xp_needed_for_level
    case level
    when 1 then 100  # XP needed to level up to level 2
    when 2 then 250  # XP needed to level up to level 3
    else 0           # No further levels after level 3
    end
  end
end
