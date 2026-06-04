# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RosterMailer do
  describe 'open_dates_alert' do
    subject(:email) { described_class.with(roster:, open_periods:).open_dates_alert }

    let(:admin) { create :user }
    let(:roster) { create :roster }
    let(:period_start) { Time.zone.local(2026, 6, 1, 17, 0, 0) }
    let(:period_end) { Time.zone.local(2026, 6, 2, 17, 0, 0) }
    let(:open_periods) { [{ start_datetime: period_start, end_datetime: period_end }] }

    before { create :membership, user: admin, roster:, admin: true }

    it 'queues the email to be sent' do
      expect { email.deliver_now }.to change { ActionMailer::Base.deliveries.size }.by 1
    end

    it 'sends the email to the correct users' do
      admin2 = create :user, rosters: [roster]
      admin2.memberships.last.update(admin: true)

      expect(email.to).to eq [admin.email, admin2.email]
    end

    it 'has the correct subject' do
      expect(email.subject).to eq "Upcoming dates are uncovered for #{roster.name} On-Call"
    end

    it 'includes the roster name' do
      expect(email.body.encoded).to include roster.name
    end

    it 'includes the start of each uncovered period' do
      expect(email.body.encoded).to include I18n.l(period_start, format: :named)
    end

    it 'includes the end of each uncovered period' do
      expect(email.body.encoded).to include I18n.l(period_end, format: :named)
    end

    context 'without a fallback user' do
      it 'includes no fallback user message' do
        expect(email.body.encoded).to include 'There is no fallback user!'
      end
    end

    context 'with a fallback user' do
      let(:roster) { create :roster, fallback_user: admin }

      it 'includes the fallback user name' do
        expect(email.body.encoded).to have_text "The fallback user is #{roster.fallback_user.full_name}."
      end
    end
  end

  describe 'fallback_number_changed' do
    subject(:email) { described_class.with(roster:).fallback_number_changed }

    let(:admin) { create :user }
    let(:roster) { create :roster, fallback_user: create(:user) }

    before { admin.memberships.create(roster:, admin: true) }

    it 'queues the email to be sent' do
      expect { email.deliver_now }.to change { ActionMailer::Base.deliveries.size }.by 1
    end

    it 'sends the email to the correct users' do
      admin2 = create :user
      admin2.memberships.create(roster:, admin: true)

      expect(email.to).to eq [admin.email, admin2.email]
    end

    it 'has the correct subject' do
      expect(email.subject).to eq "Fallback number changed for #{roster.name} On-Call"
    end

    it 'includes the update twilio link' do
      expect(email.body.encoded).to include('update twilio').and include(edit_roster_path(roster))
    end
  end
end
