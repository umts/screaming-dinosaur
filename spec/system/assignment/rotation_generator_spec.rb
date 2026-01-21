# frozen_string_literal: true

RSpec.describe 'generate rotation' do
  let(:roster) { create :roster }
  let(:roster_admin) { create :user, rosters: [roster] }
  let!(:roster_user) { create :user, rosters: [roster] }
  let(:current_user) { roster_admin }

  before do
    roster_admin.membership_in(roster).update admin: true
    visit roster_assign_weeks_path(roster)
  end

  it 'does not let you generate a rotation without the starting user' do
    select(roster_user.last_name, from: 'Starting user')
    uncheck(roster_user.full_name)
    click_button 'Generate'
    expect(page).to have_css '.alert.alert-primary',
                             text: 'Starting user must be included in the list of selected users'
  end
end
