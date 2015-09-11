require 'factory_girl_rails'

# USERS
FactoryGirl.create :user, first_name: 'Adam',  last_name: 'Sherson',      email: 'adam@umass.edu'
FactoryGirl.create :user, first_name: 'Metin', last_name: 'Yavuz',        email: 'yavuz@umass.edu'
FactoryGirl.create :user, first_name: 'Matt',  last_name: 'Moretti',      email: 'moretti@umass.edu'
FactoryGirl.create :user, first_name: 'Logan', last_name: 'Slinski',      email: 'phantom.patrol@gmail.com'
FactoryGirl.create :user, first_name: 'David', last_name: 'Faulkenberry', email: 'dfaulken@umass.edu'


# ASSIGNMENTS
User.all.each_with_index do |user, i|
  FactoryGirl.create :assignment, user: user,
    start_date: i.weeks.since.beginning_of_week(:friday),
    end_date: i.weeks.since.end_of_week(:friday)
end
