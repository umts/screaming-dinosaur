import Rails from '@rails/ujs';
import {Tooltip} from 'bootstrap';
import './controllers/index.js';

Rails.start();

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((tooltipTriggerEl) => {
    new Tooltip(tooltipTriggerEl);
  });
});
