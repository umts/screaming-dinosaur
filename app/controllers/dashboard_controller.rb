# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    authorize!
    rosters = authorized_scope Roster.all
    if rosters.one?
      redirect_to roster_assignments_path(rosters.first)
    else
      redirect_to rosters_path
    end
  end
end
