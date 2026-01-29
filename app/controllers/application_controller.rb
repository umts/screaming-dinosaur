# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authorizable

  before_action :set_roster

  protected

  def flash_success_for(subject, action = nil, undoable: false) = flash_success(flash, subject, action, undoable)

  def flash_errors_for(subject) = flash_errors(flash, subject)

  def flash_errors_now_for(subject) = flash_errors(flash.now, subject)

  private

  def flash_success(flash, subject, action, undoable)
    flash[:notice] = success_message_for(subject, action)
    flash[:undo] = subject.versions.last&.id if undoable
  end

  def flash_errors(flash, subject)
    flash[:alert] = subject.errors.full_messages.to_sentence
  end

  def success_message_for(subject, action)
    subject = subject.model_name.human.downcase if subject.respond_to?(:model_name)
    action ||= action_name
    t('success.message', action: t("success.actions.#{action}"), subject:)
  end

  def set_roster
    @roster = Roster.friendly.find(params[:roster_id], allow_nil: true) || Current.user&.rosters&.first || Roster.first
  end
end
