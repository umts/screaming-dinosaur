# frozen_string_literal: true

module AssIndexHelper

  def cal_day(day:)
    if day == Date.current
      'current-day'
    end
  end

  def cal_ass(assignment:, day:)
    if assignment.present?
      ass = 'ass'
      if assignment.user == @current_user
        ass = 'ass-user'
      end

      if day == assignment.start_date && day == assignment.end_date
        ass += '-only'
      elsif day == assignment.start_date
        ass += '-start'
      elsif day == assignment.end_date
        ass += '-end'
      else
        ass
      end
    end
    ass
  end

end