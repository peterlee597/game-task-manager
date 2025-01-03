class HomepageController < ApplicationController
  def index
    if user_signed_in?
      @tasks = current_user.tasks
      @goals = current_user.goals
      @user_level = current_user.level
    else
      # You can handle the case where no user is signed in
      @tasks = []
      @goals = []
      @user_level = nil
    end
  end

  def show
  end

  private
  def calculate_xp_progress(level)
    # Get the XP required for the next level using the level's method
    xp_needed_for_next_level = level.xp_needed_for_level
    current_xp = level.xp

    # Calculate the percentage of progress towards the next level
    xp_progress = [ (current_xp.to_f / xp_needed_for_next_level.to_f) * 100, 100 ].min

    xp_progress
  end
end
