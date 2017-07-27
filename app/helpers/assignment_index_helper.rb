# frozen_string_literal: true

module AssignmentIndexHelper
  def cal_day(day:)
    'current-day' if day == Date.current
  end

  def cal_assignment(assignment:, day:)
    return if assignment.blank?
    assign = 'assignment'
    assign += '-user' if assignment.user == @current_user

    if day == assignment.start_date && day == assignment.end_date
      assign + ' assignment-only ' + ' width'
    elsif day == assignment.start_date
      assign + ' assignment-start'
    elsif day == assignment.end_date
      assign + ' assignment-end ' + ' width'
    else
      assign
    end
  end
end
