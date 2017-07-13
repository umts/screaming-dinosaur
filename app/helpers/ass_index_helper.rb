# frozen_string_literal: true

module AssIndexHelper

  def cal_day(assignment:, day:)
    whatDay = ''

    if assignment.present?
      if @current_user.admin?
        if day == assignment.start_date
          whatDay = 'ass-start'
        elsif day == assignment.end_date
          whatDay = 'ass-end'
        end
      end
      if assignment.user == @current_user
        whatDay += ' ass-week'
      end
    end
    if day == Date.current
      whatDay += ' current-day'
    end
    whatDay
  end
end