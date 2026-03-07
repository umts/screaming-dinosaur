# frozen_string_literal: true

class VersionsController < ApplicationController
  before_action :find_version

  def undo
    authorize! @version
    # Reify only returns false when the thing didn't exist beforehand.
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    flash_success_for(@version)
    redirect_back_or_to root_path
  end

  private

  def find_version
    @version = Version.find params[:id]
  end
end
