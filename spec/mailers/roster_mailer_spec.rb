# frozen_string_literal: true

RSpec.describe RosterMailer do
  describe 'open_dates_alert' do
    subject(:email) { described_class.with(roster: roster).open_dates_alert }

    let(:roster) { create(:roster) }
    let(:admin) { create(:user) }

    before { create(:membership, roster: roster, user: admin, admin: true) }

    context 'with open assignments in the next two weeks' do
      before { create(:assignment, roster: roster, start_date: 1.week.from_now, end_date: 2.weeks.from_now) }

      it 'queues the email to be sent' do
        expect { email.deliver_now }.to change { ActionMailer::Base.deliveries.size }.by 1
      end

      it 'sends the email to the correct users' do
        admin2 = create(:user)
        create(:membership, roster: roster, user: admin2, admin: true)

        expect(email.to).to eq [admin.email, admin2.email]
      end

      it 'has the correct subject' do
        expect(email.subject).to eq "Upcoming dates are uncovered for #{roster.name} On-Call"
      end

      it 'includes the roster name' do
        expect(email.body.encoded).to include roster.name
      end

      it 'includes the uncovered dates' do
        open_dates = Time.zone.today.to_date.upto(6.days.from_now.to_date)
        open_dates_string = ''
        open_dates.each { |date| open_dates_string += "\r\n#{date.to_fs(:short)}" }

        expect(email.body.encoded).to have_text open_dates_string
      end

      context 'without a fallback user' do
        it 'includes no fallback user message' do
          expect(email.body.encoded).to include 'There is no fallback user!'
        end
      end

      context 'with a fallback user' do
        let(:roster) { create(:roster, fallback_user: admin) }

        it 'includes the fallback user name' do
          expect(email.body.encoded).to have_text "The fallback user is #{roster.fallback_user.full_name}."
        end
      end
    end

    context 'without open assignments in the next two weeks' do
      before { create(:assignment, roster: roster, start_date: Time.zone.today, end_date: 2.weeks.from_now) }

      it 'does not queue the email to be sent' do
        expect { email.deliver_now }.not_to(change { ActionMailer::Base.deliveries.size })
      end
    end
  end
end
