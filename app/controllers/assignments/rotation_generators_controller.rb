# frozen_string_literal: true

module Assignments
  class RotationGeneratorsController < ApplicationController
    before_action :initialize_rotation_generator

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

    def initialize_rotation_generator
      default_start = @roster.next_rotation_start_date
      @generator = Assignment::RotationGenerator.new(roster_id: @roster.id,
                                                     start_date: default_start,
                                                     end_date: default_start + 3.months,
                                                     user_ids: @roster.users.pluck(:id),
                                                     **generate_rotation_params)
    end

    def generate_rotation_params
      params.fetch(:assignment_rotation_generator, {})
            .permit(:starting_user_id, :start_date, :end_date, user_ids: [])
    end
  end
end
