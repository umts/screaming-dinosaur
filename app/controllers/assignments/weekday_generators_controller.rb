# frozen_string_literal: true

module Assignments
  class WeekdayGeneratorsController < ApplicationController
    before_action :initialize_weekday_generator

    def prompt
      authorize! context: { roster: @roster }
    end

    def perform
      authorize! context: { roster: @roster }
      if @generator.generate
        flash_success_for(Assignment.model_name.human.downcase.pluralize, :create)
        redirect_to roster_assignments_path(@roster, date: @generator.start_date)
      else
        flash_errors_now_for(@generator)
        render :prompt, status: :unprocessable_content
      end
    end

    private

    def initialize_weekday_generator
      @generator = Assignment::WeekdayGenerator.new(roster_id: @roster.id, **generate_by_weekday_params)
    end

    def generate_by_weekday_params
      params.fetch(:assignment_weekday_generator, {})
            .permit(:user_id, :start_date, :end_date, :start_weekday, :end_weekday)
    end
  end
end
