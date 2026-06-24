# frozen_string_literal: true

current_user = @roster.on_call_user
current_assignment = @roster.current_assignment
next_assignment = current_assignment&.next

json.extract! @roster, :id, :name, :slug, :phone
if current_user.present?
  json.on_call do
    json.extract! current_user, :last_name, :first_name
    json.until current_assignment&.end_datetime&.iso8601
  end
else
  json.on_call nil
end
if next_assignment&.user.present?
  json.upcoming do
    json.extract! next_assignment.user, :last_name, :first_name
  end
end
