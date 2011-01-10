(function($, undefined) {
    if($ == undefined)
        throw "jQuery not loaded";

    $(function() {
        // fixes EBI iframes issue in MSIE
        if ($.browser.msie) {
            $("#head").attr("allowTransparency", true);
            $("#ae_contents").css("z-index", 1);
        }
    });

})(window.jQuery);
