# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Taking assignments' do
  let(:roster) { create :roster }
  let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: false)] }

  describe 'taking a single assignment from the index' do
    let!(:assignment) { create :assignment, roster:, user: nil }

    it 'assigns the current user' do
      visit roster_assignments_path(roster)
      click_on 'Take'
      click_on 'Take'
      expect(assignment.reload.user).to eq current_user
    end
  end

  describe 'taking a grouped assignment' do
    let(:group) { create :assignment_group, name: 'Morning shifts' }
    let!(:assignment) { create :assignment, roster:, user: nil, assignment_group: group }
    let!(:sibling) { create :assignment, roster:, user: nil, assignment_group: group }

    it 'shows the group name' do
      visit take_assignment_path(assignment)
      expect(page).to have_text('Morning shifts')
    end

    it 'takes only the target when the whole-group box is unchecked' do
      visit take_assignment_path(assignment)
      click_on 'Take'
      expect(assignment.reload.user).to eq current_user
    end

    it 'leaves the siblings unassigned when the whole-group box is unchecked' do
      visit take_assignment_path(assignment)
      click_on 'Take'
      expect(sibling.reload.user).to be_nil
    end

    it 'takes the whole group when the box is checked' do
      visit take_assignment_path(assignment)
      check 'Take the whole group'
      click_on 'Take'
      expect([assignment, sibling].map { |a| a.reload.user }).to all(eq(current_user))
    end
  end
end
