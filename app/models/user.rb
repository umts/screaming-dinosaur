class User < ActiveRecord::Base
  has_many :assignments

  validates :first_name, :last_name, :spire, :email, :phone,
            presence: true
  validates :spire, :email, :phone,
            uniqueness: true
  validates :spire,
            format: { with: /\d{8}@umass.edu/,
                      message: 'must be 8 digits followed by @umass.edu' }
  validates :phone,
            format: { with: /\+1\d{10}/,
                      message: 'must be "+1" followed by 10 digits' }
  validates :is_fallback,
            uniqueness: { message: 'may be true for only one user' },
            if: -> { is_fallback }

  def full_name
    "#{first_name} #{last_name}"
  end

  def proper_name
    "#{last_name}, #{first_name}"
  end

  def self.fallback
    User.find_by is_fallback: true
  end
end
