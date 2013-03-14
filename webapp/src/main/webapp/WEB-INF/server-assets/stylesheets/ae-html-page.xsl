<?xml version="1.0" encoding="UTF-8"?>
<!--
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
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="html xs fn ae"
                exclude-result-prefixes="html xs fn ae"
                version="2.0">

    <xsl:param name="host"/>
    <xsl:param name="context-path"/>
    <xsl:param name="original-request-uri"/>
    <xsl:param name="referer"/>
    <xsl:param name="query-string"/>
    <xsl:param name="userid"/>
    <xsl:param name="username"/>

    <xsl:output omit-xml-declaration="yes" method="html" indent="no" encoding="UTF-8"/>

    <xsl:variable name="relative-uri" select="fn:substring-after($original-request-uri, $context-path)"/>
    <xsl:variable name="relative-referer" select="if (fn:starts-with($referer, '/')) then fn:substring-after($referer, $context-path) else ''"/>

    <xsl:variable name="secure-host" select="if (fn:matches($host, '^http[:]//www(dev)?[.]ebi[.]ac[.]uk$')) then fn:replace($host, '^http[:]//', 'https://') else ''"/>

    <xsl:template name="ae-page">
        <xsl:param name="pIsFixedWidth" as="xs:boolean"/>
        <xsl:param name="pIsSearchVisible" as="xs:boolean"/>
        <xsl:param name="pSearchInputValue" as="xs:string"/>
        <xsl:param name="pTitleTrail" as="xs:string"/>
        <xsl:param name="pBreadcrumbTrail"/>
        <xsl:param name="pExtraCSS"/>
        <xsl:param name="pExtraJS"/>

        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
        <!-- http://paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->
        <xsl:comment>[if lt IE 7]>&lt;html class="no-js ie6 oldie" lang="en">&lt;![endif]</xsl:comment>
        <xsl:comment>[if IE 7]>&lt;html class="no-js ie7 oldie" lang="en">&lt;![endif]</xsl:comment>
        <xsl:comment>[if IE 8]>&lt;html class="no-js ie8 oldie" lang="en">&lt;![endif]</xsl:comment>
        <xsl:comment>[if gt IE 8]>&lt;!</xsl:comment>
        <html class="no-js" lang="en">
            <xsl:comment>&lt;![endif]</xsl:comment>
            <xsl:call-template name="ae-page-head">
                <xsl:with-param name="pTitleTrail" select="$pTitleTrail"/>
                <xsl:with-param name="pExtraCode" select="$pExtraCSS"/>
            </xsl:call-template>
            <xsl:call-template name="ae-page-body">
                <xsl:with-param name="pIsFixedWidth" select="$pIsFixedWidth"/>
                <xsl:with-param name="pIsSearchVisible" select="$pIsSearchVisible"/>
                <xsl:with-param name="pSearchInputValue" select="$pSearchInputValue"/>
                <xsl:with-param name="pBreadcrumbTrail" select="$pBreadcrumbTrail"/>
                <xsl:with-param name="pExtraCode" select="$pExtraJS"/>
            </xsl:call-template>
        </html>
    </xsl:template>

    <xsl:template name="ae-page-head">
        <xsl:param name="pTitleTrail"/>
        <xsl:param name="pExtraCode"/>
        <head>
            <meta charset="utf-8"/>

            <title>
                <xsl:if test="$pTitleTrail"><xsl:value-of select="$pTitleTrail"/> &lt; </xsl:if>
                <xsl:text>ArrayExpress &lt; EMBL-EBI</xsl:text>
            </title>
            <meta name="description" content="EMBL-EBI"/>   <!-- Describe what this page is about -->
            <meta name="keywords" content="bioinformatics, europe, institute"/> <!-- A few keywords that relate to the content of THIS PAGE (not the whol project) -->
            <meta name="author" content="EMBL-EBI"/>        <!-- Your [project-name] here -->

            <!-- Mobile viewport optimized: http://j.mp/bplateviewport -->
            <meta name="viewport" content="width=device-width,initial-scale=1"/>

            <!-- Place favicon.ico and apple-touch-icon.png in the root directory: http://mathiasbynens.be/notes/touch-icons -->

            <!-- CSS: implied media=all -->
            <!-- CSS concatenated and minified via ant build script-->
            <link rel="stylesheet" href="//www.ebi.ac.uk/web_guidelines/css/compliance/mini/ebi-fluid-embl.css" type="text/css"/>
            <link rel="stylesheet" href="{$context-path}/assets/stylesheets/font-awesome.css" type="text/css"/>
            <link rel="stylesheet" href="{$context-path}/assets/stylesheets/ae-common-1.0.130314.css" type="text/css"/>
            <xsl:copy-of select="$pExtraCode"/>
            <!-- end CSS-->

            <!-- All JavaScript at the bottom, except for Modernizr / Respond.
                Modernizr enables HTML5 elements & feature detects; Respond is a polyfill for min/max-width CSS3 Media Queries
                For optimal performance, use a custom Modernizr build: http://www.modernizr.com/download/ -->

            <!-- Full build -->
            <!-- <script src="../js/libs/modernizr.minified.2.1.6.js"></script> -->

            <!-- custom build (lacks most of the "advanced" HTML5 support -->
            <script src="//www.ebi.ac.uk/web_guidelines/js/libs/modernizr.custom.49274.js"/>
        </head>
    </xsl:template>

    <xsl:template name="ae-page-body">
        <xsl:param name="pIsFixedWidth"/>
        <xsl:param name="pIsSearchVisible"/>
        <xsl:param name="pSearchInputValue"/>
        <xsl:param name="pBreadcrumbTrail"/>
        <xsl:param name="pExtraCode"/>
        <body>   <!-- add any of your classes or IDs -->
            <xsl:attribute name="class">
                <xsl:text>level2</xsl:text>
                <xsl:if test="$pIsFixedWidth">
                    <xsl:text> narrow</xsl:text>
                </xsl:if>
            </xsl:attribute>

            <div id="skip-to">
                <ul>
                    <li><a href="#content" title="">Skip to main content</a></li>
                    <li><a href="#local-nav" title="">Skip to local navigation</a></li>
                    <li><a href="#global-nav" title="">Skip to EBI global navigation menu</a></li>
                    <li><a href="#global-nav-expanded" title="">Skip to expanded EBI global navigation menu (includes all sub-sections)</a></li>
                </ul>
            </div>

            <div id="wrapper" class="container_24">
                <header>
                    <div id="global-masthead" class="masthead grid_24">
                        <!--This has to be one line and no newline characters-->
                        <a href="//www.ebi.ac.uk/" title="Go to the EMBL-EBI homepage"><img src="//www.ebi.ac.uk/web_guidelines/images/logos/EMBL-EBI/EMBL_EBI_Logo_white.png" alt="EMBL European Bioinformatics Institute"/></a>

                        <nav>
                            <ul id="global-nav">
                                <!-- set active class as appropriate -->
                                <li class="first active" id="services"><a href="//www.ebi.ac.uk/services">Services</a></li>
                                <li id="research"><a href="//www.ebi.ac.uk/research">Research</a></li>
                                <li id="training"><a href="//www.ebi.ac.uk/training">Training</a></li>
                                <li id="industry"><a href="//www.ebi.ac.uk/industry">Industry</a></li>
                                <li id="about" class="last"><a href="//www.ebi.ac.uk/about">About us</a></li>
                            </ul>
                        </nav>

                    </div>
                    <div id="local-masthead" class="masthead grid_24 nomenu">
                        <!-- local-title -->
                        <div id="local-title">
                            <xsl:if test="$pIsSearchVisible"><xsl:attribute name="class">grid_12 alpha</xsl:attribute></xsl:if>
                            <h1><a href="{$context-path}/" title="Back to ArrayExpress homepage">ArrayExpress</a></h1>
                        </div>
                        <!--
                        <div class="grid_12 alpha" id="local-title-logo">
                            <h1>ArrayExpress</h1>
                            <p><img src="{$context-path}/assets/images/frontier/ae-header-lg.png" alt="ArrayExpress" width="440" height="68" class="logo" /></p>
                        </div>
                        -->
                        <!-- /local-title -->
                        <!-- local-search -->
                        <!-- NB: if you do not have a local-search, delete the following div, and drop the class="grid_12 alpha" class from local-title above -->
                        <xsl:if test="$pIsSearchVisible">
                            <div class="grid_12 omega">
                                <form id="local-search" name="local-search" action="{$context-path}/search" method="get">
                                    <fieldset>
                                        <div class="left">
                                            <label>
                                                <input type="text" name="query" id="local-searchbox">
                                                    <xsl:if test="$pSearchInputValue != ''">
                                                        <xsl:attribute name="value" select="$pSearchInputValue"/>
                                                    </xsl:if>
                                                </input>
                                            </label>
                                            <!-- Include some example searchterms - keep them short and few! -->
                                            <span class="examples">Examples: <a href="{$context-path}/search?query=E-MEXP-31">E-MEXP-31</a>, <a href="{$context-path}/search?query=cancer">cancer</a>, <a href="{$context-path}/search?query=p53">p53</a>, <a href="{$context-path}/search?query=Geuvadis">Geuvadis</a></span>
                                        </div>
                                        <div class="right">
                                            <input type="submit" value="Search" class="submit"/>
                                            <!-- If your search is more complex than just a keyword search, you can link to an Advanced Search,
                                           with whatever features you want available -->
                                            <span class="adv"><a href="{$context-path}/search" id="adv-search" title="Advanced">Advanced</a></span>
                                        </div>
                                    </fieldset>
                                </form>
                            </div>
                        </xsl:if>
                        <!-- /local-search -->
                        <!-- local-nav -->
                        <nav>
                            <ul class="grid_24" id="local-nav">
                                <li>
                                    <xsl:attribute name="class">first<xsl:if test="$relative-uri = '/'"> active</xsl:if></xsl:attribute>
                                    <a href="{$context-path}/" title="ArrayExpress ${project.version}.r${buildNumber}">Home</a>
                                </li>
                                <li>
                                    <xsl:if test="fn:starts-with($relative-uri, '/experiments/')"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
                                    <a href="{$context-path}/experiments/browse.html" title="Experiments">Experiments</a>
                                </li>
                                <li>
                                    <xsl:if test="fn:starts-with($relative-uri, '/arrays/')"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
                                    <a href="{$context-path}/arrays/browse.html?directsub=on" title="Arrays">Arrays</a>
                                </li>
                                <xsl:if test="not($userid)">
                                    <li>
                                        <xsl:if test="fn:starts-with($relative-uri, '/protocols/')"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
                                        <a href="{$context-path}/protocols/browse.html" title="Protocols">Protocols</a>
                                    </li>
                                    <li>
                                        <xsl:if test="fn:starts-with($relative-uri, '/files/')"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
                                        <a href="{$context-path}/files/browse.html" title="Files">Files</a>
                                    </li>
                                    <li>
                                        <xsl:if test="fn:starts-with($relative-uri, '/users/')"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
                                        <a href="{$context-path}/users/browse.html" title="Users">Users</a>
                                    </li>
                                </xsl:if>
                                <li>
                                    <xsl:if test="fn:starts-with($relative-uri, '/submit/')"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
                                    <a href="{$context-path}/submit/overview.html" title="Submit">Submit</a></li>
                                <li>
                                    <xsl:if test="fn:starts-with($relative-uri, '/help/')"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
                                    <a href="{$context-path}/help/index.html" title="Help">Help</a>
                                </li>
                                <li class="last">
                                    <xsl:if test="$relative-uri = '/about.html'"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
                                    <a href="{$context-path}/about.html">About ArrayExpress</a></li>
                                <!-- If you need to include functional (as opposed to purely navigational) links in your local menu,
                                 add them here, and give them a class of "functional". Remember: you'll need a class of "last" for
                                 whichever one will show up last...
                                 For example: -->
                                <li class="functional last login">
                                    <a href="#" class="icon icon-functional" data-icon="l">
                                        <xsl:choose>
                                            <xsl:when test="$userid = '1'">Login</xsl:when>
                                            <xsl:when test="fn:exists($username)">Logout [<xsl:value-of select="$username"/>]</xsl:when>
                                            <xsl:otherwise>Logout</xsl:otherwise>
                                        </xsl:choose>
                                    </a>
                                </li>
                                <li class="functional feedback"><a href="#" class="icon icon-static" data-icon="\">Feedback</a></li>
                                <!--
                                <li class="functional"><a href="#" class="icon icon-functional" data-icon="r">Share</a></li>
                                -->
                            </ul>
                        </nav>
                        <!-- /local-nav -->
                    </div>
                </header>

                <div id="content" role="main" class="grid_24 clearfix">
                    <!-- If you require a breadcrumb trail, its root should be your service.
     	                 You don't need a breadcrumb trail on the homepage of your service... -->
                    <xsl:if test="fn:boolean($pBreadcrumbTrail)">
                        <nav id="breadcrumb">
                            <p><a href="{$context-path}/">ArrayExpress</a> &gt; <xsl:copy-of select="$pBreadcrumbTrail"/></p>
                        </nav>
                    </xsl:if>

                    <section>
                        <div id="ae-login-window" style="display:none">
                            <h3>ArrayExpress submitter/reviewer login<a id="ae-login-close" href="#" class="icon icon-functional" data-icon="x"/></h3>
                            <form id="ae-login" method="post" action="{$secure-host}{$context-path}/auth">
                                <fieldset>
                                    <label for="ae-user-field">User name</label>
                                    <input id="ae-user-field" name="u" maxlength="50"/>
                                </fieldset>
                                <fieldset>
                                    <label for="ae-pass-field">Password</label>
                                    <input id="ae-pass-field" type="password" name="p" maxlength="50"/>
                                </fieldset>
                                <span>
                                    <input id="ae-login-remember" name="r" type="checkbox"/>
                                    <label for="ae-login-remember">Remember me</label>
                                </span>
                                <input id="ae-login-submit" type="submit" name="s" value="Login"/>
                            </form>
                            <div id="ae-login-status"/>
                        </div>
                    </section>
                    <section>
                        <div id="ae-feedback-window" style="display:none">
                            <h3>Have your say<a id="ae-feedback-close" href="#" class="icon icon-functional" data-icon="x"/></h3>
                            <form id="ae-feedback" method="post" action="#" onsubmit="return false">
                                <fieldset>
                                    <label for="ae-feedback-message">We value your feedback. Please leave your comment below.</label>
                                    <textarea id="ae-feedback-message" name="m"/>
                                </fieldset>
                                <fieldset>
                                    <label for="ae-email-field">Optionally please enter your email address if you wish to get a response. We will never share this address with anyone else.</label>
                                    <input id="ae-email-field" name="e" maxlength="50"/>
                                </fieldset>
                                <input type="hidden" name="p" value="{$context-path}{$relative-uri}?{$query-string}"/>
                                <input type="hidden" name="r" value="{$context-path}{$relative-referer}"/>
                                <input id="ae-login-submit" type="submit" name="s" value="Send"/>
                            </form>
                        </div>
                    </section>
                    <xsl:call-template name="ae-content-section"/>
                    <!-- Suggested layout containers -->
                    <!--
                    <section>
                        <h2>[Page title]</h2>
                        <p>Your content</p>
                    </section>

                    <section>
                        <h3>[Another title]</h3>
                        <p>More content in a full-width container.</p>
                    </section>
                    -->
                    <!-- End suggested layout containers -->
                </div>
                <footer>
                    <!-- Optional local footer (insert citation / project-specific copyright / etc here -->
                    <!--
                    <div id="local-footer" class="grid_24 clearfix">
                            <p>How to reference this page: ...</p>
                        </div>
                    -->
                    <!-- End optional local footer -->
                    <div id="global-footer" class="grid_24">
                        <nav id="global-nav-expanded">
                            <div class="grid_4 alpha">
                                <h3 class="embl-ebi"><a href="//www.ebi.ac.uk/" title="EMBL-EBI">EMBL-EBI</a></h3>
                            </div>
                            <div class="grid_4">
                                <h3 class="services"><a href="//www.ebi.ac.uk/services">Services</a></h3>
                            </div>
                            <div class="grid_4">
                                <h3 class="research"><a href="//www.ebi.ac.uk/research">Research</a></h3>
                            </div>
                            <div class="grid_4">
                                <h3 class="training"><a href="//www.ebi.ac.uk/training">Training</a></h3>
                            </div>
                            <div class="grid_4">
                                <h3 class="industry"><a href="//www.ebi.ac.uk/industry">Industry</a></h3>
                            </div>
                            <div class="grid_4 omega">
                                <h3 class="about"><a href="//www.ebi.ac.uk/about">About us</a></h3>
                            </div>
                        </nav>
                        <section id="ebi-footer-meta">
                            <p class="address">EMBL-EBI, Wellcome Trust Genome Campus, Hinxton, Cambridgeshire, CB10 1SD, UK &#160; &#160; +44 (0)1223 49 44 44</p>
                            <p class="legal">Copyright &#169; EMBL-EBI 2013 | EBI is an Outstation of the <a href="http://www.embl.org">European Molecular Biology Laboratory</a> | <a href="/about/privacy">Privacy</a> | <a href="/about/cookies">Cookies</a> | <a href="/about/terms-of-use">Terms of use</a></p>
                        </section>
                    </div>
                </footer>
            </div>  <!--! end of #wrapper -->

            <script defer="defer" src="//www.ebi.ac.uk/web_guidelines/js/cookiebanner.js"/>
            <script defer="defer" src="//www.ebi.ac.uk/web_guidelines/js/foot.js"/>
            <script src="{$context-path}/assets/scripts/jquery-1.8.2.min.js"/>
            <script src="{$context-path}/assets/scripts/jquery.cookie-1.0.js"/>
            <script src="{$context-path}/assets/scripts/jquery.caret-range-1.0.js"/>
            <script src="{$context-path}/assets/scripts/jquery.autocomplete-1.1.0.130305.js"/>
            <script src="{$context-path}/assets/scripts/jquery.ae-common-1.0.130312.js"/>
            <script type="text/javascript">
                <xsl:text>var contextPath = "</xsl:text>
                <xsl:value-of select="$context-path"/>
                <xsl:text>";</xsl:text>
            </script>
            <xsl:copy-of select="$pExtraCode"/>
            ${interface.application.google.analytics}
        </body>
    </xsl:template>

    <xsl:template name="add-table-sort">
        <xsl:param name="pKind"/>
        <xsl:param name="pSortBy"/>
        <xsl:param name="pSortOrder"/>
        <xsl:if test="$pKind = $pSortBy">
            <xsl:choose>
                <xsl:when test="fn:starts-with($pSortOrder, 'a')">
                    <i class="aw-icon-angle-up"/>
                </xsl:when>
                <xsl:otherwise>
                    <i class="aw-icon-angle-down"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:function name="ae:setQSParam" as="xs:string">
        <xsl:param name="pQueryString" as="xs:string"/>
        <xsl:param name="pParamName" as="xs:string"/>
        <xsl:param name="pParamValue" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="fn:matches($pQueryString, fn:concat('(^|&amp;)', $pParamName, '='))">
                <xsl:value-of select="fn:replace($pQueryString, fn:concat('(^|&amp;)(', $pParamName, '=)([^&amp;]+)'), fn:concat('$1$2', $pParamValue))"/>
            </xsl:when>
            <xsl:when test="fn:string-length($pQueryString) > 0">
                <xsl:value-of select="fn:concat($pQueryString, '&amp;', $pParamName,'=', $pParamValue)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="fn:concat($pParamName, '=', $pParamValue)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="table-page-size">
        <xsl:param name="pCurrentPageSize" as="xs:integer"/>
        <xsl:param name="pTotal" as="xs:integer"/>
        <xsl:param name="pPageParam" as="xs:string"/>
        <xsl:param name="pPageSizeParam" as="xs:string"/>
        <div class="ae-page-size">
            <xsl:choose>
                <xsl:when test="$pTotal > 25">
                    <xsl:variable name="vPageSizes" select="25, 50, 100, 250, 500"/>
                    <xsl:text>Page size </xsl:text>
                    <xsl:for-each select="$vPageSizes">
                        <xsl:choose>
                            <xsl:when test="fn:current() = $pCurrentPageSize">
                                <span><xsl:value-of select="."/></span>
                            </xsl:when>
                            <xsl:otherwise>
                                <a href="{$context-path}{$relative-uri}?{ae:setQSParam(ae:setQSParam($query-string, $pPageParam, '1'), $pPageSizeParam, fn:string(fn:current()))}">
                                    <xsl:value-of select="fn:current()"/>
                                </a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>&#160;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="table-pager-pages">
        <xsl:param name="pTotal" as="xs:integer"/>
        <xsl:param name="pPage" as="xs:integer"/>
        <xsl:param name="pPageSize" as="xs:integer"/>
        <xsl:param name="pPageParam" as="xs:string"/>
        <xsl:param name="pPageSizeParam" as="xs:string"/>

        <div class="ae-pager">
            <xsl:choose>
                <xsl:when test="$pTotal > $pPageSize">
                    <xsl:variable name="vTotalPages" select="(fn:floor( ( $pTotal - 1 ) div $pPageSize ) + 1) cast as xs:integer" as="xs:integer"/>

                    <xsl:text>Page </xsl:text>
                    <xsl:call-template name="table-pager-page">
                        <xsl:with-param name="pPage" select="1"/>
                        <xsl:with-param name="pCurrentPage" select="$pPage"/>
                        <xsl:with-param name="pPageSize" select="$pPageSize"/>
                        <xsl:with-param name="pTotalPages" select="$vTotalPages"/>
                        <xsl:with-param name="pPageParam" select="$pPageParam"/>
                        <xsl:with-param name="pPageSizeParam" select="$pPageSizeParam"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>&#160;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="table-pager-page">
        <xsl:param name="pPage" as="xs:integer"/>
        <xsl:param name="pCurrentPage" as="xs:integer"/>
        <xsl:param name="pPageSize" as="xs:integer"/>
        <xsl:param name="pTotalPages" as="xs:integer"/>
        <xsl:param name="pPageParam" as="xs:string"/>
        <xsl:param name="pPageSizeParam" as="xs:string"/>

        <xsl:if test="$pPage &lt;= $pTotalPages">

            <xsl:choose>
                <xsl:when test="$pPage = $pCurrentPage">
                    <span><xsl:value-of select="$pPage"/></span>
                </xsl:when>
                <xsl:when test="($pPage = 2) and ($pCurrentPage > 4) and ($pTotalPages > 8)">
                    <xsl:text>..</xsl:text>
                </xsl:when>
                <xsl:when test="($pPage = ($pTotalPages - 1)) and (($pTotalPages - $pCurrentPage) > 3) and ($pTotalPages > 8)">
                    <xsl:text>..</xsl:text>
                </xsl:when>
                <xsl:when test="($pPage = 1) or (($pPage &lt; 7) and ($pCurrentPage &lt; 4)) or (fn:abs($pPage - $pCurrentPage) &lt; 3)">
                    <a href="{$context-path}{$relative-uri}?{ae:setQSParam(ae:setQSParam($query-string, $pPageParam, fn:string($pPage)), $pPageSizeParam, fn:string($pPageSize))}">
                        <xsl:value-of select="$pPage"/>
                    </a>
                </xsl:when>
                <xsl:when test="((($pTotalPages - $pCurrentPage) &lt; 2) and ($pTotalPages - $pPage &lt; 6)) or ($pPage = $pTotalPages) or ($pTotalPages &lt;= 6)">
                    <a href="{$context-path}{$relative-uri}?{ae:setQSParam(ae:setQSParam($query-string, $pPageParam, fn:string($pPage)), $pPageSizeParam, fn:string($pPageSize))}">
                        <xsl:value-of select="$pPage"/>
                    </a>
                </xsl:when>
            </xsl:choose>

            <xsl:if test="$pPage &lt; $pTotalPages">
                <xsl:call-template name="table-pager-page">
                    <xsl:with-param name="pPage" select="$pPage + 1"/>
                    <xsl:with-param name="pCurrentPage" select="$pCurrentPage"/>
                    <xsl:with-param name="pPageSize" select="$pPageSize"/>
                    <xsl:with-param name="pTotalPages" select="$pTotalPages"/>
                    <xsl:with-param name="pPageParam" select="$pPageParam"/>
                    <xsl:with-param name="pPageSizeParam" select="$pPageSizeParam"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>

    </xsl:template>

    <xsl:template name="table-pager">
        <xsl:param name="pColumnsToSpan" as="xs:integer"/>
        <xsl:param name="pName" as="xs:string"/>
        <xsl:param name="pParamPrefix" as="xs:string" select="''"/>
        <xsl:param name="pTotal" as="xs:integer"/>
        <xsl:param name="pPage" as="xs:integer"/>
        <xsl:param name="pPageSize" as="xs:integer"/>

        <xsl:variable name="vPageParam" select="fn:concat($pParamPrefix, 'page')"/>
        <xsl:variable name="vPageSizeParam" select="fn:concat($pParamPrefix, 'pagesize')"/>

        <xsl:variable name="vFrom" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$pPage > 0"><xsl:value-of select="1 + ( $pPage - 1 ) * $pPageSize"/></xsl:when>
                <xsl:when test="$pTotal = 0">0</xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vTo" as="xs:integer">
            <xsl:choose>
                <xsl:when test="( $vFrom + $pPageSize - 1 ) > $pTotal"><xsl:value-of select="$pTotal"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$vFrom + $pPageSize - 1"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <tr>
            <th colspan="{$pColumnsToSpan}" class="col_pager">
                <xsl:call-template name="table-pager-pages">
                    <xsl:with-param name="pPage" select="$pPage"/>
                    <xsl:with-param name="pPageSize" select="$pPageSize"/>
                    <xsl:with-param name="pTotal" select="$pTotal"/>
                    <xsl:with-param name="pPageParam" select="$vPageParam"/>
                    <xsl:with-param name="pPageSizeParam" select="$vPageSizeParam"/>
                </xsl:call-template>
                <xsl:call-template name="table-page-size">
                    <xsl:with-param name="pCurrentPageSize" select="$pPageSize"/>
                    <xsl:with-param name="pTotal" select="$pTotal"/>
                    <xsl:with-param name="pPageParam" select="$vPageParam"/>
                    <xsl:with-param name="pPageSizeParam" select="$vPageSizeParam"/>
                </xsl:call-template>
                <div class="ae-stats">
                    <xsl:if test="$pTotal > $pPageSize">
                        <xsl:text>Showing </xsl:text>
                        <span>
                            <xsl:value-of select="$vFrom"/>
                            <xsl:text> - </xsl:text>
                            <xsl:value-of select="$vTo"/>
                        </span>
                        <xsl:text> of </xsl:text>
                    </xsl:if>
                    <span><xsl:value-of select="$pTotal"/></span>
                    <xsl:value-of select="fn:concat(' ', $pName)"/>
                    <xsl:if test="$pTotal != 1">
                        <xsl:text>s</xsl:text>
                    </xsl:if>
                </div>
            </th>
        </tr>
    </xsl:template>

</xsl:stylesheet>