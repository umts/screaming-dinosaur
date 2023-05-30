$(function() {
  var calendar_container = document.getElementById('calendar');
  if (!calendar_container) { return }

  var calendar = new FullCalendar.Calendar(calendar_container, {
    'themeSystem': 'bootstrap',
    'initialDate': sessionStorage.getItem('lastDate') || null,
    'events': 'assignments.json',
    'startParam': 'start_date',
    'endParam': 'end_date',
    'dayCellClassNames': 'day-empty',
    'eventDidMount': function(info) {
      var date = info.event.start;
      while (date < info.event.end) {
        var dateString = date.toISOString().split('T')[0];
        $('td[data-date=' + dateString + ']').removeClass('day-empty');
        date.setDate(date.getDate() + 1);
      }
    },
    'datesSet': function(info) {
      var currentStart = info.view.currentStart.toISOString();
      sessionStorage.setItem('lastDate', currentStart);
    }
  });

  calendar.render();

  $('#calendar').on('click', 'td.day-empty', function() {
    window.location = 'assignments/new?date=' + $(this).data('date');
  });
});
