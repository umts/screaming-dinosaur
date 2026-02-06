# frozen_string_literal: true

module Rosterable
  extend ActiveSupport::Concern

  included do
    authorize :roster, through: :roster
  end

  protected

  def roster
    @roster ||= Roster.friendly.find(params[:roster_id]) if params.key?(:roster_id)
  end
end
