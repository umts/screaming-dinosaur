import {Calendar} from 'fullcalendar';
import bootstrap5Plugin from '@fullcalendar/bootstrap5';
import dayGridPlugin from 'fullcalendar/daygrid';
import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static values = {eventsUrl: String};

  connect() {
    const calendar = new Calendar(this.element, {
      plugins: [dayGridPlugin, bootstrap5Plugin],
      headerToolbar: {
        start: 'title',
        end: 'today prev,next',
      },
      buttons: {
        today: {text: 'Today'},
        prev: {iconClass: 'fa-solid fa-chevron-left'},
        next: {iconClass: 'fa-solid fa-chevron-right'},
      },
      initialDate: sessionStorage.getItem('lastDate') || null,
      events: this.eventsUrlValue,
      startParam: 'start_date',
      endParam: 'end_date',
      nextDayThreshold: '05:00',
      eventDisplay: 'block',
      eventClass: 'calendar-event',
      toolbarTitleClass: 'calendar-title',
      eventSourceFailure: function(error) {
        if (error.response.status === 403) {
          window.location.replace(window.location.origin);
        } else if (error.response.status === 401) {
          window.location.reload();
        } else {
          alert('Something has gone wrong. IT has been notified. Contact them if the problem persists.');
        }
      },
      datesSet: function(info) {
        const currentStart = info.view.currentStart.toISOString();
        sessionStorage.setItem('lastDate', currentStart);
      },
    });

    calendar.render();
  }
}
