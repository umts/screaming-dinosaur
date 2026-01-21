# frozen_string_literal: true

RSpec.describe 'the navbar' do
  let(:roster) { create :roster }
  let(:current_user) { roster_user(roster) }

  it 'applies active class to current tab in nav-bar' do
    visit roster_assignments_path(roster)
    expect(page).to have_css('.nav-link.active', count: 1)
  end
end
