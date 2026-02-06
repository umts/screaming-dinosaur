# frozen_string_literal: true

class TwilioController < ApplicationController
  include Rosterable

  layout false

  def call
    authorize!
    respond_to do |format|
      format.xml { render 'call', locals: { user: roster.on_call_user } }
    end
  end

  def text
    authorize!
    respond_to do |format|
      format.xml { render 'text', locals: { user: roster.on_call_user, body: params[:Body] } }
    end
  end
end
