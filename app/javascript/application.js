import Rails from '@rails/ujs';
import {Popover} from 'bootstrap';
import './controllers/index.js';

Rails.start();

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach((popoverTriggerEl) => {
    new Popover(popoverTriggerEl);
  });
});
