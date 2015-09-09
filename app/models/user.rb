class User < ActiveRecord::Base
  has_many :assignments

  validates :first_name, :last_name, :spire, :email, :phone,
            presence: true
  validates :spire, :email, :phone,
            uniqueness: true
end
