# frozen_string_literal: true

RSpec.describe 'the navbar' do
  let(:roster) { create :roster }

  it 'applies active class to current tab in nav-bar' do
    when_current_user_is roster_user(roster)
    visit roster_assignments_url(roster)
    expect(page).to have_selector('nav li.active', count: 1)
  end
end
