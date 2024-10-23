# frozen_string_literal: true

module ApplicationHelper
  def calendar_instructions
    'Use this address to subscribe to this calendar in ' \
      'another application (i.e. Google Calendar).'
  end

  def nav_link_item(text, path)
    tag.li class: 'nav-item' do
      link_to_unless_current text, path, class: 'nav-link' do
        tag.div text, class: 'nav-link active'
      end
    end
  end
end
