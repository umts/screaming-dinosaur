# frozen_string_literal: true

class WeekdayAssignersController < ApplicationController
  skip_before_action :set_roster
  before_action :initialize_weekday_assigner

  def prompt
    authorize! @assigner
  end

  def perform
    @assigner.assign_attributes(weekday_assigner_params)
    authorize! @assigner
    if @assigner.perform
      flash_success_for(Assignment.model_name.human.downcase.pluralize, :create)
      redirect_to roster_assignments_path(@assigner.roster, date: @assigner.start_date)
    else
      flash_errors_now_for(@assigner)
      render :prompt, status: :unprocessable_content
    end
  end

  private

  def initialize_weekday_assigner
    roster = Roster.friendly.find(params[:roster_id])
    @assigner = WeekdayAssigner.new(roster_id: roster.id)
  end

  def weekday_assigner_params
    params.expect(weekday_assigner: %i[user_id start_date end_date start_weekday end_weekday])
  end
end
