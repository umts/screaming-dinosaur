# frozen_string_literal: true

exit unless Rails.env.development?

# ROTATIONS
transit_it = FactoryBot.create :roster, name: 'Transit IT', created_at: Time.current.beginning_of_week(:friday)
ops = FactoryBot.create :roster, name: 'Transit Operations', created_at: Time.current.beginning_of_week(:friday)

# USERS
names = {
  transit_it => [
    %w[Karin Eichelman],
    %w[David Faulkenberry],
    %w[Matt Moretti],
    %w[Adam Sherson],
    %w[Metin Yavuz]
  ],
  ops => [
    %w[Glenn Barrington],
    %w[Bridgette Bauer],
    %w[Andrew Cathcart],
    %w[Don Chapman],
    %w[Karin Eichelman],
    %w[David Faulkenberry],
    %w[Graham Fortier-Dubé],
    %w[Tabitha Golz],
    %w[Jonathan McHatton],
    %w[Matt Moretti],
    %w[Diana Noble],
    %w[Derek Pires],
    %w[Evan Rife],
    %w[Nathan Santana],
    %w[Adam Sherson],
    ['Daren', 'Two Feathers']
  ]
}

names.each_pair do |roster, rot_names|
  rot_names.each do |first_name, last_name|
    user = User.find_by first_name: first_name, last_name: last_name
    if user.present?
      user.rosters << roster
      user.save!
    else
      FactoryBot.create :user, first_name: first_name,
                               last_name: last_name, rosters: [roster]
    end
  end
end

# ADMINS
ops.memberships.joins(:user).where(users: { last_name: %w[Barrington Noble] })
   .update_all admin: true # rubocop:disable Rails/SkipsModelValidations
transit_it.memberships.joins(:user).where(users: { last_name: 'Sherson' })
          .update_all admin: true # rubocop:disable Rails/SkipsModelValidations
User.find_by(last_name: 'Sherson').update(admin: true)

# ASSIGNMENTS
unless ENV['SKIP_ASSIGNMENTS']
  Roster.find_each do |roster|
    roster.users.order(:last_name).each_with_index do |user, i|
      FactoryBot.create :assignment, user: user, roster: roster,
                                     end_datetime: (i + 1).weeks.since.beginning_of_week(:friday)
    end
  end
end
