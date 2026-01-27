# frozen_string_literal: true

class FeedController < ApplicationController
  before_action :allow_calendar_token_access, only: :show

  def show
    roster = params[:roster].titleize.downcase
    @roster = Roster.where('lower(name) = ?', roster).first

    feed = Feed.new(@roster.assignments)
    authorize! feed

    render_ics_feed
  rescue ActionPolicy::Unauthorized
    skip_verify_authorized!
    head :forbidden
  end

  private

  def allow_calendar_token_access
    return if params[:token].blank?

    Current.user ||= User.find_by(calendar_access_token: params[:token])
  end

  def render_ics_feed
    feed = Feed.new(@roster.assignments)
    render plain: feed.output, content_type: 'text/calendar'
  end
end
