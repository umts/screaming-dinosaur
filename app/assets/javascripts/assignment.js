$(function() {
  $('.copy-tooltip').on('click', function() {
    const copyTextarea = $('.copy-text');
    copyTextarea.focus();
    copyTextarea.select();
    let successful = false;
    try {
      successful = document.execCommand('copy');
    } catch (err) {
      console.log('Unable to copy');
    }
    if (successful) {
      const title = 'Copied successfully!';
      $('.copy-tooltip').attr('title', title)
          .tooltip('dispose')
          .tooltip({'title': title})
          .tooltip('show');
    }
  });
});
