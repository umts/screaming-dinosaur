class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :roster
  validates :user, :roster, presence: true
  validates :user, uniqueness: { scope: :roster }
end
