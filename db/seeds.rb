# frozen_string_literal: true

exit unless Rails.env.development?

# ROTATIONS
transit_it = FactoryBot.create :roster, name: 'Transit IT', created_at: Time.current.beginning_of_week(:friday)
ops = FactoryBot.create :roster, name: 'Transit Operations',
                                 created_at: Time.current.beginning_of_week(:friday).change(hour: 4, min: 30)

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

admins = {
  transit_it => %w[Sherson],
  ops => %w[Barrington Noble]
}

names.each_pair do |roster, rot_names|
  rot_names.each do |first_name, last_name|
    user = User.find_by(first_name: first_name, last_name: last_name) ||
           FactoryBot.create(:user, first_name: first_name, last_name: last_name)
    FactoryBot.create :membership, roster: roster, user: user,
                                   admin: admins[roster].include?(last_name)
  end
end

# ADMINS
User.find_by(last_name: 'Sherson').update admin: true

# ASSIGNMENTS
transit_it.users.order(:last_name).each_with_index do |user, i|
  FactoryBot.create :assignment, user: user, roster: transit_it,
                                 end_datetime: (i + 1).weeks.since.beginning_of_week(:friday)
end

ops.users.order(:last_name).cycle.take(70).each_with_index do |user, i|
  FactoryBot.create :assignment, user: user, roster: ops,
                                 end_datetime: ops.created_at + ((i + 1) * 12).hours
end
