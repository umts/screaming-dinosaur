# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendAssignmentRemindersJob do
  include ActiveSupport::Testing::TimeHelpers

  subject(:job) { described_class.perform_now }

  before do
    travel_to(Time.zone.local(2026, 5, 24, 20, 0, 0))
    create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 5, 26, 17, 0, 0)
    create :assignment, roster:, user: recipient, end_datetime: Time.zone.local(2026, 5, 27, 17, 0, 0)
  end

  let(:roster) { create :roster, created_at: 3.weeks.ago }
  let(:recipient) { roster_user roster }

  it 'sends the upcoming reminder email' do
    expect { job }.to change { ActionMailer::Base.deliveries.size }.by 1
  end
end
