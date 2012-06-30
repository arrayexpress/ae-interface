/*
 * Copyright 2009-2012 European Molecular Biology Laboratory
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

    /* TODO
    $.fn.extend({

        aeSampleTableSorter: function() {
            return this.each(function() {
                new $.AESampleTableSorter(this);
            });
        }
    });

    $.AESampleTableSorter = function( elt ) {
    };
    */

    function
    tableAdjustColWidth( eltSelector )
    {
        $(eltSelector).each(function() {
            var me = $(this);
            me.width(me.children().first().width())
        });
    }

    function
    tableAdjustFillerHeight( tableSelector, srcEltSelector, dstEltSelector )
    {
        $(tableSelector).each(function() {
            var me = $(this);
            var srcElt = me.find(srcEltSelector).first();
            var dstElt = me.find(dstEltSelector).first();
            dstElt.height(srcElt.height() - srcElt.children().first().height());
        });
    }

    function
    updateScrollShadow()
    {
        if (scrollElt.scrollLeft() !== 0) {
            if (!shadowElt.hasClass("left-shadow")) {
                shadowElt.addClass("left-shadow");
            }
        } else {
            shadowElt.removeClass("left-shadow");
        }
        if (scrollableElt.width() - scrollElt.scrollLeft() !== scrollElt.width()) {
            if (!scrollElt.hasClass("right-shadow")) {
                scrollElt.addClass("right-shadow");
            }
        } else {
            scrollElt.removeClass("right-shadow");
        }
    }

    $(function() {

        if ($.query == undefined)
            throw "jQuery.query not loaded";

        var sortby = $.query.get("colsortby") || "col_1";
        var sortorder = $.query.get("colsortorder") || "ascending";

        var localPath = /(\/.+)$/.exec(decodeURI(window.location.pathname))[1];

        tableAdjustColWidth("td.left_fixed");
        tableAdjustColWidth("td.right_fixed");
        tableAdjustFillerHeight("table.ae_samples_table", "div.attr_table_scroll", "td.bottom_filler");

        if (false && !$.browser.msie) {
            shadowElt = $("td.middle_scrollable");
            scrollElt = shadowElt.children().first();
            scrollableElt = scrollElt.children().first();

            scrollElt.scroll( function() { updateScrollShadow() });
            $(window).resize( function() { updateScrollShadow() });
            updateScrollShadow();
        }

        $("table.ae_samples_table").find("th.sortable").each( function() {
            var me = $(this);
            var colname = /(col_\d+)/.exec(me.attr("class"))[1];

            // so the idea is to set default sorting for all columns except the "current" one
            // (which will be inverted) against its current state
            var newOrder = (colname === sortby) ? ("ascending" === sortorder ? "descending" : "ascending"): "ascending";
            var queryString = $.query.set("colsortby", colname).set("colsortorder", newOrder).toString();

            me.wrapInner("<a href=\"" + localPath + queryString + "\" title=\"Click to sort table by this column\"/>");
        });
    });

})(window.jQuery);
