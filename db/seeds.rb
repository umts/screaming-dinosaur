require 'factory_girl_rails'

# ROTATIONS
it = FactoryGirl.create :rotation, name: 'Transit IT'
ops = FactoryGirl.create :rotation, name: 'Transit Operations'

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

names.each_pair do |rotation, rot_names|
  rot_names.each do |first_name, last_name|
    user = User.find_by first_name: first_name, last_name: last_name
    if user.present?
      user.rotations << rotation
      user.save!
    else
      FactoryGirl.create :user, first_name: first_name,
        last_name: last_name, rotations: [rotation]
    end
  end
end


# ASSIGNMENTS
unless ENV['SKIP_ASSIGNMENTS']
  Rotation.all.each do |rotation|
    rotation.users.order(:last_name).each_with_index do |user, i|
      FactoryGirl.create :assignment, user: user, rotation: rotation,
        start_date: i.weeks.since.beginning_of_week(:friday),
        end_date: i.weeks.since.end_of_week(:friday)
    end
  end
end
