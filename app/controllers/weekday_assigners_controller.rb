# frozen_string_literal: true

class WeekdayAssignersController < ApplicationController
  before_action :initialize_weekday_assigner

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

  def initialize_weekday_assigner
    @assigner = WeekdayAssigner.new(roster_id: @roster.id, **generate_by_weekday_params)
  end

  def generate_by_weekday_params
    params.fetch(:weekday_assigner, {})
          .permit(:user_id, :start_date, :end_date, :start_weekday, :end_weekday)
  end
end
