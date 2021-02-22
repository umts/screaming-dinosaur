# frozen_string_literal: true

module ApplicationHelper
  def calendar_instructions
    'Use this address to subscribe to this calendar in ' \
    'another application (i.e. Google Calendar).'
  end

  def nav_link_item(text, path)
    classes = %w[nav-item mx-2]
    classes << 'active' if current_page?(path)
    content_tag 'li', class: classes do
       link_to text, path, class: 'nav-link'
    end
  end

  def switchover_time(hour)
    Time.current.change(hour: hour).strftime('%-I:%M %P')
  end
end
