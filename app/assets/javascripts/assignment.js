$(document).ready(function() {
  // Enable bootstrap tooltips
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))

  $('.copy-tooltip').on('click', function() {
    var copyTextarea = $('.copy-text');
    copyTextarea.focus();
    copyTextarea.select();
    try {
      var successful = document.execCommand('copy');
    } catch (err) {
      console.log('Unable to copy');
    }
    if (successful) {
      var title = 'Copied successfully!';
      $('.copy-tooltip').attr('title', title)
        .tooltip('dispose')
        .tooltip({'title': title})
        .tooltip('show');
    }
  });
});
