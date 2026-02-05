# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    authorize!
    if Current.user.rosters.one?
      redirect_to roster_path(Current.user.rosters.first)
    else
      redirect_to rosters_path
    end
  end
end
