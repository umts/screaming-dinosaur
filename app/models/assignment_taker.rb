# frozen_string_literal: true

class AssignmentTaker
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :assignment_id, :integer
  attribute :user_id, :integer
  attribute :group, :boolean, default: false

  validates :assignment, presence: true
  validates :user, presence: true

  def assignment
    return @assignment if defined?(@assignment)

    @assignment = Assignment.find_by(id: assignment_id)
  end

  def user
    return @user if defined?(@user)

    @user = User.find_by(id: user_id)
  end

  def perform!
    validate!
    ActiveRecord::Base.transaction { assignments.each { |assignment| assignment.update!(user:) } }
  end

  private

  def assignments
    assignment.assignment_group.present? && group ? assignment.assignment_group.assignments : [assignment]
  end
end
