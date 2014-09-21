/*
 * Copyright 2009-2014 European Molecular Biology Laboratory
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

    var query = new Object();

    function
    addHtmlToSelect( selectElt, html )
    {
        if ( $.browser.opera ) {
            var htmlParsed = $.clean( new Array(html) );
            var select = $( selectElt ).empty();
            for ( var i = 0; i < htmlParsed.length; i++ ) {
                select[0].appendChild(htmlParsed[i].cloneNode(true));
            }
        } else {
            $( selectElt ).html(html);
        }
    }

    function
    getQueryStringParam( paramName, defaultValue )
    {
        var param = $.query.get(paramName);
        if ("" !== param) {
            return param;
        } else {
            return defaultValue;
        }
    }

    function
    getQueryArrayParam( paramName )
    {
        var param = $.query.get(paramName);
        if (!jQuery.isArray(param)) {
            return new Array(param);
        } else {
            return param;
        }
    }

    function
    getQueryBooleanParam( paramName )
    {
        var param = $.query.get(paramName);
        return (true === param || "" != param) ? true : undefined;
    }

    $(function() {
        $("th.sortable").aeBrowseSorting({
            defaultField: "releasedate"
            , fields:
                { accession: { title: "accession", sort : "ascending" }
                , name: { title: "title", sort: "ascending" }
                , type: { title: "experiment type", sort: "ascending" }
                , assays: { title: "number of assays", sort: "descending" }
                , organism: { title: "organism", sort: "ascending" }
                , releasedate: { title: "release date", sort: "descending" }
                , processed: { title: "number of assays in processed data", sort: "descending" }
                , raw: { title: "number of assays in raw data", sort: "descending" }
                , atlas: { title: "presence of experiment data in Gene Expression Atlas", sort: "descending" }
                , views: { title: "number of views", sort: "descending" }
                , downloads: { title: "number of weighed downloads", sort: "descending" }
            }
        });

        $("#local-search").submit(function(event) {
            $("#ls-organism").val($("#ae-organism").val());
            $("#ls-array").val($("#ae-array").val());
            $("#ls-expdesign").val($("#ae-expdesign").val());
            $("#ls-exptech").val($("#ae-exptech").val());
        });

        $("#ae-filters > form").submit(function(event) {
            $("#ae-keywords").val($("#local-searchbox").val());
        });

        if ($("#noresults").length > 0) {
            try {
                /* The simplest implementation, used on your zero search results pages */
                updateSummary({noResults: true});
            } catch (except_1) {}

        }

        query.accession = getQueryStringParam("accession", getQueryStringParam("accnum"));
        if (undefined != query.accession && "" != query.accession) {
            query.detailedview = true;
        } else {
            query.keywords = getQueryStringParam("keywords");
            query.directsub = getQueryBooleanParam("directsub");
            //query.private = ("" != user) ? getQueryBooleanParam("private") : undefined;
            query.organism = getQueryStringParam("organism", getQueryStringParam("species"));
            query.array = getQueryStringParam("array");
            query.exptype = getQueryArrayParam("exptype");
        }

        $.get(contextPath + "/species-list.html").then( function(data) {
            $("#ae-organism").html(data).removeAttr("disabled").val(query.organism);

        });

        $.get(contextPath + "/arrays-list.html").then( function(data) {
            addHtmlToSelect("#ae-array", data);
            $("#ae-array").removeAttr("disabled").val(query.array);
        });

        $.get(contextPath + "/expdesign-list.html?q=").then( function(data) {
            $("#ae-expdesign")
                    .html(data)
                    .removeAttr("disabled")
                    .val((jQuery.isArray(query.exptype) && query.exptype.length > 0) ? query.exptype[0] : "");
        });


        $.get(contextPath + "/exptech-list.html?q=").then( function(data) {
            $("#ae-exptech")
                    .html(data)
                    .removeAttr("disabled")
                    .val((jQuery.isArray(query.exptype) && query.exptype.length > 1) ? query.exptype[1] : "");
        });
    });

})(window.jQuery);
