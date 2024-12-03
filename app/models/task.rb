class Task < ApplicationRecord
    belongs_to :category
    belongs_to :user

    #enum for xp rewards and how much points will be given
    enum :xp_reward, {easy: 0, medium: 1, hard: 2, difficult: 3}

    #due date
    def due_today?
        due_date == Date.today
    end

    def overdue?
        due_date.present? && due_date < Date.today && !completed?
    end

    def due_soon?(days = 7)
        due_date.present? && due_date <= Date.today + days.days && due_date > Date.today
    end

end
