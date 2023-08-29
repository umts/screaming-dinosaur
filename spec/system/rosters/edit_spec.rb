# frozen_string_literal: true

RSpec.describe 'editing a roster' do
  let(:roster) { create :roster, switchover: (23 * 60) + 45 }

  before do
    when_current_user_is roster_admin(roster)
    visit edit_roster_path(roster)
  end

  it 'displays the switchover in a time field' do
    expect(page).to have_field('roster_switchover_time', with: '23:45')
  end

  it 'updates the switchover with the submitted time' do
    fill_in 'roster_switchover_time', with: '04:56'
    click_on 'Save'
    expect(roster.reload.switchover).to eq((4 * 60) + 56)
  end
end
