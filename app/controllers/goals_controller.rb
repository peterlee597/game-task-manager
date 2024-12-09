class GoalsController < ApplicationController
    before_action :set_goal, only: [:show, :edit, :update, :destroy]
  
    def index
      @goals = current_user.goals  
    end
  
    def show
    end
  
    def new
      @goal = current_user.goals.build  
    end
  
    def create
      @goal = current_user.goals.build(goal_params)
  
      if @goal.save
        redirect_to @goal, notice: "Goal was successfully created."
      else
        render :new
      end
    end
  
    def edit
    end
  
    def update
      if @goal.update(goal_params)
        redirect_to @goal, notice: "Goal was successfully updated."
      else
        render :edit
      end
    end
  
    def destroy
      @goal.destroy
      redirect_to goals_url, notice: "Goal was successfully destroyed."
    end
  
    private
  
    def set_goal
      @goal = current_user.goals.find(params[:id])  # Ensure goal belongs to the current user
    end
  
    def goal_params
      params.require(:goal).permit(:title, :description)
    end
  end
  