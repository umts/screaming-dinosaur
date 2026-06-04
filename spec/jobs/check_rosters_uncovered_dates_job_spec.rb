# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckRostersUncoveredDatesJob do
  subject(:job) { described_class.perform_now }

  let(:admin) { create :user }
  let(:roster) { create :roster, created_at: 3.weeks.ago }

  before { create :membership, user: admin, roster:, admin: true }

  context 'with uncovered periods in the next two weeks' do
    before do
      create :assignment, roster:, user: admin, end_datetime: 1.day.from_now
    end

    it 'queues the email to be sent' do
      expect { job }.to change { ActionMailer::Base.deliveries.size }.by 1
    end

    context 'without admins' do
      before { admin.memberships.last.update(admin: false) }

      it 'does not queue the email to be sent' do
        expect { job }.not_to(change { ActionMailer::Base.deliveries.size })
      end
    end
  end

  context 'without uncovered periods in the next two weeks' do
    before do
      create :assignment, roster:, user: admin, end_datetime: 3.weeks.from_now
    end

    it 'does not queue the email to be sent' do
      expect { job }.not_to(change { ActionMailer::Base.deliveries.size })
    end
  end
end
