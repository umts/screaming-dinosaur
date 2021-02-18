# frozen_string_literal: true

module ApplicationHelper
  def active_class(link_path)
    'active' if current_page?(link_path)
  end

  def switchover_time(hour)
    Time.current.change(hour: hour).strftime('%-I:%M %P')
  end
end
