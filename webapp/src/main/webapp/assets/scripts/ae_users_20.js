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

(function($, undefined) {

    if($ == undefined)
        throw "jQuery not loaded";

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
        $("#ae_login_form").aeLoginForm({ status: "#ae_login_status", verifyURL : contextPath + "/verify-login.txt" });

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
