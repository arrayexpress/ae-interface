(function($, undefined) {
    if($ == undefined)
        throw "jQuery not loaded";

    var sortDefault = { accession: "ascending"
                      , name: "ascending"
                      , species: "ascending"
    };

    var sortTitle =   { accession: "accession"
                      , name: "name"
                      , species: "species"
    };

    $(function() {
        // this will be executed when DOM is ready
        if ($.query == undefined)
            throw "jQuery.query not loaded";

        var sortby = $.query.get("sortby") || "accession";
        var sortorder = $.query.get("sortorder") || "ascending";

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

        $("#ae_results_pager").aePager();
    });

})(window.jQuery);
