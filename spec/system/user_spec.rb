# frozen_string_literal: true

require 'spec_helper'

describe 'user pages' do
  let(:roster) { create :roster }
  let(:admin_membership) { create :membership, roster: roster, admin: true }
  let(:admin) { create :user, memberships: [admin_membership] }
  context 'viewing the index' do
  end
end
