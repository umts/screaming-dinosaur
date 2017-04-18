# frozen_string_literal: true
PaperTrail.config.track_associations = false
PaperTrail::Rails::Engine.eager_load!

module PaperTrail
  class Version
    scope :done_by, ->(user) { where(whodunnit: user.id.to_s) }

    def done_by?(user)
      raise ArgumentError unless user.is_a? User
      whodunnit.to_i == user.id
    end
  end
end
