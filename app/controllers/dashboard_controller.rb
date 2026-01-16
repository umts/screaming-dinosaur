# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    authorize!
    if Current.user.rosters.one?
      redirect_to roster_assignments_path
    else
      redirect_to rosters_path
    end
  end
end
