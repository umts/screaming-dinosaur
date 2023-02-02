# screaming-dinosaur

A Rails app for the management of on-call schedules and interactions with Twilio.

![screaming dinosaur](app/assets/images/screaming_dinosaur.jpg)

[![Build Status](https://travis-ci.org/umts/screaming-dinosaur.svg?branch=master)](https://travis-ci.org/umts/screaming-dinosaur)
[![Code Climate](https://codeclimate.com/github/umts/screaming-dinosaur/badges/gpa.svg)](https://codeclimate.com/github/umts/screaming-dinosaur)
[![Test Coverage](https://codeclimate.com/github/umts/screaming-dinosaur/badges/coverage.svg)](https://codeclimate.com/github/umts/screaming-dinosaur/coverage)
[![Issue Count](https://codeclimate.com/github/umts/screaming-dinosaur/badges/issue_count.svg)](https://codeclimate.com/github/umts/screaming-dinosaur)

## Development

### Setup
1. Install Gems: `bundle`
2. Install Node packages: `yarn`
3. Create your application.yml: `cp config/application.yml.example config/application.yml`
4. Create your database.yml: `cp config/database.yml.example config/database.yml`
5. Setup your databases: `rails db:setup`

### Style guides

This app comes bundled with [RuboCop](https://github.com/rubocop/rubocop) for ruby files,
[haml-lint](https://github.com/sds/haml-lint) for haml files, [ESLint](https://eslint.org/) for JavaScript files,
and [Stylelint](https://github.com/stylelint/stylelint) for scss files.

Many text editors have support for these linters and can show code violations in real time.

You can also run the linters from the command line:

```bash
rubocop your_file.rb
```
```bash
haml-lint your_file.html.haml
```
```bash
yarn run eslint your_file.js
```
```bash
yarn run stylelint your_file.scss
```
