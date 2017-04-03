class Rotation < ActiveRecord::Base
  has_many :assignments
  has_and_belongs_to_many :users
  belongs_to :fallback_user, class_name: 'User', foreign_key: :fallback_user_id

  validates :name, presence: true, uniqueness: true

end
