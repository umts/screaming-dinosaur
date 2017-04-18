class ChangesController < ApplicationController
  def undo
    version = PaperTrail::Version.find(params.require :id)
    unless version.whodunnit == @current_user.id.to_s
      head :unauthorized and return
    end
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
