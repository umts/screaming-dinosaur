import Rails from '@rails/ujs';
import {Tooltip} from 'bootstrap';
import './calendar.js';
import './controllers/index.js';
import './copyTooltip.js';

Rails.start();

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((tooltipTriggerEl) => {
    new Tooltip(tooltipTriggerEl);
  });
});
