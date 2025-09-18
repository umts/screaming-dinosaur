document.addEventListener('DOMContentLoaded', () => {
  const calendarContainer = document.querySelector('#calendar');
  if (!calendarContainer) {
    return;
  }

  const calendar = new FullCalendar.Calendar(calendarContainer, {
    themeSystem: 'bootstrap5',
    buttonIcons: {
      prev: 'fa fa fa-chevron-left',
      next: 'fa fa fa-chevron-right',
    },
    initialDate: sessionStorage.getItem('lastDate') || null,
    events: 'assignments.json',
    startParam: 'start_date',
    endParam: 'end_date',
    dayCellClassNames: 'day-empty',
    eventDidMount: function(info) {
      const date = info.event.start;
      while (date < info.event.end) {
        const dateString = date.toISOString().split('T')[0];
        document.querySelectorAll(`td[data-date="${dateString}"]`).forEach((td) => {
          td.classList.remove('day-empty');
        });
        date.setDate(date.getDate() + 1);
      }
    },
    datesSet: function(info) {
      const currentStart = info.view.currentStart.toISOString();
      sessionStorage.setItem('lastDate', currentStart);
    },
  });

  calendar.render();

  calendarContainer.addEventListener('click', (e) => {
    const dayElement = e.target.closest('td.day-empty');
    if (dayElement) {
      window.location = 'assignments/new?date=' + dayElement.dataset.date;
    }
  });
});
