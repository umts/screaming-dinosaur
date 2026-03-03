# frozen_string_literal: true

module LoginHelpers
  extend ActiveSupport::Concern

  included do
    let(:current_user) { nil }

    if self <= RSpec::Rails::RequestExampleGroup || self <= RSpec::Rails::SystemExampleGroup
      before { login_as(current_user) if current_user.present? }
    else
      around { |example| Current.set(user: current_user) { example.run } }
    end

    shared_context 'when logged in as a user unrelated to the roster' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }
    end

    shared_context 'when logged in as a member of the roster' do
      let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: false)] }
    end

    shared_context 'when logged in as an admin of the roster' do
      let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: true)] }
    end
  end

  def login_as(user)
    case self
    when RSpec::Rails::RequestExampleGroup
      rack_login_as(user)
    when RSpec::Rails::SystemExampleGroup
      capybara_login_as(user)
    else
      current_login_as(user)
    end
  end

  private

  def current_login_as(user)
    Current.user = user
  end

  def rack_login_as(user)
    get '/auth/developer/callback', params: { uid: user&.entra_uid }
  end

  def capybara_login_as(user)
    original_url = current_url
    visit "/auth/developer/callback?uid=#{user&.entra_uid}"
    visit original_url
  end
end
