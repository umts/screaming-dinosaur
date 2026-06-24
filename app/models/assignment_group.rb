# frozen_string_literal: true

class AssignmentGroup < ApplicationRecord
  has_many :assignments, dependent: :nullify

  validates :name, presence: true
end
