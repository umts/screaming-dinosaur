# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  authorize :user, allow_nil: true
  authorize :api_key, optional: true

  protected

  def valid_api_key? = api_key.present? && api_key == Rails.application.credentials.fetch(:api_key)
end
