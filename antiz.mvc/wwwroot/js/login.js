
var $scrpt = $("#scriptLogin");


$(function () {

    $(".mode-" + $scrpt.data('mode')).hide();
    $("#loginForm input[name='Username'], #loginForm input[name='Password']").on('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            login();
        }
    });

});

function showRegister() {

    $(".mode-login").hide();
    $(".mode-register").show();

    return false;
}


function login() {
    const $form = $("#loginForm");

    if ( $scrpt.data('ismodal') ) {

        var formData = $form.serialize();
        formData += '&act=login&isModal=true';

        $.ajax({
            url: $form.attr('action'),
            type: "POST",
            data: formData,
            success: function (response) {

                if (window.loginCallback)
                    window.loginCallback();

                if (window.loginRedirect != null)
                    location.href = window.loginRedirect;
                else
                    location.reload();
            },
            error: function (xhr) {
                $("#myModalContent").html(xhr.responseText)                
            }
        });
    }
    else
        $form.submit();
}