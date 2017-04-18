# frozen_string_literal: true
namespace :migrations do
  task rosters: :environment do
    it = Roster.create! name: 'Transit IT'
    User.find_each do |user|
      user.rosters << it
    end
    Assignment.update_all(roster: it)
    # Teh sherson administrates
    User.find_by(last_name: 'Sherson').memberships.first.update admin: true
  end
end
