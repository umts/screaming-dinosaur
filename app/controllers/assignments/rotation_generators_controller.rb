# frozen_string_literal: true

module Assignments
  class RotationGeneratorsController < ApplicationController
    before_action :require_admin_in_roster
    before_action :initialize_rotation_generator
    before_action :initialize_form

    def prompt
    end

    def perform
      if @generator.generate
        flash[:message] = t('.success')
        redirect_to roster_assignments_path(@roster, date: @generator.start_date)
      else
        flash.now[:errors] = @generator.errors.full_messages.to_sentence
        @generator.end_date = @generator.start_date + 3.months
        render :prompt, status: :unprocessable_entity
      end
    end

    private

    def initialize_rotation_generator
      @generator = Assignment::RotationGenerator.new(roster_id: @roster.id, **generate_rotation_params)
      @generator.start_date ||= @roster.next_rotation_start_date
      @generator.end_date ||= @generator.start_date + 3.months
    end

    def initialize_form
      @users = @roster.users.active.order :last_name
    end

    def generate_rotation_params
      params.fetch(:assignment_rotation_generator, {}).permit!
    end
  end
end
