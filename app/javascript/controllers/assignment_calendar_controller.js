import {Calendar} from '@fullcalendar/core';
import bootstrap5Plugin from '@fullcalendar/bootstrap5';
import dayGridPlugin from '@fullcalendar/daygrid';
import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    eventsUrl: String,
    newAssignmentUrl: String,
  };

  connect() {
    const calendar = new Calendar(this.element, {
      plugins: [dayGridPlugin, bootstrap5Plugin],
      themeSystem: 'bootstrap5',
      buttonIcons: {
        prev: 'fa fa fa-chevron-left',
        next: 'fa fa fa-chevron-right',
      },
      buttonText: {
        today: 'Today',
      },
      initialDate: sessionStorage.getItem('lastDate') || null,
      events: this.eventsUrlValue,
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

    this.element.addEventListener('click', (e) => {
      const dayElement = e.target.closest('td.day-empty');
      if (dayElement) {
        window.location = `${this.newAssignmentUrlValue}?date=` + dayElement.dataset.date;
      }
    });
  }
}
