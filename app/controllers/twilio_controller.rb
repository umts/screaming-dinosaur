class TwilioController < ApplicationController
  before_action :set_on_call_user
  skip_before_action :set_current_user
  layout false

  def call
    respond_to do |format|
      format.xml { render 'call' }
    end
  end

  def text
    @body = params[:Body]
    respond_to do |format|
      format.xml { render 'text' }
    end
  end

  private

  def set_on_call_user
    @user = Assignment.current.user
  end
end
