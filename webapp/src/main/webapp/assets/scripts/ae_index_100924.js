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

var user = "";
var unavail = "Information is unavailable at the moment";

function
aeShowAdvQueryHelp()
{
    $("#dialog").dialog({modal: false, resizable: false});
}

function
aeShowLoginForm()
{
    $("#aer_login_link").hide();
    $("#aer_help_link").hide();
    $("#aer_login_status").text("");
    $("#aer_login_box").show();
    $("#aer_user_field").focus();
}

function
aeHideLoginForm()
{
    $("#aer_login_box").hide();
    $("#aer_login_status").text("");
    if ( "" != user ) {
        $("#aer_login_link").hide();
        $("#aer_login_info strong").text(user);
        $("#aer_login_info").show();
    } else {
        $("#aer_login_link").show();
    }
    $("#aer_help_link").show();
}


function
aeDoLogin()
{
    user = $("#aer_user_field").val();
    var pass = $("#aer_pass_field").val();
    $("#aer_pass_field").val("");
    $("#aer_login_status").text("");
    $("#aer_login_submit").attr("disabled", "true");
    $.get("verify-login.txt", { u: user, p: pass }).next(aeDoLoginNext);
}

function
aeDoLoginNext(text)
{
    if ( "" != text ) {
        $("#aer_login_box").hide();
        $("#aer_login_submit").removeAttr("disabled");

        var loginExpiration = null;
        if ( $("#aer_login_remember").attr("checked") ) {
            loginExpiration = 365;
        }

        $.cookie("AeLoggedUser", user, {expires: loginExpiration, path: '/'});
        $.cookie("AeLoginToken", text, {expires: loginExpiration, path: '/'});

        aeShowLoginInfo();
        $("#aer_help_link").show();
        $("#aer_avail_info").text("Updating data, please wait...");
        updateAeStats();
    } else {
        user = "";
        $("#aer_login_status").text("Incorrect user name or password. Please try again.");
        $("#aer_login_submit").removeAttr("disabled");
        $("#aer_user_field").focus();
    }
}

function
aeShowLoginInfo()
{
    $("#aer_login_info strong").text(user);
    $("#aer_login_info").show();
}

function
aeDoLogout(shouldUpdateStats)
{
    $("#aer_login_info").hide();
    $("#aer_login_link").show();
    $.cookie("AeLoggedUser", null, {path: '/' });
    $.cookie("AeLoginToken", null, {path: '/' });
    user = "";
    if (undefined == shouldUpdateStats || shouldUpdateStats) {
        $("#aer_avail_info").text("Updating data, please wait...");
       updateAeStats();
    }
}

function
aeOnLoad()
{
    // step 0: hack for IE to work with this funny EBI header/footer (to be redeveloped with jQuery)
    if (-1 != navigator.userAgent.indexOf('MSIE')) {
        document.getElementById('head').allowTransparency = true;
        // step 0.5: display a warning for those unlucky who use IE5.x
        if ( -1 != navigator.userAgent.indexOf('MSIE 5')) {
            document.getElementById('ae_jquery_unsupported').style.display = 'block';
        }
    }
}

// runs on page reload after rendering is done
$(document).ready(function()
{
    // footer is hidden by default to prevent its ugly appearance on IE if scripting is disabled
    $("#ebi_footer").show();

    // check if there is a old-fasioned request which
    // we need to dispatch to the new browse interface
    if ("" != window.location.hash) {
        var hash = String(window.location.hash);
        if ( -1 != hash.indexOf("ae-browse") ) {
        var location = "browse.html";
            var pattern = new RegExp("ae-browse\/q=([^\[]*)", "ig");
            var results = pattern.exec(hash);
            if (undefined != results && undefined != results[1]) {
                location = location + "?keywords=" + results[1];
            }
            window.location.href = location;
        }
    }

    // populate species from atlas
    $.get("${interface.application.link.atlas.species_options.url}").next( function(data) {
        $("#atlas_species_field").html(data).removeAttr("disabled");
    });

    // populate stats from atlas
    $.get("${interface.application.link.atlas.stats.url}")
            .next( function(data) {
                data = String(data).replace(/\nAtlas Data Release \d+\.\d+: /, "");
                $("#atlas_avail_info").text(data);
            })
            .error( function() {
                $("#atlas_avail_info").text(unavail);
            });

    var _user = $.cookie("AeLoggedUser");
    var _token = $.cookie("AeLoginToken");
    if ( undefined != _user && undefined != _token ) {
        user = _user;
        $("#aer_login_link").hide();
        aeShowLoginInfo();
    }

    // adds a callback to close a login form on escape
    $("#aer_login_form input").keydown(
            function (e) {
                if (e.keyCode == 27) {
                    aeHideLoginForm();
                }
            }
        );

    updateAeStats();

    // loads news page
    $("#ae_news").load("${interface.application.link.news_xml.url} div ul");

    // loads links page
    $("#ae_links").load("${interface.application.link.links_xml.url} div ul");
    $("#ae_news_links_area").show();
});

function
trimString(stringToTrim)
{
    return String(stringToTrim).replace(/^\s+|\s+$/g, "");
}

function
updateAeStats()
{
    // gets aer stats and updates the page
    $.get("ae-stats.xml").next(onAeStatsSuccess).error(onAeStatsError);
}

function
onAeStatsError()
{
    $("#aer_avail_info").text("");
}

function
onAeStatsSuccess(xml)
{
    var aer_avail_info = unavail;
    if (undefined != xml) {
        var ae_repxml = $($(xml).find("experiments")[0]);
        var etotal = ae_repxml.attr("total");
        var atotal = ae_repxml.attr("total-assays");
        if (etotal != undefined && etotal > 0) {
            aer_avail_info = etotal + " experiments, " + atotal + " assays";
        }
    }
    $("#aer_avail_info").text(aer_avail_info);

    // verifying AeLoggedUser cookie still here
    if ("" != user && $.cookie("AeLoggedUser") != user) {
        // cookie was removed :)
        alert("The session for user " + user + " has expired.");
        aeDoLogout(false);
    }
}

function
getNumDocsFromSolrStats(xml)
{
    return trimString($($(xml).find("stat[name='numDocs']")[0]).text());
}
