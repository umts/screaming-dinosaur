# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Assignment Generator' do
  describe 'start date autofill' do
    let(:roster) { create(:roster) }
    let(:current_user) { create(:user, memberships: [build(:membership, roster:, admin: true)]) }

    context 'when assignments exist in the roster' do
      before do
        create_list(:assignment, 10, roster:)
        visit generate_roster_assignments_path(roster)
      end

      let(:last_assignment) { roster.assignments.order(:end_datetime).first }

      it "fills in the start date field with the most recent assignment's end date" do
        expect(page).to have_css("input[value='#{last_assignment.end_datetime.to_date}']")
      end

      it "shows a hint with the most recent assignment's end date and time" do
        expect(page).to have_text(/#{I18n.l last_assignment.end_datetime, format: :named_with_year}/)
      end
    end
  end
end
