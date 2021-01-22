json.array! @assignments do |assignment|
  json.id "assignment-#{assignment.id}"
  json.title assignment.user.last_name
  json.url edit_roster_assignment_path(@roster, assignment)
  json.allDay true
  json.start assignment.start_date.to_s(:iso8601)
  json.end 1.day.after(assignment.end_date).to_s(:iso8601)

  color = (assignment.user == @current_user ? '#ece9d4' : '#d9edf7')
  json.borderColor color
  json.backgroundColor color
  json.textColor '#337ab7'
end
