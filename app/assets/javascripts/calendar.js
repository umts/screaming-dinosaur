var calendar
$(document).ready(function() {
  var calendar_container = document.getElementById('calendar');
  if (!calendar_container) { return }

  calendar = new FullCalendar.Calendar(calendar_container, {
    'events': 'assignments.json',
    'startParam': 'start_date',
    'endParam': 'end_date',
    'dateClick': function(info) {
      var eventOnDay = calendar.getEvents().find(function(event) {
        return event.start <= info.date && info.date < event.end;
      })
      if (eventOnDay === undefined) {
        console.log('Create New Assignment');
      }
    }
  });
  calendar.render();
});
