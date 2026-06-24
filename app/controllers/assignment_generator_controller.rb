# frozen_string_literal: true

class AssignmentGeneratorController < ApplicationController
  include Rosterable

  before_action :initialize_assignment_generator

  def prompt
    authorize! @assignment_generator
  end

  def perform
    @assignment_generator.assign_attributes(assignment_generator_params)
    authorize! @assignment_generator
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
  end

  def assignment_generator_params
    params.expect assignment_generator: [:user_id,
                                         :start_date,
                                         :end_date,
                                         :end_time,
                                         { weekdays: [] }]
  end
end
