# frozen_string_literal: true

class AssignmentGeneratorController < ApplicationController
  include Rosterable

  before_action :initialize_assignment_generator

  def prompt
    authorize! @assignment_generator
    @assignment_generator.start_date = @last_end_datetime.to_date
  end

  def perform
    authorize! @assignment_generator
    @assignment_generator.assign_attributes(assignment_generator_params)
    if @assignment_generator.perform
      flash_success_for(Assignment.model_name.human.downcase.pluralize, :create)
      redirect_to roster_path(@assignment_generator.roster, date: @assignment_generator.start_date)
    else
      flash_errors_now_for(@assignment_generator)
      render :prompt, status: :unprocessable_content
    end
  end

  private

  def initialize_assignment_generator
    @assignment_generator = AssignmentGenerator.new(roster_id: roster.id)
    @last_end_datetime = @assignment_generator.roster.assignments.order(end_datetime: :desc).first&.end_datetime
  end

  def assignment_generator_params
    params.expect(
      assignment_generator: [
        :start_date,
        :end_date,
        {
          definitions_attributes: [[
            :end_time,
            :group,
            :overnight,
            { weekdays: [] }
          ]]
        }
      ]
    )
  end
end
