# frozen_string_literal: true

json.array! @assignments do |assignment|
  json.id "assignment-#{assignment.id}"
  json.title assignment.user&.last_name || 'Open'
  json.url edit_assignment_path(assignment)
  json.start assignment.start_datetime.to_fs(:iso8601)
  json.end assignment.end_datetime.to_fs(:iso8601)
  json.color("var(--#{assignment.user == Current.user ? 'bs-primary' : 'bs-secondary'})")
end
