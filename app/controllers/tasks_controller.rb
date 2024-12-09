class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy complete]

  def index
    @tasks = current_user.tasks
  end

  def show
  end

  def new
    @task = current_user.tasks.build
    @categories = Category.all
  end

  def edit
    @task = current_user.tasks.find(params[:id])
    @categories = Category.all
  end

  def create
    @task = current_user.tasks.new(task_params)

    # Ensure start_time and end_time are set, either from the form or with defaults
    if @task.start_time.nil?
      @task.start_time = @task.due_date.beginning_of_day  # Default to beginning of due date
    end

    if @task.end_time.nil?
      @task.end_time = @task.due_date.end_of_day  # Default to end of due date
    end

    respond_to do |format|
      if @task.save        
         # Create Google Calendar event
        google_calendar_service = GoogleCalendarService.new(current_user)
        google_calendar_service.create_event(@task)

        format.html { redirect_to @task, notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        @categories = Category.all
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @task = current_user.tasks.find(params[:id])

    # Log the xp_reward before proceeding
    Rails.logger.debug "XP Reward from form: #{params[:task][:xp_reward]}"

    # Log the task's current state before update
    Rails.logger.debug "Before Update: Task completed = #{@task.completed}"

    if params[:task][:completed] == 'true' && !@task.completed
      Rails.logger.debug "Task #{@task.id} is being marked as completed."
      @task.complete
    end

    if @task.update(task_params)
      Rails.logger.debug "Task #{@task.id} updated successfully."
      redirect_to tasks_path, notice: 'Task was successfully updated.'
    else
      Rails.logger.debug "Task #{@task.id} failed to update."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy!

    respond_to do |format|
      format.html { redirect_to tasks_path, status: :see_other, notice: "Task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Mark task as completed and award XP
  def complete
    Rails.logger.debug "XP Reward: #{@task.xp_reward}, XP Value: #{@task.xp_reward_value}"

    if @task.user && @task.xp_reward_value > 0
      Rails.logger.debug "Adding XP: #{@task.xp_reward_value} to user: #{@task.user.id}, current level: #{@task.user.level.level}, current XP: #{@task.user.level.xp}"

      @task.user.level.add_xp(@task.xp_reward_value)

      Rails.logger.debug "New level: #{@task.user.level.level}, new XP: #{@task.user.level.xp}"
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:name, :description, :due_date, :xp_reward, :category_id, :user_id, :completed, :start_time, :end_time)
  end
end
