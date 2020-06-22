# screaming-dinosaur

![screaming dinosaur](app/assets/images/screaming_dinosaur.jpg)

[![Build Status](https://travis-ci.org/umts/screaming-dinosaur.svg?branch=master)](https://travis-ci.org/umts/screaming-dinosaur)
[![Code Climate](https://codeclimate.com/github/umts/screaming-dinosaur/badges/gpa.svg)](https://codeclimate.com/github/umts/screaming-dinosaur)
[![Test Coverage](https://codeclimate.com/github/umts/screaming-dinosaur/badges/coverage.svg)](https://codeclimate.com/github/umts/screaming-dinosaur/coverage)
[![Issue Count](https://codeclimate.com/github/umts/screaming-dinosaur/badges/issue_count.svg)](https://codeclimate.com/github/umts/screaming-dinosaur)

Other candidates for the repo name included:

+ rough-morning
+ persistent-weeknight
+ digital-moose
+ nervous-neutron

Rails 5 app for management of Transportation IT on-call schedule and interaction with Twilio.

## Development

### Setup
1. `bundle`
2. `yarn`
3. Create your application.yml: `cp config/application.yml.example config/application.yml`
4. Create your database.yml: `cp config/database.yml.example config/database.yml`
5. Create the databases: `rails db:create`
6. Setup databases: `rails db:schema:load`
7. Seed development data: `rails db:seed`

When seeding, you can skip creating assignments with `SKIP_ASSIGNMENTS=true rake db:reset` etc.
