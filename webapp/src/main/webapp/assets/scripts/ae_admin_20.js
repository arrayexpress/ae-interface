/*
 * Copyright 2009-2010 European Molecular Biology Laboratory
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

    $(function() {
        // this will be executed when DOM is ready

        $("#ae_login_form").aeLoginForm("#ae_login_status");
    });

})(window.jQuery);
