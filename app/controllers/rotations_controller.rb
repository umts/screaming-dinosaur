class RotationsController < ApplicationController
  def index
    @rotations = Rotation.all
  end
end
