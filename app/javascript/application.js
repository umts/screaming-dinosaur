import {Tooltip} from 'bootstrap';

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((tooltipTriggerEl) => {
    new Tooltip(tooltipTriggerEl);
  });
});
