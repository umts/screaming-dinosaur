# frozen_string_literal: true

module Assignments
  class RotationGeneratorsController < ApplicationController
    before_action :require_admin_in_roster
    before_action :initialize_rotation_generator
    before_action :initialize_form, only: :prompt

    def prompt
    end

    def perform
      if @generator.generate
        flash[:message] = t('.success')
        redirect_to roster_assignments_path(@roster, date: @generator.start_date)
      else
        flash.now[:errors] = @generator.errors.full_messages.to_sentence
        initialize_form
        render :prompt, status: :unprocessable_entity
      end
    end

    private

    def initialize_rotation_generator
      @generator = Assignment::RotationGenerator.new(roster_id: @roster.id, **generate_rotation_params)
    end

    def initialize_form
      @start_date = @roster.next_rotation_start_date
      @users = @roster.users.active.order :last_name
    end

    def generate_rotation_params
      params.permit(:start_date, :end_date, :starting_user_id, :user_ids)
    end
  end
end
