# frozen_string_literal: true

class SendAssignmentRemindersJob < ApplicationJob
  def perform
    Assignment.send_reminders!
  end
end
