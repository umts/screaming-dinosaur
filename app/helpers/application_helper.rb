# frozen_string_literal: true

module ApplicationHelper
  def active_class(link_path)
    return 'active' unless current_page?(link_path)
    end
  end
end
