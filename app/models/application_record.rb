# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.minutes_since_midnight
    now = Time.zone.now
    Arel::Nodes.build_quoted ((now - now.midnight) / 60).to_i
  end
end
