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
    put RackSessionAccess.path, params: { data: RackSessionAccess.encode(user_id: user&.id) }
  end

  def capybara_login_as(user)
    page.set_rack_session(user_id: user&.id)
  end
end
