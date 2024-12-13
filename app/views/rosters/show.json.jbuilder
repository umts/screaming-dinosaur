# frozen_string_literal: true

json.extract! @roster, :id, :name, :slug, :phone
if (user = @roster.on_call_user).present?
  json.on_call do
    json.extract! user, :last_name, :first_name
    json.until @roster.assignments.current&.effective_end_datetime
  end
else
  json.on_call nil
end
if @upcoming.present?
  json.upcoming do
    json.extract! @upcoming.first.user, :last_name, :first_name
  end
end
