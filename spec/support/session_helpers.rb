# frozen_string_literal: true

module SessionHelpers
  extend ActiveSupport::Concern

  included do
    let(:current_user) { create :user }

    before { login_as(current_user) if current_user.present? }
  end

  def login_as(user)
    if defined?(page) && page.is_a?(Capybara::Session)
      original_url = current_url
      visit "/auth/developer/callback?uid=#{user&.entra_uid}"
      visit original_url
    elsif defined?(controller) && controller.is_a?(ApplicationController)
      allow(controller).to receive(:find_current_user).and_return(user)
    else
      get '/auth/developer/callback', params: { uid: user&.entra_uid }
    end
  end
end
