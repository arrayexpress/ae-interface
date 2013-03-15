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

    function fixImagesLinks() {
        // fix all image links
        $("img").attr("src", function(i, val) {

            if (undefined !=val && !val.match(/^http:\/\//)) {

                // fix internal relative image links
                val = val.replace(/^([^\/])/, "../../../assets/images/help/$1");

                // fix external image links
                val = val.replace(/^\/\//, "http://");

                // fix internal absolute image links
                val = val.replace(/^\/arrayexpress\//, "../../../");
            }

            return val;
        });

        $("a").attr("href", function(i, val) {
            // fix internal relative image links
            if (undefined != val) {
                if (!val.match(/^http:\/\//)) {

                    // fix relative links
                    val = val.replace(/^([^\/#])/, "preview.html?page=help/$1");

                    // fix internal project links
                    val = val.replace(/^\/arrayexpress\//, "preview.html?page=");

                    // fix internal absolute links
                    val = val.replace(/^\//, "http://www.ebi.ac.uk/");
                }
            }
            return val;
        });
    }


    $(function() {
        var page = $.query.get("page") || "about.html";

        $.get(page, function(html) {
            if (typeof html == "string") {
                var title = html.match("<title>(.*?)</title>")[1];
                document.title = title.replace(/&lt;/g, "<");
            }

            var $content = $(html).find("section,aside");
            $content.appendTo("#content");

            fixImagesLinks();
        }, "text").fail(function() {
            $("#content").html('<div style="text-align:center; margin: 100px 0">Page <span class="alert">' + page + '</span> was not found.</div></div>');
            fixImagesLinks();
        });
    });

})(window.jQuery);

