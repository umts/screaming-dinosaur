# frozen_string_literal: true

RSpec.describe 'generate rotation' do
  let(:roster) { create :roster }
  let(:roster_admin) { create :user, rosters: [roster] }
  let!(:roster_user) { create :user, rosters: [roster] }

  before do
    roster_admin.membership_in(roster).update admin: true
    when_current_user_is roster_admin
    visit roster_assignments_rotation_generator_path(roster)
  end

  it 'does not let you generate a rotation without the starting user' do
    select(roster_user.last_name, from: 'Starting with')
    unselect(roster_user.last_name, from: 'Users')
    click_button 'Generate rotation'
    expect(page).to have_css '.alert.alert-danger', text: 'Starting user is not included in the list'
  end
end
