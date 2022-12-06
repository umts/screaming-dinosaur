# frozen_string_literal: true

def roster_user(roster)
  create :user, rosters: [roster]
end

def roster_admin(roster = nil)
  if roster.present?
    create(:membership, roster: roster, admin: true).user
  else
    (create :membership, admin: true).user
  end
end
