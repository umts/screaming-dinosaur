import { Calendar } from "fullcalendar";
import bootstrap5Plugin from "@fullcalendar/bootstrap5";
import dayGridPlugin from "fullcalendar/daygrid";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    eventsUrl: String,
    newAssignmentUrl: String,
  };

  connect() {
    const calendar = new Calendar(this.element, {
      plugins: [dayGridPlugin, bootstrap5Plugin],
      headerToolbar: {
        start: "title",
        end: "today prev,next",
      },
      buttons: {
        today: { text: "Today" },
        prev: { iconClass: "fa-solid fa-chevron-left" },
        next: { iconClass: "fa-solid fa-chevron-right" },
      },
      initialDate: sessionStorage.getItem("lastDate") || null,
      events: this.eventsUrlValue,
      startParam: "start_date",
      endParam: "end_date",
      dayCellClass: "calendar-day calendar-day-empty",
      toolbarTitleClass: "calendar-title",
      eventDidMount: function (info) {
        const date = info.event.start;
        while (date < info.event.end) {
          const dateString = date.toISOString().split("T")[0];
          document.querySelectorAll(`.calendar-day[data-date="${dateString}"]`).forEach((td) => {
            td.classList.remove("calendar-day-empty");
          });
          date.setDate(date.getDate() + 1);
        }
      },
      eventSourceFailure: function (error) {
        if (error.response.status === 403) {
          window.location.replace(window.location.origin);
        } else if (error.response.status === 401) {
          window.location.reload();
        } else {
          alert(
            "Something has gone wrong. IT has been notified. Contact them if the problem persists.",
          );
        }
      },
      datesSet: function (info) {
        const currentStart = info.view.currentStart.toISOString();
        sessionStorage.setItem("lastDate", currentStart);
      },
    });

    calendar.render();

    this.element.addEventListener("click", (e) => {
      const dayElement = e.target.closest(".calendar-day-empty");
      if (dayElement) {
        window.location = `${this.newAssignmentUrlValue}?date=` + dayElement.dataset.date;
      }
    });
  }
}
