class User < ActiveRecord::Base
  has_many :assignments, dependent: :restrict_with_error
  has_many :memberships
  has_many :rosters, through: :memberships

  validates :first_name, :last_name, :spire, :email, :phone, :rosters,
            presence: true
  validates :spire, :email, :phone,
            uniqueness: true
  validates :spire,
            format: { with: /\d{8}@umass.edu/,
                      message: 'must be 8 digits followed by @umass.edu' }
  validates :phone,
            format: { with: /\+1\d{10}/,
                      message: 'must be "+1" followed by 10 digits' }

  def full_name
    "#{first_name} #{last_name}"
  end

  def proper_name
    "#{last_name}, #{first_name}"
  end
end
