# frozen_string_literal: true

module Assignments
  class WeekdayGeneratorsController < ApplicationController
    before_action :require_admin_in_roster
    before_action :initialize_weekday_generator

    def prompt; end

    def perform
      if @generator.generate
        flash[:message] = t('.success')
        redirect_to roster_assignments_path(@roster, date: @generator.start_date)
      else
        flash.now[:errors] = @generator.errors.full_messages.to_sentence
        render :prompt, status: :unprocessable_entity
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
