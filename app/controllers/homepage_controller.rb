class HomepageController < ApplicationController
  def index
    @tasks = current_user.tasks
    @goals = current_user.goals
  end
  
  def show 
  end 

end
