# frozen_string_literal: true

class TwilioController < ApplicationController
  before_action :set_on_call_user
  layout false

  def call
    authorize!
    respond_to do |format|
      format.xml { render 'call', locals: { user: @user } }
    end
  end

  def text
    authorize!
    respond_to do |format|
      format.xml { render 'text', locals: { user: @user, body: params[:Body] } }
    end
  end

  private

  def set_on_call_user
    @user = @roster.on_call_user
  end
end
