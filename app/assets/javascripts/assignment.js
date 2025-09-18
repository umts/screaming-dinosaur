document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.copy-tooltip').forEach((tooltip) => {
    const prompt = tooltip.dataset.bsTitle;

    tooltip.addEventListener('click', () => {
      bootstrap.Tooltip.getInstance(tooltip).dispose();
      navigator.clipboard.writeText(tooltip.dataset.content).then(() => {
        tooltip.dataset.bsTitle = tooltip.dataset.success;
      }).catch(() => {
        tooltip.dataset.bsTitle = tooltip.dataset.error;
      }).finally(() => {
        new bootstrap.Tooltip(tooltip).show();
      });
    });

    tooltip.addEventListener('hidden.bs.tooltip', () => {
      bootstrap.Tooltip.getInstance(tooltip).dispose();
      tooltip.dataset.bsTitle = prompt;
      new bootstrap.Tooltip(tooltip);
    });
  });
});
