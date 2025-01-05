

function updateTimeAgo() {
    $('[data-fromnow]').each(function () {
        const d = moment($(this).data('fromnow'));
        $(this).html(d.fromNow());
        $(this).attr("title", d.format("dddd, MMMM Do YYYY, h:mm:ss a"));
    });
    setTimeout("updateTimeAgo()", 2000);

}

function openLoginModal(callback, redirect) {
    window.loginRedirect = redirect;
    window.loginCallback = callback; 
    openToModal(bitMin.viewData.loginModalUrl, callback, redirect );
}

function openToModal(url) {
    if (!url.startsWith("http"))
        url = `${location.origin}${url}`;
    $.get(url, function (content) {
        $('#myModalContent').html(content);

        $('#myModalContent').find('script').each(function (ix, el) {
            const script = document.createElement('script');
            script.src = el.src;
//            script.innerText = el.innerText;
            script.async = true;
            document.body.appendChild(script); 
        });

        $('#myModal').modal('show');
    });
}

function navigateToPost(el) {
    const statementId = $(el).closest(".statement-in-list, .reply-parent-in-list").data("statementid") || $(el).data("statementid");

    const url = `${location.origin}${bitMin.viewData.postUrl}/${statementId}`;

    location.href = url; 

}

function statFunc(src, islogin, xcase, statementId) {
    event.stopPropagation();

    const $src = $(src);
    const postUrl = location.origin + bitMin.viewData.postUrl + '/' + statementId;

    switch (xcase) {
        case 'post-id':
        case 'post-replyTo':
            if (islogin)
                timeline.editStatement(statementId, xcase.replace( "post-", "" ));
            else 
                openLoginModal(undefined, postUrl );

            break;
        case 'like':
        case 'repost':
            const myflip = () => flip(xcase, statementId, $src);
            if (islogin)
                myflip();
            else
                openLoginModal(myflip, postUrl);

            break;

    }


}

const interactIcons = {
    like : {
        active: 'bi-star-fill',
        inactive: 'bi-star',
    }, 
    repost: {
        active: 'bi-repeat-1',
        inactive: 'bi-repeat',
    },
}

function flip(what, statementId, $src) {

    const url = `${location.origin}${bitMin.viewData.likeOrRepostUrl}/${what}?statementId=${statementId}`;

    $.get(url ).done(function ( data ) {
        $counter = $src.find(".stat-count");
        $icon = $src.find("i");
        const count = parseInt($counter.html());
        const nuCount = parseInt(data);
        if (nuCount > 0) {
            $src.addClass("placed");
            $icon.removeClass(interactIcons[what].inactive);
            $icon.addClass(interactIcons[what].active);
        }
        else {
            $src.removeClass("placed");
            $icon.removeClass(interactIcons[what].active);
            $icon.addClass(interactIcons[what].inactive);
        }
            
        $counter.html(count + nuCount );
    }).fail(function (data) {
        alertError(data.responseText);
        console.log(data.responseText);
    });      

}

function alertError( data ) {
    const errorMessage = $(data).find("#error-message").html();
    alert( errorMessage || data );
}

$(function () {


    $('[data-bs-toggle="popover"]').popover();

    updateTimeAgo();

});
