# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    authorize!
    return unless Current.user.rosters.one?

    redirect_to roster_assignments_path(Current.user.rosters.first)
  end
end
