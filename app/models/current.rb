# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user

  resets { PaperTrail.request.whodunnit if PaperTrail.request.enabled? }

  def user=(user)
    PaperTrail.request.whodunnit = user&.id if PaperTrail.request.enabled?
    super
  end
end
