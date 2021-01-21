# frozen_string_literal: true

module ApplicationHelper
  def nav_link_item(text, path)
    classes = %w[nav-item mx-2]
    classes << 'active' if current_page?(path)
    content_tag 'li', class: classes do
       link_to text, path, class: 'nav-link'
    end
  end
end
