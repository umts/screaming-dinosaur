# frozen_string_literal: true

class AssignmentTaker
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :assignment_id, :integer
  attribute :user_id, :integer
  attribute :whole_group, :boolean, default: false

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

  def grouped? = assignment&.assignment_group.present?

  def group_assignments = grouped? ? assignment.assignment_group.assignments : Assignment.none

  def other_group_assignments = group_assignments.reject { |a| a.id == assignment&.id }

  def perform
    perform!
    true
  rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid
    false
  end

  private

  def targets
    whole_group && grouped? ? group_assignments : [assignment]
  end

  def perform!
    validate!
    ActiveRecord::Base.transaction do
      targets.each { |target| target.update!(user_id:) }
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.merge! e.record.errors
    raise e
  end
end
