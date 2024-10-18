exit unless Rails.env.development?

# ROTATIONS
it = FactoryBot.create :roster, name: 'Transit IT'
ops = FactoryBot.create :roster, name: 'Transit Operations'

# USERS
names = {
  it => [
    %w(Karin Eichelman),
    %w(David Faulkenberry),
    %w(Matt Moretti),
    %w(Adam Sherson),
    %w(Metin Yavuz)
  ],
  ops => [
    %w(Glenn Barrington),
    %w(Bridgette Bauer),
    %w(Andrew Cathcart),
    %w(Don Chapman),
    %w(Karin Eichelman),
    %w(David Faulkenberry),
    %w(Graham Fortier-Dubé),
    %w(Tabitha Golz),
    %w(Jonathan McHatton),
    %w(Matt Moretti),
    %w(Diana Noble),
    %w(Derek Pires),
    %w(Evan Rife),
    %w(Nathan Santana),
    %w(Adam Sherson),
    %w(Daren Two\ Feathers)
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
ops.memberships.joins(:user).where(users: { last_name: %w(Barrington Noble) })
                            .update_all admin: true
it.memberships.joins(:user).where(users: { last_name: 'Sherson' })
                           .update_all admin: true

# ASSIGNMENTS
unless ENV['SKIP_ASSIGNMENTS']
  Roster.all.each do |roster|
    roster.users.order(:last_name).each_with_index do |user, i|
      FactoryBot.create :assignment, user: user, roster: roster,
        start_date: i.weeks.since.beginning_of_week(:friday),
        end_date: i.weeks.since.end_of_week(:friday)
    end
  end
end
