# frozen_string_literal: true

class ChangesController < ApplicationController
  def undo
    version = PaperTrail::Version.find params.require(:id)
    original_user = version.whodunnit.to_i == @current_user.id
    head :unauthorized and return unless original_user

    # Reify only returns false when the thing didn't exist beforehand.
    if version.reify
      version.reify.save!
      flash[:message] = 'Change has been reverted.'
    else
      version.item.destroy
      flash[:message] = "#{version.item_type} has been deleted."
    end
    redirect_back fallback_location: 'public/404.html'
  end
end
