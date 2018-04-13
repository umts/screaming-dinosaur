$(document).ready(function() {
    var copyTextBtn = $('.copy-text-btn');

    $(copyTextBtn).on('click', function() {
        var copyTextarea = $('.copy-text');
        copyTextarea.focus();
        copyTextarea.select();
        try {
            var successful = document.execCommand('copy');
            var msg = successful ? 'successful' : 'unsuccessful';
            console.log('Copying text command was ' + msg);
        } catch (err) {
            console.log('Unable to copy');
        }
    });
});
