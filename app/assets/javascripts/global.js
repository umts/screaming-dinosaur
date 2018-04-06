$(document).ready(function() {
    var copyTextBtn = document.querySelector('.copy-text-btn');

    copyTextBtn.addEventListener('click', function (event) {
        var copyTextarea = document.querySelector('.copy-text');
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
