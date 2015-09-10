class AssignmentsController < ApplicationController
  def index
    @date = if params[:date].present?
              Date.parse params[:date]
            else Date.today.beginning_of_week :sunday
            end
    @week = @date..(@date + 6.days)
  end
end
