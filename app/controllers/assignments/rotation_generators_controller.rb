# frozen_string_literal: true

module Assignments
  class RotationGeneratorsController < ApplicationController
    before_action :require_admin_in_roster
    before_action :initialize_rotation_generator
    before_action :initialize_form, only: %i[prompt]

    def prompt; end

    def perform
      if @generator.generate
        flash[:message] = t('.success')
        redirect_to roster_assignments_path(@roster, date: @generator.start_date)
      else
        flash.now[:errors] = @generator.errors.full_messages.to_sentence
        @start_date = @generator.start_date
        render :prompt, status: :unprocessable_entity
      end
    end

    private

    def initialize_rotation_generator
      @generator = Assignment::RotationGenerator.new(roster_id: @roster.id, **generate_rotation_params)
    end

    def initialize_form
      @start_date = @generator.start_date
      @users = @roster.users.active.order :last_name
    end

    def generate_rotation_params
      params.fetch(:assignment_rotation_generator, {})
            .permit(:user_ids, :start_user_id, :start_date, :end_date)
    end
  end
end
