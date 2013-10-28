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

    $.extend($.fn, {
        aeSVGFallback: function () {
            /*
             * SVG test from Modernizr
             * @see https://github.com/Modernizr/Modernizr/blob/master/feature-detects/svg-svg.js
             */
            if (!!document.createElementNS &&
                !!document.createElementNS('http://www.w3.org/2000/svg', 'svg').createSVGRect)
                return

            var check_svg = new RegExp("(.+)(\\.svg)");
            this.each(function (index, element) {
                if (!$(element).attr('src') || !check_svg.test($(element).attr('src'))) return;
                var png_src = $(element).attr('src').replace(/(\.svg)$/, ".png");
                $.ajax({url:png_src, type:"HEAD", success:function () {
                    $(element).attr('src', png_src);
                }});
            });
            return this;
        }
    })

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
        var $login_form = $window.find("form").first();
        var $user = $login_form.find("input[name='u']").first();
        var $pass = $login_form.find("input[name='p']").first();
        var $open = $(options.open).first();
        var $close = $(options.close).first();
        var $status = $(options.status);
        var $status_text = $("<span class='alert'/>").appendTo($status);
        var $forgot = $(options.forgot).first();
        var $forgot_form = $window.find("form").last();
        var $email = $forgot_form.find("input[name='e']").first();
        var $accession = $forgot_form.find("input[name='a']").first();

        function verifyLoginValues() {
            if ("" == $user.val()) {
                showStatus("User name should not be empty");
                $user.focus();
                return false;
            }

            if ("" == $pass.val()) {
                showStatus("Password should not be empty");
                $pass.focus();
                return false;
            }

            hideStatus();
            return true;
        }

        function verifyForgotValues() {

            if ("" == $email.val()) {
                showStatus("User name or email should not be empty");
                $email.focus();
                return false;
            }

            if ("" == $accession.val()) {
                showStatus("Accession should not be empty");
                $accession.focus();
                return false;
            }

            if (-1 == ("=" + $accession.val() + "=").search(new RegExp("=[ae]-[a-z]{4}-[0-9]+=", "i"))) {
                showStatus("Incorrect accession format (should be E-xxxx-nnnn)");
                $accession.focus();
                return false;
            }

            hideStatus();
            return true;
        }

        function isLoggedIn() {
            return (undefined != $.cookie("AeLoggedUser") && undefined != $.cookie("AeLoginToken"));
        }

        function clearCookies() {
            $.cookie("AeAuthMessage", null, {path: '/' });
            $.cookie("AeAuthUser", null, {path: '/' });
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
            hideForgotPanel();
            $window.show();
        }

        function doCloseWindow() {
            $window.unbind("click", onWindowClick);
            $body.unbind("click", doCloseWindow);
            $window.hide();
            hideStatus();
        }

        function onWindowClick(e) {
            e.stopPropagation();
        }

        function showStatus(text) {
            $status_text.text(text);
            $status.show();
        }

        function hideStatus() {
            $status.hide();
            $status_text.text();
        }

        function showForgotPanel() {
            $login_form.hide();
            $forgot_form.show();
            $forgot_form.find("input").first().focus();
        }

        function hideForgotPanel() {

            $forgot_form.hide();
            $forgot_form.find("input").first().val("");
            $login_form.show();
        }

        $login_form.submit(function() {
            return verifyLoginValues();
        });

        $forgot_form.submit(function() {
            return verifyForgotValues();
        });

        $open.click(function (e) {
            e.preventDefault();
            e.stopPropagation();
            if (isLoggedIn()) {
                doLogout();
            } else {
                doOpenWindow();
                $user.focus();
            }
        });

        $close.click(function (e) {
            e.preventDefault();
            doCloseWindow();
        });

        $forgot.find("a").click(function (e) {
            e.preventDefault();
            hideStatus();
            showForgotPanel();
        });

        $window.find("input").keydown(function (e) {
            if (27 == e.keyCode) {
                doCloseWindow();
            }
        });

        var message = $.cookie("AeAuthMessage");
        if (undefined != message) {
            var username = $.cookie("AeAuthUser");
            clearCookies();
            if (undefined != username) {
                $user.val(username);
            }
            showStatus(message.replace(/^"?(.+[^"])"?$/g, "$1"));
            doOpenWindow();
            if (undefined != username) {
                $pass.focus();
            } else {
                $user.focus();
            }
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
        $('.svg').aeSVGFallback();

        initPersistentHeaders();
        $("#ae-login").aeLoginForm({
            open: "li.login a",
            close: "#ae-login-close",
            status: ".ae-login-status",
            forgot: "#ae-login-forgot"
        });
        $("#ae-feedback").aeFeedbackForm({
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
        var $data = $("#ae-content");
        $data.find(".text-hit").attr("title", "This is exact string matched for input query terms");
        $data.find(".text-syn").attr("title", "This is synonym matched from Experimental Factor Ontology e.g. neoplasia for cancer");
        $data.find(".text-efo").attr("title", "This is matched child term from Experimental Factor Ontology e.g. brain and subparts of brain");

    });

})(window.jQuery);
