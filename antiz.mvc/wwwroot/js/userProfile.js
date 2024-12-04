const userProfile = {

    newFollow: function (targetId) {
        event.stopPropagation();
        const $target = $(event.target);
        $.get( location.origin + bitMin.viewData.newFollowUrl + '/' + targetId)
            .done(function (data) {
                if (data == "done") {
                    $target.html("following");
                    $target.attr("onclick", "");
                }
                if (data == "no_login")
                    openLoginModal();
            })
            .fail(function (data) {
                alertError(data.responseText);
                console.log(data.responseText);
            });

    },



}