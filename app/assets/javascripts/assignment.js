$(document).ready(function() {
    // enable bootstrap tooltips
    $("[data-toggle='tooltip']").tooltip('enable');
    var copyTextBtn = $('.copy-text-btn');
    $(copyTextBtn).on('click', function() {
        var copyTextarea = $('.copy-text');
        copyTextarea.focus();
        copyTextarea.select();
        try {
            var successful = document.execCommand('copy');
            console.log('Copied successfully');
        } catch (err) {
            console.log('Unable to copy');
        }
        if(successful === true) {
            $('.copied').attr('title', 'Copied successfully!')
                .tooltip('fixTitle')
                .tooltip('show');
            console.log('Tooltip title updated')
        }
    });
});
