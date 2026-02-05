# frozen_string_literal: true

class FeedController < ApplicationController
  include Rosterable

  before_action :allow_calendar_token_access, only: :show

  def show
    feed = Feed.new(roster)
    authorize! feed
    render plain: feed.output, content_type: 'text/calendar'
  rescue ActionPolicy::Unauthorized
    skip_verify_authorized!
    head :forbidden
  end

  private

  def allow_calendar_token_access
    return if params[:token].blank?

    Current.user ||= User.find_by(calendar_access_token: params[:token])
  end
end
