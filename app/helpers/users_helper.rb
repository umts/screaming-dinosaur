# frozen_string_literal: true

module UsersHelper
  def selected_rosters(user, current_roster)
    user.rosters.present? ? user.rosters.pluck(:id) : [current_roster.id]
  end
end
