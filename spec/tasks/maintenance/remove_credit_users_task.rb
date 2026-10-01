# frozen_string_literal: true

require 'rails_helper'

module Maintenance
  RSpec.describe RemoveCreditUsersTask do
    describe '#process' do
      subject(:process) { described_class.process(element) }
      let!(:unaffected_user) { create(:user, assignments: create_list(:assignment, 10)) }
      let!(:assignments) { create_list(:assignment, 10, user: element) }
      let(:element) { create(:user) }

      it 'releases the users assignments' do
        process
        expect(assignments.map { |assignment| assignment.reload.user }).to all be_nil
      end

      it 'removes the user' do
        expect { process }.to change(User, :count).by(-1)
      end

      it 'does not change other users' do
        expect { process }.not_to change(unaffected_user, :assignments)
      end
    end
  end
end
