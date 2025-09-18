import {Tooltip} from 'bootstrap';

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.copy-tooltip').forEach((tooltip) => {
    const prompt = tooltip.dataset.bsTitle;

    tooltip.addEventListener('click', () => {
      console.log('HI');
      Tooltip.getInstance(tooltip).dispose();
      navigator.clipboard.writeText(tooltip.dataset.content).then(() => {
        tooltip.dataset.bsTitle = tooltip.dataset.success;
      }).catch(() => {
        tooltip.dataset.bsTitle = tooltip.dataset.error;
      }).finally(() => {
        new Tooltip(tooltip).show();
      });
    });

    tooltip.addEventListener('hidden.bs.tooltip', () => {
      Tooltip.getInstance(tooltip).dispose();
      tooltip.dataset.bsTitle = prompt;
      new Tooltip(tooltip);
    });
  });
});
