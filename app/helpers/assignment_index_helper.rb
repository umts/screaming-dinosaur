# frozen_string_literal: true

module AssignmentIndexHelper
  def cal_day(day:)
    'current-day' if day == Date.current
  end

  def cal_assignment(assignment:, day:)
    return if assignment.blank?

    [base_assignment_class(assignment),
     width_assignment_class(assignment, day)].join(' ')
  end

  def base_assignment_class(assignment)
    if assignment.user == @current_user
      'assignment-user'
    else 'assignment'
    end
  end

  def width_assignment_class(assignment, date)
    if date == assignment.start_date && date == assignment.end_date
      'assignment-only width'
    elsif date == assignment.start_date
      'assignment-start'
    elsif date == assignment.end_date
      'assignment-end width'
    else ''
    end
  end
end
