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

    var sortDefault = { accession: "ascending"
                      , name: "ascending"
                      , assays: "descending"
                      , species: "ascending"
                      , releasedate: "descending"
                      , fgem: "descending"
                      , raw: "descending"
                      , atlas: "descending"
    };
    
    var sortTitle =   { accession: "accession"
                      , name: "title"
                      , assays: "number of assays"
                      , species: "species"
                      , releasedate: "release date"
                      , fgem: "number of assays in processed data"
                      , raw: "number of assays in raw data"
                      , atlas: "presence of experiment data in Gene Expression Atlas"
    };

    $(function() {
        // this will be executed when DOM is ready
        if ($.query == undefined)
            throw "jQuery.query not loaded";

        var sortby = $.query.get("sortby") || "releasedate";
        var sortorder = $.query.get("sortorder") || "descending";

        var pageName = /\/?([^\/]+)$/.exec(decodeURI(window.location.pathname))[1];

        $("th.sortable").each( function() {
            var thisObj = $(this);
            var colname = /col_(\w+)/.exec(thisObj.attr("class"))[1];

            // so the idea is to set default sorting for all columns except the "current" one
            // (which will be inverted) against its current state
            var newOrder = (colname === sortby) ? ("ascending" === sortorder ? "descending" : "ascending"): sortDefault[colname];
            var queryString = $.query.set("sortby", colname).set("sortorder", newOrder).toString();

            thisObj.wrapInner("<a href=\"" + pageName + queryString + "\" title=\"Click to sort by " + sortTitle[colname] + "\"/>");
        });


    });

})(window.jQuery);
