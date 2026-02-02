# frozen_string_literal: true

RSpec.describe 'roster setup page' do
  let(:roster) { create :roster, fallback_user: create(:user) }
  let(:current_user) { roster_admin roster }

  before do
    visit setup_roster_path(roster)
  end

  it 'displays the call webhook URL' do
    expect(page).to have_content('Call webhook')
  end

  it 'displays the message webhook URL' do
    expect(page).to have_content('Message webhook')
  end

  it 'has a copy button for call webhook' do
    within find('.card', text: 'Call webhook') do
      expect(page).to have_button('Copy')
    end
  end

  it 'has a copy button for message webhook' do
    within find('.card', text: 'Message webhook') do
      expect(page).to have_button('Copy')
    end
  end

  it 'displays failure handler cards when fallback user is present' do
    expect(page).to have_content('Failure handler', count: 2)
  end
end
