class RotationsController < ApplicationController
  before_action :find_rotation, only: %i(edit update)

  def edit
    @users = @rotation.users
  end

  def index
    @rotations = Rotation.all
  end

  def update
    rotation_params = params.require(:rotation).permit!
    if @rotation.update rotation_params
      flash[:message] = 'Rotation has been updated.'
      redirect_to rotations_path
    else
      flash[:errors] = @rotation.errors.full_messages
      redirect_to :back
    end
  end

  private

  def find_rotation
    @rotation = Rotation.find(params.require :id)
  end
end
