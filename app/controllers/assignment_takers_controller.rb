# frozen_string_literal: true

class AssignmentTakersController < ApplicationController
  before_action :initialize_taker

  def prompt
    authorize! @taker
  end

  def perform
    @taker.assign_attributes(taker_params)
    authorize! @taker
    @taker.perform!
    flash_success_for(@taker.assignment, :take)
    redirect_to roster_path(@taker.assignment.roster)
  end

  private

  def initialize_taker
    @taker = AssignmentTaker.new(assignment_id: params.expect(:id), user_id: Current.user.id)
  end

  def taker_params
    params.fetch(:assignment_taker, {}).permit(:group)
  end
end
