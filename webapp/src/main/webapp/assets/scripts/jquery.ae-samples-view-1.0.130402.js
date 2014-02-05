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

    $.fn.extend({

        aeSampleTableSorter: function() {
            return this.each(function() {
                new $.AESampleTableSorter(this);
            });
        }
    });

    $.AESampleTableSorter = function(table) {
        if ($.query == undefined)
            throw "jQuery.query not loaded";

        var sortby = $.query.get("s_sortby") || "col_1";
        var sortorder = $.query.get("s_sortorder") || "ascending";

        var localPath = /(\/.+)$/.exec(decodeURI(window.location.pathname))[1];

        $(table).find("th.sortable").each( function() {
            var me = $(this);
            var colname = /(col_\d+)/.exec(me.attr("class"))[1];

            // so the idea is to set default sorting for all columns except the "current" one
            // (which will be inverted) against its current state
            var newOrder = (colname === sortby) ? ("ascending" === sortorder ? "descending" : "ascending"): "ascending";
            var queryString = $.query.set("s_sortby", colname).set("s_sortorder", newOrder).toString();

            me.wrapInner("<a href=\"" + localPath + queryString + "\" title=\"Click to sort table by this column\"/>");
        });
    };

    $.fn.extend({
        aeSampleTableScrollShadow: function() {
            return this.each(function() {
                if (!($.browser.msie || $.browser.opera)) {
                    new $.AESSampleTableScrollShadow(this);
                }
            });
        }
    });

    $.AESSampleTableScrollShadow = function(table) {
        var $table = $(table);
        var $leftShadow = $table.find(".left_shadow").first();
        var $rightShadow = $table.find(".right_shadow").first();
        var $scrollFrame = $table.find(".attr_table_scroll").first();
        var $scrollable = $scrollFrame.children().first();

        function updateShadow() {
            var scrollLeft = $scrollFrame.scrollLeft();
            if ( scrollLeft !== 0) {
                $leftShadow.show();
            } else {
                $leftShadow.hide();
            }
            if ($scrollable.width() - scrollLeft !== $scrollFrame.width()) {
                $rightShadow.show();
            } else {
                $rightShadow.hide();
            }
        }

        $scrollFrame.scroll( function() { updateShadow() });
        $(window).resize( function() { updateShadow() });
        updateShadow();
    };

    function
    tableAdjustColWidth( tableSelector, tdClassName )
    {
        $(tableSelector).each(function() {
            var $table = $(this);
            var $content = $table.find("td." + tdClassName).first().children().first();
            var $col = $table.find("col.col_" + tdClassName);
            $col.width($content.width());
            $content.addClass("w100pc");
        });
    }

    function
    tableReveal( tableSelector )
    {
        $(tableSelector).each(function() {
            $(this).css("visibility", "visible");
        });
    }

    function
    tableAdjustFillerHeight( tableSelector, srcEltSelector, dstEltSelector )
    {
        $(tableSelector).each(function() {
            var $table = $(this);
            var $src = $table.find(srcEltSelector).first();
            var $dst = $table.find(dstEltSelector).first();
            $dst.height($src.height() - $src.children().first().height());
        });
    }

    function
    tableAdjust()
    {
        tableAdjustFillerHeight("table.ae_samples_table", "div.attr_table_scroll", "td.bottom_filler");
    }

    $(function() {

        tableAdjustColWidth("table.ae_samples_table", "left_fixed");
        tableAdjustColWidth("table.ae_samples_table", "right_fixed");
        tableReveal("table.ae_samples_table");

        $(window).resize(tableAdjust).trigger("resize");

        var $table = $("table.ae_samples_table");

        $table.aeSampleTableSorter();
        $table.aeSampleTableScrollShadow();
    });

})(window.jQuery);
