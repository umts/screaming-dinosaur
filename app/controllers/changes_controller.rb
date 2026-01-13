# frozen_string_literal: true

class ChangesController < ApplicationController
  before_action :find_version

  def undo
    authorize! context: { user_id: @version.whodunnit.to_i }
    # Reify only returns false when the thing didn't exist beforehand.
    if @version.reify
      @version.reify.save!
      flash[:message] = t('.change')
    else
      @version.item.destroy
      flash[:message] = t('.create', item: @version.item_type)
    end
    redirect_back_or_to root_path
  end

  private

  def find_version
    @version = PaperTrail::Version.find params.require(:id)
  end
end
