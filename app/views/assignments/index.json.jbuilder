# frozen_string_literal: true

json.array! @assignments do |assignment|
  json.id "assignment-#{assignment.id}"
  json.title assignment.user&.last_name || 'Open'
  json.url take_assignment_path(assignment)
  json.start assignment.start_datetime.to_fs(:iso8601)
  json.end assignment.end_datetime.to_fs(:iso8601)

  if assignment.user.blank?
    json.className 'event-outline'
    json.contrastColor 'var(--bs-body-color)'
  elsif assignment.user == Current.user
    json.color 'var(--bs-primary)'
  else
    json.color 'var(--bs-secondary-bg)'
    json.contrastColor 'var(--bs-body-color)'
  end
end
