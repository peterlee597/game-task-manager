class Task < ApplicationRecord
    belongs_to :category
    belongs_to :user
  
    # Enum for xp rewards and their associated values
    enum xp_reward: { easy: 10, medium: 20, hard: 40, difficult: 80 }, _default: :easy
  
    # Method to mark the task as completed and award XP
    def complete
        Rails.logger.debug "Completing Task #{@id}. Awarding XP: #{xp_reward_value}"
      
        # Award XP to the user's level
        user.level.add_xp(xp_reward_value)
      
        # Mark the task as completed
        update(completed: true)
      end
  
    # Method to get the integer value for the xp_reward enum
    def xp_reward_value
        case xp_reward
        when "easy"
          10
        when "medium"
          20
        when "hard"
          40
        when "difficult"
          80
        else
          0
        end
      end
    # Method to check if the task is due today
    def due_today?
      due_date == Date.today
    end
  
    # Method to check if the task is overdue
    def overdue?
      due_date.present? && due_date < Date.today && !completed?
    end
  
    # Method to check if the task is due soon (within a certain number of days)
    def due_soon?(days = 7)
      due_date.present? && due_date <= Date.today + days.days && due_date > Date.today
    end
  end