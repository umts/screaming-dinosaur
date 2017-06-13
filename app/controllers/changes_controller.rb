# frozen_string_literal: true

class ChangesController < ApplicationController
  def undo
    version = PaperTrail::Version.find(params.require :id)
    # ... and return is correct here
    # rubocop:disable Style/AndOr
    head :unauthorized and return unless version.done_by? @current_user
    # rubocop:enable Style/AndOr
    # Reify only returns false when the thing didn't exist beforehand.
    if version.reify
      version.reify.save!
      flash[:message] = 'Change has been reverted.'
    else
      version.item.destroy
      flash[:message] = "#{version.item_type} has been deleted."
    end
    redirect_to :back
  end
end
