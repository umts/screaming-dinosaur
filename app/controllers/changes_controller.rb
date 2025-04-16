# frozen_string_literal: true

class ChangesController < ApplicationController
  before_action :find_version
  before_action :require_original_user

  def undo
    # Reify only returns false when the thing didn't exist beforehand.
    if @version.reify
      @version.reify.save!
      flash[:message] = t('.change')
    else
      @version.item.destroy
      flash[:message] = t('.create', item: @version.item_type)
    end
    redirect_back fallback_location: '/public/404.html'
  end

  private

  def find_version
    @version = PaperTrail::Version.find params.require(:id)
  end

  def require_original_user
    return if @version.whodunnit.to_i == Current.user&.id

    head :unauthorized
  end
end
