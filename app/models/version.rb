# frozen_string_literal: true

class Version < ApplicationRecord
  include PaperTrail::VersionConcern

  belongs_to :author, optional: true, class_name: 'User', foreign_key: :whodunnit, inverse_of: :authored_versions
end
