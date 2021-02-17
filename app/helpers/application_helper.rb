# frozen_string_literal: true

module ApplicationHelper
  def active_class(link_path)
    'active' if current_page?(link_path)
  end

  def switchover_time(hour)
    Time.new.change(hour: hours).strftime('%I:%M %p')
  end
end
