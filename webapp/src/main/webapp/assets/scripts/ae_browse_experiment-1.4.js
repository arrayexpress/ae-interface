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

// query object is a global variable
var query = new Object();
var basePath = "";
var accession = "";

function
aeClearKeywords()
{
    $("#ae_keywords").val("");
    $("#ae_directsub").removeAttr("checked");
}

function
aeResetFilters()
{
    $("#ae_species").val("");
    $("#ae_array").val("");
    $("#ae_expdesign").val("");
    $("#ae_exptech").val("");

}

function
aeResetOptions()
{
    $("#ae_pagesize").val("25");
    $("#ae_detailedview").removeAttr("checked");
}

$(document).ready( function() {

    // step 0: hack for IE to work with this funny EBI header/footer (to be redeveloped with jQuery)
    if (-1 != navigator.userAgent.indexOf('MSIE')) {
        document.getElementById('head').allowTransparency = true;
        document.getElementById('ae_contents').style.zIndex = 1;
    }

    // added autocompletion
    basePath = "/arrayexpress/";
    accession = decodeURI(window.location.pathname).replace(/^.+\//, "");

    $("#ae_keywords").autocomplete(
            basePath + "keywords.txt"
            , { matchContains: false
                , selectFirst: false
                , scroll: true
                , max: 50
                , requestTreeUrl: basePath + "efotree.txt"
            }
        );

    $("#ae_keywords").val("accession:" + accession);

    initControls();
});

function
initControls()
{
    $.get(basePath + "species-list.html").next( function(data) {
        $("#ae_species").html(data).removeAttr("disabled").val(query.species);

    });

    $.get(basePath  + "arrays-list.html").next( function(data) {
        addHtmlToSelect("ae_array", data);
        $("#ae_array").removeAttr("disabled").val(query.array);
    });

    $.get(basePath + "expdesign-list.html?q=").next( function(data) {
        $("#ae_expdesign")
                .html(data)
                .removeAttr("disabled")
                .val((jQuery.isArray(query.exptype) && query.exptype.length > 0) ? query.exptype[0] : "");
    });


    $.get(basePath + "exptech-list.html?q=").next( function(data) {
        $("#ae_exptech")
                .html(data)
                .removeAttr("disabled")
                .val((jQuery.isArray(query.exptype) && query.exptype.length > 1) ? query.exptype[1] : "");
    });
}

function
addHtmlToSelect( selectEltId, html )
{
    if ( $.browser.opera ) {
        var htmlParsed = $.clean( new Array(html) );
        var select = $( "#" + selectEltId ).empty();
        for ( var i = 0; i < htmlParsed.length; i++ ) {
            select[0].appendChild(htmlParsed[i].cloneNode(true));
        }
    } else {
        $( "#" + selectEltId ).html(html);
    }
}
