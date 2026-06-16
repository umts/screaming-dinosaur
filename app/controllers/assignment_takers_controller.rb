# frozen_string_literal: true

class AssignmentTakersController < ApplicationController
  before_action :build_taker

  def prompt
    authorize! @taker
  end

  def perform
    @taker.assign_attributes(taker_params)
    authorize! @taker
    if @taker.perform
      flash_success_for(@taker.assignment, :take)
      redirect_to roster_path(@taker.assignment.roster)
    else
      flash_errors_now_for(@taker)
      render :prompt, status: :unprocessable_content
    end
  end

  private

  def build_taker
    @taker = AssignmentTaker.new(assignment_id: params.expect(:id), user_id: Current.user&.id)
  end

  def taker_params
    params.fetch(:assignment_taker, {}).permit(:whole_group)
  end
end
