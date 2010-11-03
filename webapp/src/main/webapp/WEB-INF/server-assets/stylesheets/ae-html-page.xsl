<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="html"
                exclude-result-prefixes="html"
                version="1.0">

    <xsl:template name="page-header">
        <xsl:param name="pTitle"/>
        <xsl:param name="pExtraCode"/>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
            <meta http-equiv="Content-Language" content="en-GB"/>
            <meta http-equiv="Window-target" content="_top"/>
            <meta name="no-email-collection" content="http://www.unspam.com/noemailcollection/"/>

            <title><xsl:value-of select="$pTitle"/></title>

            <link rel="SHORTCUT ICON" href="${interface.application.link.www_domain}/bookmark.ico"/>

            <link rel="stylesheet" href="${interface.application.link.www_domain}/inc/css/contents.css" type="text/css"/>
            <link rel="stylesheet" href="${interface.application.link.www_domain}/inc/css/userstyles.css" type="text/css"/>

            <script src="${interface.application.link.www_domain}/inc/js/contents.js" type="text/javascript"/>

            <xsl:copy-of select="$pExtraCode"/>
        </head>
    </xsl:template>

    <xsl:template name="page-body">
        <body class="${interface.application.body.class}">
            <div class="headerdiv" id="headerdiv" style="position:absolute; z-index: 1;">
                <iframe src="${interface.application.link.www_domain}/inc/head.html" name="head" id="head"
                        frameborder="0" marginwidth="0px" marginheight="0px" scrolling="no" width="100%"
                        style="position:absolute; z-index: 1; height: 57px;">
                    <xsl:text>Your browser does not support inline frames or is currently configured not to display inline frames. Content can be viewed at actual source page: http://www.ebi.ac.uk/inc/head.html</xsl:text>
                </iframe>
            </div>
            <noscript>
                <div id="ae_noscript" class="assign_font">
                    <div class="ae_error_area">ArrayExpress uses JavaScript for better data handling and enhanced representation. Please enable JavaScript if you want to continue browsing ArrayExpress.</div>
                </div>
            </noscript>
            <div id="ae_contents"><xsl:call-template name="ae-contents"/></div>
            <div id="ebi_footer">
                <iframe src="${interface.application.link.www_domain}/inc/foot.html"
                        name="foot" frameborder="0" marginwidth="0px" marginheight="0px"
                        scrolling="no" height="22px" width="800px" style="z-index:2">
                    <xsl:text>Your browser does not support inline frames or is currently configured not to display inline frames. Content can be viewed at actual source page: http://www.ebi.ac.uk/inc/foot.html</xsl:text>
                </iframe>
            </div>
            ${interface.application.google.analytics}
        </body>
    </xsl:template>

    <!-- no EBI common crap -->
    <xsl:template name="page-header-plain">
        <xsl:param name="pTitle"/>
        <xsl:param name="pExtraCode"/>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
            <meta http-equiv="Content-Language" content="en-GB"/>
            <meta http-equiv="Window-target" content="_top"/>
            <meta name="no-email-collection" content="http://www.unspam.com/noemailcollection/"/>

            <title><xsl:value-of select="$pTitle"/></title>

            <link rel="SHORTCUT ICON" href="${interface.application.link.www_domain}/bookmark.ico"/>

            <xsl:copy-of select="$pExtraCode"/>
        </head>
    </xsl:template>

    <xsl:template name="page-body-plain">
        <body>
            <div id="ae_contents"><xsl:call-template name="ae-contents"/></div>
            ${interface.application.google.analytics}
        </body>
    </xsl:template>
</xsl:stylesheet>