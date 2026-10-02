# frozen_string_literal: true

require 'rails_helper'

module Maintenance
  RSpec.describe RemoveCreditUsersTask do
    describe '#process' do
      subject(:process) { described_class.new.process(element) }
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

    describe '#collection' do
      subject(:collection) { described_class.new.collection }
      let(:target_user_emails) do
        %w[
          11111111@umass.edu
          22222222@umass.edu
          66666666@umass.edu
          77777777@umass.edu
          88888888@umass.edu
          99999999@umass.edu
        ]
      end

      before do
        create_list(:user, 10)
        target_user_emails.each { |email| create(:user, email:) }
      end

      it 'only selects the emails specified in the task' do
        expect(collection.pluck(:email)).to eql(target_user_emails)
      end
    end
  end
end
