/*
 * Copyright 2009-2013 European Molecular Biology Laboratory
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

(function ($, undefined) {
    if ($ == undefined) {
        throw "jQuery not loaded";
    }

    $.fn.extend({

        aeLoginForm: function(options) {
            return this.each(function() {
			    new $.AELoginForm(this, options);
            });
        }
    });

    $.AELoginForm = function(loginWindow, options) {

        var $body = $("body");
        var $window = $(loginWindow);
        var $form = $window.find("form").first();
        var $user = $form.find("input[name='u']").first();
        var $pass = $form.find("input[name='p']").first();
        var $submit = $form.find("input[type='submit']").first();
        var $open = $(options.open).first();
        var $close = $(options.close).first();
        var $status = $(options.status).first();

        function verifyLoginValues() {
            var user = $user.val();
            var pass = $pass.val();

            $submit.attr("disabled", "true");

            if ("" == user) {
                $status.text("User name should not be empty.");
                $user.focus();
                $submit.removeAttr("disabled");
                return false;
            }

            if ("" == pass) {
                $status.text("Password should not be empty.");
                $pass.focus();
                $submit.removeAttr("disabled");
                return false;
            }

            $status.text();
            return true;
        }

        function isLoggedIn() {
            return (undefined != $.cookie("AeLoggedUser") && undefined != $.cookie("AeLoginToken"));
        }

        function clearCookies() {
            $.cookie("AeAuthMessage", null, {path: '/' });
            $.cookie("AeLoggedUser", null, {path: '/' });
            $.cookie("AeLoginToken", null, {path: '/' });
        }

        function doLogout() {
            clearCookies();
            doReload();
        }

        function doReload() {
            window.location.href = window.location.href;
        }

        function doOpenWindow() {
            $body.bind("click", doCloseWindow);
            $window.bind("click", onWindowClick);

            $submit.removeAttr("disabled");
            $window.show();
            $user.focus();
        }

        function doCloseWindow() {
            $window.unbind("click", onWindowClick);
            $body.unbind("click", doCloseWindow);
            $window.hide();
            $status.text("");
        }

        function onWindowClick(e) {
            e.stopPropagation();
        }

        $form.submit(function() {
            return verifyLoginValues();
        });

        $open.click(function (e) {
            e.preventDefault();
            e.stopPropagation();
            if (isLoggedIn()) {
                doLogout();
            } else {
                doOpenWindow();
            }
        });

        $close.click(function (e) {
            e.preventDefault();
            doCloseWindow();
        });

        $form.find("input").keydown(function (e) {
            if (27 == e.keyCode) {
                doCloseWindow();
            }
        });

        var message = $.cookie("AeAuthMessage");
        if (undefined != message) {
            var username = $.cookie("AeLoggedUser");
            clearCookies();
            $user.val(username);
            $status.html(message.replace(/^"?(.+[^"])"?$/g, "$1"));
            doOpenWindow();
        }
    };

    $.fn.extend({

        aeFeedbackForm: function(options) {
            return this.each(function() {
                new $.AEFeedbackForm(this, options);
            });
        }
    });

    $.AEFeedbackForm = function(feedbackWindow, options) {

        var $body = $("body");
        var $window = $(feedbackWindow);
        var $form = $window.find("form").first();
        var $message = $form.find("textarea[name='m']").first();
        var $email = $form.find("input[name='e']").first();
        var $page = $form.find("input[name='p']").first();
        var $ref = $form.find("input[name='r']").first();
        var $submit = $form.find("input[type='submit']").first();
        var $open = $(options.open).first();
        var $close = $(options.close).first();


        function doOpenWindow() {
            $body.bind("click", doCloseWindow);
            $window.bind("click", onWindowClick);

            $submit.removeAttr("disabled");
            $window.show();
            $message.val("").focus();
        }

        function doCloseWindow() {
            $window.unbind("click", onWindowClick);
            $body.unbind("click", doCloseWindow);
            $window.hide();
        }

        function onWindowClick(e) {
            e.stopPropagation();
        }

        $form.submit(function() {
            $submit.attr("disabled", "true");
            $.post( contextPath + "/feedback"
                , {m : $message.val(), e : $email.val(), p : $page.val(), r : $ref.val()}
            ).always(function() {
                doCloseWindow();
            });
        });

        $open.click(function (e) {
            e.preventDefault();
            e.stopPropagation();
            doOpenWindow();
        });

        $close.click(function (e) {
            e.preventDefault();
            doCloseWindow();
        });

        $form.find("input,textarea").keydown(function (e) {
            if (27 == e.keyCode) {
                doCloseWindow();
            }
        });
    };

    $.fn.extend({

        aeBrowseSorting: function(options) {
            return this.each(function() {
                new $.AEBrowseSorting(this, options);
            });
        }
    });

    $.AEBrowseSorting =  function(column, options) {
        if ($.query == undefined) {
            throw "jQuery.query not loaded";
        }

        var $column = $(column);

        var sortby = $.query.get("sortby") || options.defaultField;
        var sortorder = $.query.get("sortorder") || options.fields[options.defaultField].sort;

        var pageName = /\/?([^\/]*)$/.exec(decodeURI(window.location.pathname))[1];

        var colname = /col_(\w+)/.exec($column.attr("class"))[1];

        // so the idea is to set default sorting for all columns except the "current" one
        // (which will be inverted) against its current state
        var newOrder = (colname === sortby) ? ("ascending" === sortorder ? "descending" : "ascending"): options.fields[colname].sort;
        var queryString = $.query.set("sortby", colname).set("sortorder", newOrder).toString();

        $column.wrapInner("<a href=\"" + pageName + queryString + "\" title=\"Click to sort by " + options.fields[colname].title + "\"/>");
    };

    function updateTableHeaders() {
        $(".persist-area").each(function() {

            var el             = $(this),
                offset         = el.offset(),
                scrollTop      = $(window).scrollTop(),
                floatingHeader = $(".floating-header", this),
                width          = floatingHeader.prev().width();


            if ((scrollTop > offset.top) && (scrollTop < offset.top + el.height())) {
                floatingHeader.css({
                    "visibility": "visible",
                    "width": width
                });
            } else {
                floatingHeader.css({
                    "visibility": "hidden"
                });
            }
        });
    }

    function resizeTableHeaders() {
        $(".persist-area").each(function() {

            var floatingHeader = $(".floating-header", this),
                width          = floatingHeader.prev().width();


            if ("visible" == floatingHeader.css("visibility")) {
                floatingHeader.css({
                    "visibility": "visible",
                    "width": width
                });
            }
        });
    }

    function initPersistentHeaders()
    {
        var clonedHeaderRow;

        $(".persist-area").each(function() {
            clonedHeaderRow = $(".persist-header", this);
            clonedHeaderRow
                .before(clonedHeaderRow.clone())
                .addClass("floating-header");

        });

        $(window)
            .scroll(updateTableHeaders)
            .resize(resizeTableHeaders)
            .trigger("scroll");
    }


    $.aeFeedback = function(e) {
        e.preventDefault();
        e.stopPropagation();
        $("li.feedback a").click();
    };

    $(function() {
        initPersistentHeaders();
        $("#ae-login-window").aeLoginForm({
            open: "li.login a",
            close: "#ae-login-close",
            status: "#ae-login-status"
        });
        $("#ae-feedback-window").aeFeedbackForm({
            open: "li.feedback a",
            close: "#ae-feedback-close"
        });

        var autoCompleteFixSet = function() {
            $(this).attr('autocomplete', 'off');
        };
        var autoCompleteFixUnset = function() {
            $(this).removeAttr('autocomplete');
        };

        $("#local-searchbox").autocomplete(
            contextPath + "/keywords.txt"
            , { matchContains: false
                , selectFirst: false
                , scroll: true
                , max: 50
                , requestTreeUrl: contextPath + "/efotree.txt"
            }
        ).focus(autoCompleteFixSet).blur(autoCompleteFixUnset).removeAttr('autocomplete');

        // attach titles to highlight classes
        var $browse_data = $("#ae-browse").find("td");
        $browse_data.find(".text-hit").attr("title", "This is exact string matched for input query terms");
        $browse_data.find(".text-syn").attr("title", "This is synonym matched from Experimental Factor Ontology e.g. neoplasia for cancer");
        $browse_data.find(".text-efo").attr("title", "This is matched child term from Experimental Factor Ontology e.g. brain and subparts of brain");

    });

})(window.jQuery);
