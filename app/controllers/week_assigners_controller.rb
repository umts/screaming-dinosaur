# frozen_string_literal: true

class WeekAssignersController < ApplicationController
  before_action :initialize_week_assigner

  def prompt
    authorize! context: { roster: @roster }
  end

  def perform
    authorize! context: { roster: @roster }
    if @assigner.generate
      flash[:message] = t('.success')
      redirect_to roster_assignments_path(@roster, date: @assigner.start_date)
    else
      flash.now[:errors] = @assigner.errors.full_messages.to_sentence
      render :prompt, status: :unprocessable_content
    end
  end

  private

  def initialize_week_assigner
    default_start = @roster.next_rotation_start_date
    @assigner = WeekAssigner.new(roster_id: @roster.id,
                                 start_date: default_start,
                                 end_date: default_start + 3.months,
                                 user_ids: @roster.users.active.pluck(:id),
                                 **week_assigner_params)
  end

  def week_assigner_params
    params.fetch(:week_assigner, {})
          .permit(:starting_user_id, :start_date, :end_date, user_ids: [])
  end
end
