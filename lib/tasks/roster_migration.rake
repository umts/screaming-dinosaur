# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
namespace :migrations do
  task rosters: :environment do
    it = Roster.create! name: 'Transit IT'
    User.find_each do |user|
      user.rosters << it
    end
    Assignment.update_all(roster_id: it.id)
    # Teh sherson administrates
    User.find_by(last_name: 'Sherson').memberships.first.update admin: true
  end
end
