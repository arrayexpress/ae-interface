(function($, undefined) {

    if($ == undefined)
        throw "jQuery not loaded";

    $.fn.extend({

        aeLoginForm: function(status) {
            return this.each(function() {
			new $.AELoginForm(this, status);
            });
        }
    });

    $.AELoginForm = function(form, status) {

        var $form = $(form);
        var $user = $form.find("input[name='u']").first();
        var $pass = $form.find("input[name='p']").first();
        var $remember = $form.find("input[name='r']").first();
        var $submit = $form.find("input[name='s']").first();
        var $status = $(status);

        function doLogin() {
            var pass = $pass.val();

            $pass.val("");
            $status.text("");
            $submit.attr("disabled", "true");
            $.get("verify-login.txt", { u: $user.val(), p: pass }, doLoginNext);
        }

        function doLoginNext(text) {
            $submit.removeAttr("disabled");
            if ( "" != text ) {
                var loginExpiration = null;
                if ( $remember.attr("checked") ) {
                    loginExpiration = 365;
                }

                $.cookie("AeLoggedUser", $user.val(), {expires: loginExpiration, path: '/'});
                $.cookie("AeLoginToken", text, {expires: loginExpiration, path: '/'});

                window.location.href = decodeURI(window.location.pathname);
            } else {
                $status.text("Incorrect user name or password. Please try again.");
                $user.focus();
            }
        }

        $(form).submit(function() {
            doLogin();
            return false;
        });

        $user.focus();
    };

    var sortDefault = { id: "ascending"
                      , name: "ascending"
                      , email: "ascending"
    };

    var sortTitle =   { id: "user ID"
                      , name: "name"
                      , email: "E-mail address"
    };

    $(function() {
        // this will be executed when DOM is ready
        if ($.query == undefined)
            throw "jQuery.query not loaded";

        // initialize login box
        $("#ae_login_form").aeLoginForm("#ae_login_status");

        var sortby = $.query.get("sortby") || "releasedate";
        var sortorder = $.query.get("sortorder") || "descending";

        var localPath = /(\/.+)$/.exec(decodeURI(window.location.pathname))[1];

        $("th.sortable").each( function() {
            var thisObj = $(this);
            var colname = /col_(\w+)/.exec(thisObj.attr("class"))[1];

            // so the idea is to set default sorting for all columns except the "current" one
            // (which will be inverted) against its current state
            var newOrder = (colname === sortby) ? ("ascending" === sortorder ? "descending" : "ascending"): sortDefault[colname];
            var queryString = $.query.set("sortby", colname).set("sortorder", newOrder).toString();

            thisObj.wrapInner("<a href=\"" + localPath + queryString + "\" title=\"Click to sort by " + sortTitle[colname] + "\"/>");
        });


    });

})(window.jQuery);
