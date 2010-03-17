//
//  AE Browse Page Scripting Support. Requires jQuery 1.3.1 and JSDefeered.jQuery 0.2.1
//

// query object is a global variable
var query = new Object();
var user = "";
var headerPrintElt = null;

function
aeClearKeywords()
{
    $("#ae_keywords").val("");
    $("#ae_expandefo").removeAttr("checked");
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

function
aeShowLoginForm()
{
    $("#ae_login_link").hide();
    $("#ae_help_link").hide();
    $("#ae_keywords_box").hide();
    $("#ae_login_status").text("");
    $("#ae_login_box").show();
    $("#ae_user_field").focus();
}

function
aeHideLoginForm()
{
    $("#ae_login_box").hide();
    $("#ae_help_link").show();
    $("#ae_keywords_box").show();
    $("#ae_login_status").text("");
    if ( "" != user ) {
        $("#ae_login_link").hide();
        $("#ae_login_info strong").text(user);
        $("#ae_login_info").show();
    } else {
        $("#ae_login_link").show();
    }
}


function
aeDoLogin()
{
    user = $("#ae_user_field").val();
    var pass = $("#ae_pass_field").val();
    $("#ae_pass_field").val("");
    $("#ae_login_status").text("");
    $("#ae_login_submit").attr("disabled", "true");
    $.get("verify-login.txt", { u: user, p: pass }).next(aeDoLoginNext);
}

function
aeDoLoginNext(text)
{
    if ( "" != text ) {
        $("#ae_login_box").hide();
        $("#ae_help_link").show();
        $("#ae_keywords_box").show();
        $("#ae_login_submit").removeAttr("disabled");

        var loginExpiration = null;
        if ( $("#ae_login_remember").attr("checked") ) {
            loginExpiration = 365;
        }

        $.cookie("AeLoggedUser", user, {expires: loginExpiration, path: '/'});
        $.cookie("AeLoginToken", text, {expires: loginExpiration, path: '/'});

        $("#ae_login_info strong").text(user);
        $("#ae_login_info").show();
        window.location.href = decodeURI(window.location.pathname) + $.query.toString();        
    } else {
        user = "";
        $("#ae_login_status").text("Incorrect user name or password. Please try again.");
        $("#ae_login_submit").removeAttr("disabled");
        $("#ae_user_field").focus();
    }
}

function
aeDoLogout(shouldReQuery)
{
    $("#ae_login_info").hide();
    $("#ae_login_link").show();
    $.cookie("AeLoggedUser", null, {path: '/' });
    $.cookie("AeLoginToken", null, {path: '/' });
    user = "";
    if (undefined == shouldReQuery || shouldReQuery) {
        window.location.href = decodeURI(window.location.pathname) + $.query.toString();
    }
}

function
aeSort( sortby )
{
    if ( -1 != String("accession name assays species releasedate fgem raw atlas").indexOf(sortby) ) {
        var innerElt = $( "#ae_results_header_" + sortby ).find("div.table_header_inner");
        var sortorder = "ascending";
        if ( -1 != String("accession name species").indexOf(sortby)) {
            if ( undefined != innerElt && innerElt.hasClass("table_header_sort_asc") )
                sortorder = "descending";
        } else {
            sortorder = "descending";
            if ( undefined != innerElt && innerElt.hasClass("table_header_sort_desc") )
                sortorder = "ascending";
        }
        var newQuery = $.query.set( "sortby", sortby ).set( "sortorder", sortorder ).toString();
        window.location.href = "browse.html" + newQuery;
    }
}

function
aeToggleExpand( id, shouldUpdateState )
{
    id = String(id);
    var mainElt = $("#" + id + "_main");
    var extElt = $("#" + id +  "_ext");
    if ( mainElt.hasClass("exp_expanded")) {
        // collapse now
        mainElt.removeClass("exp_expanded").find("td").removeClass("td_expanded");
        extElt.hide();
    } else {
        mainElt.addClass("exp_expanded").find("td").addClass("td_expanded");
        extElt.show();
    }
    onWindowResize();

    if (shouldUpdateState) {
        updateAppStateExpand(id);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

$(document).ready( function() {

    // step 0: hack for IE to work with this funny EBI header/footer (to be redeveloped with jQuery)
    if (-1 != navigator.userAgent.indexOf('MSIE')) {
        document.getElementById('head').allowTransparency = true;
        document.getElementById('ae_contents').style.zIndex = 1;
    }

    // content is hidden by default to prevent its ugly appearance on IE if scripting is disabled
    $("#ae_contents").show();

    // retrieve the location of print button element from header
    $("#head").load(function () {
        var frame = this.contentDocument;
        headerPrintElt = $("#printiconhref", frame);
    })

    if ($.browser.opera && $.browser.version < 9.5) {
        onWindowResize();
        $(window).bind('resize', onWindowResize);
    } else {
        onWindowResize();
    }

    // added autocompletion
    var basePath = decodeURI(window.location.pathname).replace(/\/\w+\.\w+$/,"/");

    $("#ae_keywords").autocomplete(
            basePath + "keywords.txt"
            , { matchContains: false
                , selectFirst: false
                , scroll: true
                , max: 50
                , requestTreeUrl: basePath + "efotree.txt"
            }
        );

    var _user = $.cookie("AeLoggedUser");
    var _token = $.cookie("AeLoginToken");
    if ( undefined != _user && undefined != _token ) {
        user = _user;
        $("#ae_login_link").hide();
        $("#ae_login_info strong").text(_user);
        $("#ae_login_info").show();
    }

    // adds a callback to close a login form on escape
    $("#ae_login_form input").keydown(
            function (e) {
                if (e.keyCode == 27) {
                    aeHideLoginForm();
                }
            }
        );

    query.accession = getQueryStringParam("accnum");
    query.accession = getQueryStringParam("accession");
    if ("" != query.accession) {
        query.detailedview = true;
    } else {
        query.keywords = getQueryStringParam("keywords");
        query.expandefo = getQueryBooleanParam("expandefo");
        query.species = getQueryStringParam("species");
        query.array = getQueryStringParam("array");
        query.exptype = getQueryArrayParam("exptype");
        query.efv = getQueryStringParam("efv");
        query.sa = getQueryStringParam("sa");
        query.pmid = getQueryStringParam("pmid");
        query.gxa = getQueryStringParam("gxa");
        query.page = getQueryStringParam("page");
        query.pagesize = getQueryStringParam("pagesize", "25");
        query.sortby = getQueryStringParam("sortby", "releasedate");
        query.sortorder = getQueryStringParam("sortorder", "descending");
        query.detailedview = getQueryBooleanParam("detailedview");
        query.queryversion = getQueryStringParam("queryversion", "2");
        query.wholewords = getQueryStringParam("wholewords", "");
    }
    
    initControls();

    $("#ae_results_body_inner").ajaxError(onQueryError);
    $.get( "browse-table.html", query ).next(onExperimentQuery);
});

function
onWindowResize()
{
    var outerWidth = $("#ae_results_body").width();
    var innerWidth = $("#ae_results_body table").width();
    var padding = outerWidth - innerWidth;
    if ( padding > 0 && padding < 30 ) {
        $("#ae_results_hdr").css( "right", padding + "px" );
    } else if ( padding == 0 && $.browser.opera && $.browser.version < 9.5 ) {
        $("#ae_results_hdr").css( "right", "-1px" );
    }
}

function
onExperimentQuery( tableHtml )
{
    // remove progress gif
    $("#ae_results_body_inner").removeClass("ae_results_tbl_loading");

    // populate table with data
    $("#ae_results_tbody").html(tableHtml);

    // attach titles to highlight classes
    $("#ae_results_tbody").find(".ae_text_hit").attr("title", "This is exact string matched for input query terms");
    $("#ae_results_tbody").find(".ae_text_syn").attr("title", "This is synonym matched from Experimental Factor Ontology e.g. neoplasia for cancer");
    $("#ae_results_tbody").find(".ae_text_efo").attr("title", "This is matched child term from Experimental Factor Ontology e.g. brain and subparts of brain");

    // check if the appstate was saved for the page
    if (checkAppState()) {
        // update checkboxes and scroll position
        applySavedAppState();
    } else {
        // create a new appstate
        createAppState();
    }

    $("#ae_results_body_inner").scroll(
            function (e) {
                updateAppStateScroll($(this).scrollTop());
            }
        );

    // adjust header width to accomodate scroller (for Opera <9.5)
    if ($.browser.opera && $.browser.version < 9.5)
        onWindowResize();

    // get stats from the first row
    var total = $("#ae_results_total").text();
    var totalAssays = $("#ae_results_total_assays").text();
    var from = $("#ae_results_from").text();
    var to = $("#ae_results_to").text();
    var curpage = $("#ae_results_page").text();
    var pagesize = $("#ae_results_pagesize").text();


    if ( total > 0 ) {

        // fix a header print icon so it does the right thing :)
        if (null != headerPrintElt) {
            headerPrintElt.attr("onClick", "").attr("target", "_top").attr("href", decodeURI(window.location.pathname).replace(/browse/, "browse.printer") + $.query.toString());
        }
        var queryString = $.query.toString();
        // assign valid hrefs to print, save and rss feed elements
        $("#ae_results_print a").attr("href", "browse.printer.html" + queryString);
        $("#ae_results_save a").attr("href", "ArrayExpress-Experiments.txt" + queryString);
        $("#ae_results_save_xls a").attr("href", "ArrayExpress-Experiments.xls" + queryString);
        $("#ae_results_save_feed a").attr("href", "rss/v2/experiments" + queryString);
        // show controls
        $(".status_icon").show();

        var totalPages = total > 0 ? Math.floor( ( total - 1 ) / pagesize ) + 1 : 0;
        $("#ae_results_status").html(
            total + " experiment" + (total != 1 ? "s" : "" ) + ", " +
            totalAssays + " assay" + (totalAssays != 1 ? "s" : "" ) + "." +
            ( totalPages > 1 ? (" Displaying experiments " + from + " to " + to + ".") : "" )
            );

        if ( totalPages > 1 ) {
            var pagerHtml = "Pages: ";
            for ( var page = 1; page <= totalPages; page++ ) {
                if ( curpage == page ) {
                    pagerHtml = pagerHtml + "" + page + "";
                } else if ( 2 == page && curpage > 6 && totalPages > 11 ) {
                    pagerHtml = pagerHtml + "..";
                } else if ( totalPages - 1 == page && totalPages - curpage > 5 && totalPages > 11 ) {
                    pagerHtml = pagerHtml + "..";
                } else if ( 1 == page || ( curpage < 7 && page < 11 ) || ( Math.abs( page - curpage ) < 5 ) || ( totalPages - curpage < 6 && totalPages - page < 10 ) || totalPages == page || totalPages <= 11 ) {
                    var newQuery = $.query.set( "page", page ).set( "pagesize", pagesize ).toString();
                    pagerHtml = pagerHtml + "<a href=\"browse.html" + newQuery + "\">" + page + "</a>";
                }
                if ( page < totalPages ) {
                    pagerHtml = pagerHtml + " ";
                }
            }
            $("#ae_results_pager").html( pagerHtml );
        }
    }

    // attach handlers
    $(".tr_main").each(addExpansionHandlers);

    // check if user cookie has been invalidated
    if ("" != user && $.cookie("AeLoggedUser") != user) {
        // cookie was removed :)
        alert("The session for user " + user + " has expired.");
        aeDoLogout(false);
    }
}

function
onQueryError()
{
    $(this).removeClass("ae_results_tbl_loading");
    $("#ae_results_tbody").html("<tr class=\"ae_results_tr_error\"><td colspan=\"9\">There was an error processing the query. Please try again later.</td></tr>");
}

function
initControls()
{
    // keywords
    $("#ae_keywords").val(query.keywords);
    if (query.expandefo)
        $("#ae_expandefo").attr("checked", "true");
    
    $("#ae_sortby").val(query.sortby);
    $("#ae_sortorder").val(query.sortorder);
    $("#ae_pagesize").val(query.pagesize);
    if (query.detailedview)
        $("#ae_detailedview").attr("checked", "true");

    $.get("species-list.html").next( function(data) {
        $("#ae_species").html(data).removeAttr("disabled").val(query.species);
        
    });

    $.get("arrays-list.html").next( function(data) {
        addHtmlToSelect("ae_array", data);
        $("#ae_array").removeAttr("disabled").val(query.array);
    });

//  $("#ae_expdesign").change( function(e) {
//                  var selected = e.target.value;
//                  onExpDesignChange(selected);
//  });
//
//  $("#ae_exptech").change( function(e) {
//                  var selected = e.target.value;
//                  onExpTechChange(selected);
//  });


    $.get("expdesign-list.html?q=").next( function(data) {
        $("#ae_expdesign")
                .html(data)
                .removeAttr("disabled")
                .val((jQuery.isArray(query.exptype) && query.exptype.length > 0) ? query.exptype[0] : "");
//      if (query.expdesign > "")
//          onExpDesignChange(query.expdesign);
    });


    $.get("exptech-list.html?q=").next( function(data) {
        $("#ae_exptech")
                .html(data)
                .removeAttr("disabled")
                .val((jQuery.isArray(query.exptype) && query.exptype.length > 1) ? query.exptype[1] : "");
//      if (query.exptech > "")
//          onExpTechChange(query.exptech);
    });

    if ( "" != query.sortby ) {
        var thElt = $("#ae_results_header_" + query.sortby);
        if ( null != thElt ) {
            thElt.addClass("table_header_box_selected").removeClass("table_header_box").removeClass("sortable");

            if ( "" != query.sortorder) {
                var divElt = thElt.find("div.table_header_inner");
                if ( null != divElt ) {
                    divElt.addClass( "descending" == query.sortorder ? "table_header_sort_desc" : "table_header_sort_asc" );
                }
            }
        }
    }
}

function
onExpDesignChange( value )
{
    $.get("exptech-list.html?q=" + String(value).replace(/ +/g, "+")).next( function(data) {
                        var selector = $("#ae_exptech");
                        var curValue = selector.val();
                        var newValue = curValue;
                        selector.html(data);
                        if (0 == selector.find("option[value='" + curValue + "']").length) {
                            newValue = selector.find("option")[0].val();
                        }
                        if (curValue != newValue) {
                            onExpTechChange(selector.val());
                        }
                    });
}

function
onExpTechChange( value )
{
    $.get("expdesign-list.html?q=" + String(value).replace(/ +/g, "+")).next( function(data) {
                        var selector = $("#ae_expdesign");
                        var curValue = selector.val();
                        var newValue = curValue;
                        selector.html(data);
                        if (0 == selector.find("option[value='" + curValue + "']").length) {
                            newValue = selector.find("option")[0].val();
                        }
                        if (curValue != newValue) {
                            onExpDesignChange(selector.val());
                        }
                    });
}

function
addExpansionHandlers()
{
    $(this).find("div.table_row_expand").wrap("<a href=\"javascript:aeToggleExpand('" + String(this.id).replace(/_main/, "") + "', true);\" title=\"Click to reveal/hide more information on the experiment\"><div class=\"table_row_expander\"></div></a>");
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

function
getQueryStringParam( paramName, defaultValue )
{
    if (undefined == defaultValue) {
        defaultValue = "";
    }
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
    return (true === param || "" != param);
}

function
checkAppState()
{
    return (($.query.toString() + "?") == $.cookie("AeAppStateQStr"));
}

function
createAppState()
{
    $.cookie("AeAppStateQStr", $.query.toString() + "?", {path: '/'});
    $.cookie("AeAppStateData", "0", {path: '/'});
}

function
applySavedAppState()
{
    var appStateData = $.cookie("AeAppStateData");
    if (null != appStateData) {
        appStateData = appStateData.split(";");
        for (var i = 1; i < appStateData.length; i++) {
            aeToggleExpand(appStateData[i], false);
        }
        if (0 < appStateData[0] && 0 == $("#ae_results_body_inner").scrollTop()) {
            $("#ae_results_body_inner").scrollTop(appStateData[0]);
        }
    }
}

function
updateAppStateExpand( id )
{
    var appStateData = $.cookie("AeAppStateData");
    if (null != appStateData) {
        if (-1 != appStateData.indexOf(";" + id)) {
            // found, remove it from the list
            appStateData = appStateData.replace(new RegExp(";" + id), "");
        } else {
            appStateData = appStateData + ";"+ id;
        }
        $.cookie("AeAppStateData", appStateData);
    }
}

function
updateAppStateScroll( scrollValue )
{
    var appStateData = $.cookie("AeAppStateData");
    if (null != appStateData) {
        appStateData = appStateData.replace(/^\d+/, scrollValue);
        $.cookie("AeAppStateData", appStateData);
    }
}
