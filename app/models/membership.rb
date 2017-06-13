# frozen_string_literal: true

class Membership < ActiveRecord::Base
  has_paper_trail
  belongs_to :user
  belongs_to :roster
  validates :user, :roster, presence: true
  validates :user, uniqueness: { scope: :roster }
end
