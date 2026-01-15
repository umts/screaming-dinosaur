# frozen_string_literal: true

RSpec.describe RosterMailer do
  describe 'open_dates_alert' do
    subject(:email) { described_class.with(roster:, open_dates:).open_dates_alert }

    let(:admin) { create :user }
    let(:roster) { admin.rosters.last }
    let(:open_dates) { Time.zone.today.to_date..6.days.from_now.to_date }

    before { admin.memberships.last.update(admin: true) }

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

    it 'includes the uncovered dates' do
      open_dates_string = ''
      open_dates.each { |date| open_dates_string += "\r\n#{date.to_fs(:short)}" }

      expect(email.body.encoded).to have_content open_dates_string
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
      expect(email.body.encoded).to include 'update twilio'
      expect(email.body.encoded).to include roster_setup_path(roster)
    end
  end
end
