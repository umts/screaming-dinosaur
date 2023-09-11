# frozen_string_literal: true

namespace :rosters do
  desc 'Populate roster slugs'
  task slug: :environment do
    Roster.find_each(&:save!)
  end
end
