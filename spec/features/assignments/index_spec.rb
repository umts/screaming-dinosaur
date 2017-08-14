# frozen_string_literal: true

require 'rails_helper'

describe 'viewing the calendar' do
  it 'highlights today' do
    visit assignments_url
  end
end