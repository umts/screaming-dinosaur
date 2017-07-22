# frozen_string_literal: true

module AssignmentIndexHelper
  def cal_day(day:)
    'current-day' if day == Date.current
  end

  def cal_assignment(assignment:, day:)
    return if assignment.blank?
    ass = 'assignment'
    ass += '-user' if assignment.user == @current_user

    if day == assignment.start_date && day == assignment.end_date
      ass + ' assignment-only ' + ' width'
    elsif day == assignment.start_date
      ass + ' assignment-start'
    elsif day == assignment.end_date
      ass + ' assignment-end ' + ' width'
    else
      ass
    end
  end
end
