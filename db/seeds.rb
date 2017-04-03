require 'factory_girl_rails'

# USERS
names = [
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

names.each do |(first_name, last_name)|
  FactoryGirl.create :user, first_name: first_name, last_name: last_name,
                            email: last_name + '@example.umass.edu'
end


# ASSIGNMENTS
User.order(:last_name).each_with_index do |user, i|
  FactoryGirl.create :assignment, user: user,
    start_date: i.weeks.since.beginning_of_week(:friday),
    end_date: i.weeks.since.end_of_week(:friday)
end
