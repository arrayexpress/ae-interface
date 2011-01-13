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

            <link rel="stylesheet" href="${interface.application.link.www_domain.inc}/css/contents.css" type="text/css"/>
            <link rel="stylesheet" href="${interface.application.link.www_domain.inc}/css/userstyles.css" type="text/css"/>

            <script src="${interface.application.link.www_domain.inc}/js/contents.js" type="text/javascript"/>

            <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_common_20.css" type="text/css"/>
            <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_html_page_20.css" type="text/css"/>

            <xsl:copy-of select="$pExtraCode"/>
        </head>
    </xsl:template>

    <xsl:template name="page-body">
        <body class="${interface.application.body.class}">
            <div class="headerdiv" id="headerdiv" style="position:absolute; z-index: 1;">
                <iframe src="${interface.application.link.www_domain.inc}/head.html" name="head" id="head"
                        frameborder="0" marginwidth="0px" marginheight="0px" scrolling="no" width="100%"
                        style="position:absolute; z-index: 1; height: 57px;">
                    <xsl:text>Your browser does not support inline frames or is currently configured not to display inline frames. Content can be viewed at actual source page: http://www.ebi.ac.uk/inc/head.html</xsl:text>
                </iframe>
            </div>
            <noscript>
                <div id="ae_noscript" class="ae_assign_font">
                    <div class="ae_center_box">
                        <div id="ae_contents_box_915px">
                            <div class="ae_error_area">ArrayExpress uses JavaScript for better data handling and enhanced representation. Please enable JavaScript if you want to continue browsing ArrayExpress.</div>
                        </div>
                    </div>
                </div>
            </noscript>
            <div id="ae_contents" class="ae_contents_frame ae_assign_font"><div id="ae_contents_container"><xsl:call-template name="ae-contents"/></div></div>
            <div id="ebi_footer">
                <iframe src="${interface.application.link.www_domain.inc}/foot.html"
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
            <div id="ae_contents" class="ae_assign_font"><xsl:call-template name="ae-contents"/></div>
            ${interface.application.google.analytics}
        </body>
    </xsl:template>

    <xsl:template name="block-warning">
        <xsl:param name="pStyle"/>
        <xsl:param name="pMessage"/>
        <div class="ae_center_box">
            <div id="ae_contents_box_915px">
                <div class="{$pStyle}">
                    <div><xsl:copy-of select="$pMessage"/></div>
                    <div>We value your feedback. If you believe there was an error and wish to report it, please do not hesitate to drop us a line to <strong>arrayexpress(at)ebi.ac.uk</strong> or use <a href="${interface.application.link.www_domain}/support/" title="EBI Support">EBI Support Feedback</a> form.</div>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="block-access-restricted">
        <xsl:call-template name="block-warning">
            <xsl:with-param name="pStyle" select="'ae_protected_area'"/>
            <xsl:with-param name="pMessage">Sorry, the access to the resource you are requesting is restricted. You may wish to go <a href="javascript:history.back()" title="Click to go to the page you just left">back</a>, or to <a href="{$basepath}" title="ArrayExpress Home">ArrayExpress Home</a>.</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="block-not-found">
        <xsl:call-template name="block-warning">
            <xsl:with-param name="pStyle" select="'ae_warn_area'"/>
            <xsl:with-param name="pMessage">The resource you are requesting is not found. You may wish to go <a href="javascript:history.back()" title="Click to go to the page you just left">back</a>, or to <a href="{$basepath}" title="ArrayExpress Home">ArrayExpress Home</a>.</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>