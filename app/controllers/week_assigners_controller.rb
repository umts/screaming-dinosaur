# frozen_string_literal: true

class WeekAssignersController < ApplicationController
  include Rosterable

  before_action :initialize_week_assigner

  def prompt
    authorize! @assigner
  end

  def perform
    @assigner.assign_attributes(week_assigner_params)
    authorize! @assigner
    if @assigner.perform
      flash_success_for(Assignment.model_name.human.downcase.pluralize, :create)
      redirect_to roster_path(@assigner.roster, date: @assigner.start_date)
    else
      flash_errors_now_for(@assigner)
      render :prompt, status: :unprocessable_content
    end
  end

  private

  def initialize_week_assigner
    default_start = roster.next_rotation_start_date
    @assigner = WeekAssigner.new(roster_id: roster.id,
                                 start_date: default_start,
                                 end_date: default_start + 3.months,
                                 user_ids: roster.users.active.pluck(:id))
  end

  def week_assigner_params
    params.expect week_assigner: [:starting_user_id, :start_date, :end_date, { user_ids: [] }]
  end
end
