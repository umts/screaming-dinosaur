$(function() {
  // Enable bootstrap tooltips
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(
    function(tooltipTriggerNode) {
      new bootstrap.Tooltip(tooltipTriggerNode);
    }
  );

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
