# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feeds' do
  before { freeze_time }

  describe 'GET /feed/:roster_id/:token' do
    subject(:call) { get "/feed/#{roster.slug}/#{token}" }

    let(:roster) { create(:roster, created_at: 1.hour.ago) }
    let!(:first_assignment) do
      create(:assignment, roster:, user: create(:user, rosters: [roster]), end_datetime: Time.current)
    end
    let!(:second_assignment) do
      create(:assignment, roster:, user: create(:user, rosters: [roster]), end_datetime: 2.hours.from_now)
    end

    before { create(:assignment, roster:, user: nil, end_datetime: 1.hour.from_now) }

    context 'when logged in as a user unrelated to the roster' do
      let(:token) { 'sometoken' }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with a blank token' do
      let(:token) { '%20' }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster using a calendar access token' do
      let(:token) { create(:user, rosters: [roster]).calendar_access_token }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      it 'responds with a calendar file' do
        call
        expect(response.media_type).to eq('text/calendar')
      end

      it 'responds with calendar data for all assignments with users' do
        call
        expect(response.body.chomp).to eq(<<~ICS.split("\n").join("\r\n"))
          BEGIN:VCALENDAR
          VERSION:2.0
          PRODID:-//umasstransit.org//umts-oncall.admin.umass.edu//EN
          CALSCALE:GREGORIAN
          METHOD:PUBLISH
          BEGIN:VEVENT
          DTSTAMP:#{Time.current.utc.strftime('%Y%m%dT%H%M%SZ')}
          UID:#{first_assignment.id}@screaming-dinosaur
          DTSTART:#{first_assignment.start_datetime.utc.strftime('%Y%m%dT%H%M%SZ')}
          DTEND:#{first_assignment.end_datetime.utc.strftime('%Y%m%dT%H%M%SZ')}
          CREATED:#{first_assignment.created_at.utc.strftime('%Y%m%dT%H%M%SZ')}
          DESCRIPTION:#{first_assignment.user.full_name} is on call for #{roster.name}.
          LAST-MODIFIED:#{first_assignment.updated_at.utc.strftime('%Y%m%dT%H%M%SZ')}
          STATUS:CONFIRMED
          SUMMARY:#{first_assignment.user.full_name}
          END:VEVENT
          BEGIN:VEVENT
          DTSTAMP:#{Time.current.utc.strftime('%Y%m%dT%H%M%SZ')}
          UID:#{second_assignment.id}@screaming-dinosaur
          DTSTART:#{second_assignment.start_datetime.utc.strftime('%Y%m%dT%H%M%SZ')}
          DTEND:#{second_assignment.end_datetime.utc.strftime('%Y%m%dT%H%M%SZ')}
          CREATED:#{second_assignment.created_at.utc.strftime('%Y%m%dT%H%M%SZ')}
          DESCRIPTION:#{second_assignment.user.full_name} is on call for #{roster.name}.
          LAST-MODIFIED:#{second_assignment.updated_at.utc.strftime('%Y%m%dT%H%M%SZ')}
          STATUS:CONFIRMED
          SUMMARY:#{second_assignment.user.full_name}
          END:VEVENT
          END:VCALENDAR
        ICS
      end
    end
  end
end
