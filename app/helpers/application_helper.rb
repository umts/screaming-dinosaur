# frozen_string_literal: true

module ApplicationHelper
  def active_class(link_path)
    'active' if current_page?(link_path)
  end
end
