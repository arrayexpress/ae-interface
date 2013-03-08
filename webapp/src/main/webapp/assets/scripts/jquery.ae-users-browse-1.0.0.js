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

    $(function() {
        $("th.sortable").aeBrowseSorting({
            defaultField: "id"
            , fields:
                { id: { title: "ID", sort : "ascending" }
                , source: { title: "source", sort: "ascending" }
                , name: { title: "name", sort: "ascending" }
                , email: { title: "e-mail address", sort: "ascending" }
            }
        });
    });

})(window.jQuery);
