# frozen_string_literal: true

RSpec.describe CheckRostersUncoveredDatesJob do
  subject(:job) { described_class.perform_now }

  let(:admin) { create :user }
  let(:roster) { create :roster }

  before { create :membership, user: admin, roster: }

  context 'with open assignments in the next two weeks' do
    before do
      create :assignment, roster:, user: admin, start_date: 1.week.from_now, end_date: 2.weeks.from_now
    end

    context 'with admins' do
      before { admin.memberships.last.update(admin: true) }

      it 'queues the email to be sent' do
        expect { job }.to change { ActionMailer::Base.deliveries.size }.by 1
      end
    end

    context 'without admins' do
      it 'does not queue the email to be sent' do
        expect { job }.not_to(change { ActionMailer::Base.deliveries.size })
      end
    end
  end

  context 'without open assignments in the next two weeks' do
    before do
      admin.memberships.last.update(admin: true)
      create :assignment, roster:, user: admin, start_date: Time.zone.today, end_date: 2.weeks.from_now
    end

    it 'does not queue the email to be sent' do
      expect { job }.not_to(change { ActionMailer::Base.deliveries.size })
    end
  end
end
