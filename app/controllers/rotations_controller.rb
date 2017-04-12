class RotationsController < ApplicationController

  def create
    rotation_params = params.require(:rotation).permit(:name)
    rotation = Rotation.new rotation_params
    if rotation.save
      flash[:message] = 'Rotation has been created.'
      redirect_to rotations_path
    else
      flash[:errors] = rotation.errors.full_messages
      redirect_to :back
    end
  end

  def destroy
    @rotation.destroy
    flash[:message] = 'Rotation and any assignments have been deleted.'
    redirect_to rotations_path
  end

  def edit
    @users = @rotation.users
  end

  def index
    @rotations = Rotation.all
  end

  def new
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

  #def find_rotation
   # @rotation = Rotation.find(params.require :id)
  #end
end
