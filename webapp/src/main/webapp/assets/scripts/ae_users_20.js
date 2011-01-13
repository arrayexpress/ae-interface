(function($, undefined) {

    if($ == undefined)
        throw "jQuery not loaded";

    $.fn.extend({

        aeLoginForm: function(options) {
            return this.each(function() {
			new $.AELoginForm(this, options);
            });
        }
    });

    $.AELoginForm = function(form, opts) {

        var $form = $(form);
        var $user = $form.find("input[name='u']").first();
        var $pass = $form.find("input[name='p']").first();
        var $remember = $form.find("input[name='r']").first();
        var $submit = $form.find("input[name='s']").first();
        var options = opts
        var $status = $(options.status);

        function doLogin() {
            var pass = $pass.val();

            $pass.val("");
            $status.text("");
            $submit.attr("disabled", "true");
            $.get(options.verifyURL, { u: $user.val(), p: pass }, doLoginNext);
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

    $.fn.extend({

        aePager: function() {
            return this.each(function() {
			new $.AEPager(this);
            });
        }
    });

    $.AEPager = function(elt) {

        var $element = $(elt);
        var curPage = $element.find("#page").first().text();
        var pageSize = $element.find("#page_size").first().text();
        var totalPages = $element.find("#total_pages").first().text();

        if ( totalPages > 1 ) {
            var pagerHtml = "Pages: ";
            for ( var page = 1; page <= totalPages; page++ ) {
                if ( curPage == page ) {
                    pagerHtml = pagerHtml + "<span id=\"current_page\">" + page + "</span>";
                } else if ( 2 == page && curPage > 6 && totalPages > 11 ) {
                    pagerHtml = pagerHtml + "..";
                } else if ( totalPages - 1 == page && totalPages - curPage > 5 && totalPages > 11 ) {
                    pagerHtml = pagerHtml + "..";
                } else if ( 1 == page || ( curPage < 7 && page < 11 ) || ( Math.abs( page - curPage ) < 5 ) || ( totalPages - curPage < 6 && totalPages - page < 10 ) || totalPages == page || totalPages <= 11 ) {
                    var newQuery = $.query.set( "page", page ).set( "pagesize", pageSize ).toString();
                    pagerHtml = pagerHtml + "<a href=\"browse.html" + newQuery + "\">" + page + "</a>";
                }
            }
            $element.html(pagerHtml).show();
        }
    };

    var sortDefault = { id: "ascending"
                      , source: "ascending"
                      , name: "ascending"
                      , email: "ascending"
    };

    var sortTitle =   { id: "user ID"
                      , source: "source"
                      , name: "name"
                      , email: "E-mail address"
    };

    $(function() {
        // this will be executed when DOM is ready
        if ($.query == undefined)
            throw "jQuery.query not loaded";

        // initialize login box
        $("#ae_login_form").aeLoginForm({ status: "#ae_login_status", verifyURL : basePath + "/verify-login.txt" });

        // initialize pager
        $("#ae_results_pager").aePager();

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
