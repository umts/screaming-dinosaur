# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Assignment Generator' do
  describe 'GET /rosters/:roster_id/assignments/generate' do
    subject(:call) { get "/rosters/#{roster.slug}/assignments/generate" }

    let(:roster) { create :roster }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds with an forbidden status' do
        call
        expect(response).to have_http_status :forbidden
      end
    end

    context 'when logged in as the roster admin' do
      include_context 'when logged in as an admin of the roster'

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /rosters/:roster_id/assignments/generate' do
    subject(:submit) do
      post "/rosters/#{roster.slug}/assignments/generate", params: {
        assignment_generator: {
          user_id: user.id,
          start_date: Date.current,
          end_date: Date.current + 14.days,
          weekdays: %w[Monday Wednesday],
          end_time: Time.zone.parse('04:30')
        }
      }
    end

    let(:roster) { create :roster }
    let(:user) { create :user, rosters: [roster] }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds with an forbidden status' do
        submit
        expect(response).to have_http_status :forbidden
      end
    end

    context 'when logged in as the roster admin with valid atrributes' do
      include_context 'when logged in as an admin of the roster'

      it 'redirects to the roster assignments page' do
        submit
        expect(response).to redirect_to roster_path(roster, date: Date.current)
      end

      it 'only create assignments on selected weekdays' do
        submit
        roster.assignments.each do |assignment|
          expect(assignment.end_datetime.strftime('%A')).to be_in(%w[Monday Wednesday])
        end
      end

      it 'sets correct end_time for all the assignments' do
        submit
        roster.assignments.each do |assignment|
          expect(assignment.end_datetime).to have_attributes(hour: 4, min: 30)
        end
      end
    end

    context 'when logged in as an admin of the roster with invalid attributes' do
      subject(:submit) do
        post "/rosters/#{roster.slug}/assignments/generate", params: {
          assignment_generator: {
            user_id: user.id,
            start_date: nil,
            end_date: nil,
            weekdays: [],
            end_time: nil
          }
        }
      end

      let(:roster) { create :roster }
      let(:user) { create :user, rosters: [roster] }

      include_context 'when logged in as an admin of the roster'

      it 'responds with an unprocessable content status' do
        submit
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not create any assignments' do
        expect { submit }.not_to change(Assignment, :count)
      end
    end

    context 'when logged in as an admin of the roster with end_date before start_date' do
      subject(:submit) do
        post "/rosters/#{roster.slug}/assignments/generate", params: {
          assignment_generator: {
            user_id: user.id,
            start_date: Date.current,
            end_date: Date.current - 1.day,
            weekdays: %w[Monday Wednesday],
            end_time: Time.zone.parse('04:30')
          }
        }
      end

      let(:roster) { create :roster }
      let(:user) { create :user, rosters: [roster] }

      include_context 'when logged in as an admin of the roster'

      it 'responds with an unprocessable content status' do
        submit
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not create any assignments' do
        expect { submit }.not_to change(Assignment, :count)
      end
    end
  end
end
