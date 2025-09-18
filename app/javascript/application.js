import {Tooltip} from 'bootstrap';
import './calendar.js';
import './copyTooltip.js';

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((tooltipTriggerEl) => {
    new Tooltip(tooltipTriggerEl);
  });
});
