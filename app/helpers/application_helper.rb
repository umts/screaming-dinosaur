# frozen_string_literal: true

module ApplicationHelper
  def calendar_instructions
    'Use this address to subscribe to this calendar in ' \
      'another application (i.e. Google Calendar).'
  end

  def nav_link_item(text, path)
    tag.li class: 'nav-item' do
      link_to text, path, class: current_page?(path) ? 'nav-link active' : 'nav-link'
    end
  end

  def switchover_time(hour)
    Time.current.change(hour: hour).strftime('%-I:%M %P')
  end
end
