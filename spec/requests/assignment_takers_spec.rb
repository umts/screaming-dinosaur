# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Assignment Takers' do
  let(:roster) { create(:roster) }
  let(:current_user) { create(:user, memberships: [build(:membership, roster:, admin: false)]) }

  describe 'GET /assignments/:id/take' do
    subject(:call) { get "/assignments/#{assignment.id}/take" }

    let(:assignment) { create(:assignment, roster:, user: nil) }

    context 'when logged in as a member of the roster' do
      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end

    context 'when logged in as a user unrelated to the roster' do
      let(:current_user) { create(:user) }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the assignment belongs to a group' do
      let(:group) { create(:assignment_group) }
      let(:assignment) { create(:assignment, roster:, user: nil, assignment_group: group) }

      before { create(:assignment, roster:, user: nil, assignment_group: group) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /assignments/:id/take' do
    subject(:submit) { post "/assignments/#{assignment.id}/take", params: { assignment_taker: attributes } }

    let(:attributes) { {} }

    context 'when logged in as a user unrelated to the roster' do
      let(:assignment) { create(:assignment, roster:, user: nil) }
      let(:current_user) { create(:user) }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not assign the user' do
        expect { submit }.not_to(change { assignment.reload.user })
      end
    end

    context 'with an ungrouped assignment' do
      let(:assignment) { create(:assignment, roster:, user: nil) }

      it 'assigns the current user' do
        expect { submit }.to change { assignment.reload.user }.from(nil).to(current_user)
      end

      it 'redirects to the roster' do
        submit
        expect(response).to redirect_to roster_path(roster)
      end
    end

    context 'with an already-assigned assignment' do
      let(:other_user) { create(:user) }
      let(:assignment) { create(:assignment, roster:, user: other_user) }

      it 'reassigns it to the current user' do
        expect { submit }.to change { assignment.reload.user }.from(other_user).to(current_user)
      end
    end

    context 'when taking the whole group of a grouped assignment' do
      let(:assignment) { create(:assignment, roster:, user: nil, assignment_group: create(:assignment_group)) }
      let!(:sibling) { create(:assignment, roster:, user: nil, assignment_group: assignment.assignment_group) }
      let(:attributes) { { group: '1' } }

      it 'assigns the current user to every member of the group' do
        submit
        expect([assignment, sibling].map { |a| a.reload.user }).to all(eq(current_user))
      end
    end

    context 'when taking a single assignment from a group' do
      let(:assignment) { create(:assignment, roster:, user: nil, assignment_group: create(:assignment_group)) }
      let!(:sibling) { create(:assignment, roster:, user: nil, assignment_group: assignment.assignment_group) }
      let(:attributes) { { group: '0' } }

      it 'assigns the current user to the target assignment' do
        submit
        expect(assignment.reload.user).to eq current_user
      end

      it 'leaves the other group members unassigned' do
        submit
        expect(sibling.reload.user).to be_nil
      end
    end

    context 'when assigning another user to an ungrouped assignment' do
      let(:user_to_assign) { create(:membership, roster:).user }
      let(:attributes) { { user_id: user_to_assign.id } }
      let(:assignment) { create(:assignment, roster:, user: nil) }

      it 'assigns the specified user' do
        expect { submit }.to change { assignment.reload.user }.from(nil).to(user_to_assign)
      end

      it 'redirects to the roster' do
        submit
        expect(response).to redirect_to roster_path(roster)
      end
    end

    context 'when assigning another user to an already-assigned assignment' do
      let(:user_to_assign) { create(:membership, roster:).user }
      let(:assignment) { create(:assignment, roster:) }
      let(:attributes) { { user_id: user_to_assign.id } }

      it 'reassigns it to the specified user' do
        expect { submit }.to change { assignment.reload.user }.to(user_to_assign)
      end
    end

    context 'when assigning another user to an entire assignment group' do
      before do
        assignment_group = create(:assignment_group)
        create_list(:assignment, 5, roster:, user: nil, assignment_group:)
      end

      let(:assignment) { Assignment.first }
      let(:user_to_assign) { create(:membership, roster:).user }
      let(:attributes) { { group: '1', user_id: user_to_assign.id } }

      it 'assigns the specified user to every member of the group' do
        submit
        expect(Assignment.all.map { |a| a.reload.user }).to all(eq(user_to_assign))
      end
    end

    context 'when assigning another user to one assignment from a group' do
      before do
        assignment_group = create(:assignment_group)
        create_list(:assignment, 5, roster:, user: nil, assignment_group:)
      end

      let(:assignment) { Assignment.first }
      let(:user_to_assign) { create(:membership, roster:).user }
      let(:attributes) { { group: '0', user_id: user_to_assign.id } }

      it 'assigns the specified user to the target assignment' do
        expect { submit }.to change { assignment.reload.user }.to(user_to_assign)
      end

      it 'leaves the other group members unassigned' do
        expect { submit }.not_to(change { Assignment.where.not(id: Assignment.first.id).pluck(&:user_id) })
      end
    end
  end
end
