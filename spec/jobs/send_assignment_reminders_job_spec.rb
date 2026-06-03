# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendAssignmentRemindersJob do
  subject(:job) { described_class.perform_now }

  before { travel_to(Time.zone.local(2026, 5, 24, 20, 0, 0)) }

  let(:roster) { create :roster, created_at: 3.weeks.ago }

  it 'sends no emails when no qualifying assignments exist' do
    expect { job }.not_to(change { ActionMailer::Base.deliveries.size })
  end

  context 'with an assignment whose start_datetime is in the upcoming Mon-Sun window' do
    let(:recipient) { roster_user roster }

    before do
      create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 5, 26, 17, 0, 0)
      create :assignment, roster:, user: recipient, end_datetime: Time.zone.local(2026, 5, 27, 17, 0, 0)
    end

    it 'sends one email to the recipient' do
      expect { job }.to change { ActionMailer::Base.deliveries.size }.by 1
    end

    it 'addresses the email to the recipient' do
      job
      expect(ActionMailer::Base.deliveries.last.to).to eql Array(recipient.email)
    end
  end

  context 'with an assignment whose start_datetime is before the window' do
    let(:recipient) { roster_user roster }

    before do
      create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 5, 22, 17, 0, 0)
      create :assignment, roster:, user: recipient, end_datetime: Time.zone.local(2026, 5, 23, 17, 0, 0)
    end

    it 'does not send an email' do
      expect { job }.not_to(change { ActionMailer::Base.deliveries.size })
    end
  end

  context 'with an assignment whose start_datetime is after the window' do
    let(:recipient) { roster_user roster }

    before do
      create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 6, 2, 17, 0, 0)
      create :assignment, roster:, user: recipient, end_datetime: Time.zone.local(2026, 6, 3, 17, 0, 0)
    end

    it 'does not send an email' do
      expect { job }.not_to(change { ActionMailer::Base.deliveries.size })
    end
  end

  context 'with only anchor assignments (user_id nil) in the window' do
    before do
      create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 5, 26, 17, 0, 0)
      create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 5, 27, 17, 0, 0)
    end

    it 'does not send any emails' do
      expect { job }.not_to(change { ActionMailer::Base.deliveries.size })
    end
  end

  context 'when a recipient has assignments across multiple rosters in the window' do
    let(:recipient) { create :user, rosters: [roster, other_roster] }
    let(:other_roster) { create :roster, created_at: 3.weeks.ago }

    before do
      create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 5, 26, 17, 0, 0)
      create :assignment, roster:, user: recipient, end_datetime: Time.zone.local(2026, 5, 27, 17, 0, 0)
      create :assignment, roster: other_roster, user: nil,
                          end_datetime: Time.zone.local(2026, 5, 28, 17, 0, 0)
      create :assignment, roster: other_roster, user: recipient,
                          end_datetime: Time.zone.local(2026, 5, 29, 17, 0, 0)
    end

    it 'sends a single email to the recipient' do
      expect { job }.to change { ActionMailer::Base.deliveries.size }.by 1
    end

    it 'includes both rosters in the email body' do
      job
      body = ActionMailer::Base.deliveries.last.body.encoded
      expect(body).to include(roster.name).and include(other_roster.name)
    end
  end

  context 'with an assignment whose start_datetime is exactly the Monday boundary' do
    let(:recipient) { roster_user roster }

    before do
      create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 5, 25, 0, 0, 0)
      create :assignment, roster:, user: recipient, end_datetime: Time.zone.local(2026, 5, 26, 17, 0, 0)
    end

    it 'sends an email (Monday 00:00 is inclusive)' do
      expect { job }.to change { ActionMailer::Base.deliveries.size }.by 1
    end
  end

  context 'with an assignment whose start_datetime is exactly the following Monday boundary' do
    let(:recipient) { roster_user roster }

    before do
      create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 6, 1, 0, 0, 0)
      create :assignment, roster:, user: recipient, end_datetime: Time.zone.local(2026, 6, 2, 17, 0, 0)
    end

    it 'does not send an email (next Monday 00:00 is exclusive)' do
      expect { job }.not_to(change { ActionMailer::Base.deliveries.size })
    end
  end
end
