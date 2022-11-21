# frozen_string_literal: true

json.array! @assignments do |assignment|
  json.id "assignment-#{assignment.id}"
  json.title assignment.user.last_name
  json.url edit_roster_assignment_path(@roster, assignment)
  json.allDay true
  json.start assignment.start_date.to_fs(:iso8601)
  json.end 1.day.after(assignment.end_date).to_fs(:iso8601)
  json.color("var(--#{assignment.user == @current_user ? :info : :secondary})")
end
