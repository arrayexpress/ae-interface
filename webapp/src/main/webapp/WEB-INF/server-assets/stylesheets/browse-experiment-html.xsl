<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae search html"
                exclude-result-prefixes="ae search html"
                version="2.0">

    <xsl:param name="sortby">releasedate</xsl:param>
    <xsl:param name="sortorder">descending</xsl:param>

    <xsl:param name="queryid"/>
    <xsl:param name="accession"/>

    <!-- dynamically set by QueryServlet: host name (as seen from client) and base context path of webapp -->
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    <xsl:variable name="vAccession" select="upper-case($accession)"/>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="ISO-8859-1" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" />

    <xsl:include href="ae-html-page.xsl"/>

    <xsl:template match="/experiments">
        <html lang="en">
            <xsl:call-template name="page-header-plain">
                <xsl:with-param name="pTitle">
                    <xsl:value-of select="$vAccession"/><xsl:text> | ArrayExpress Archive | EBI</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_common-1.4.css" type="text/css"/>
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_browse-1.4.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.caret-range-1.0.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.autocomplete-1.1.0m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_browse_experiment-1.4.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex('experiments', $queryid)"/>

        <div class="ae_centered_container_100pc assign_font">
            <div id="ae_keywords_filters_area">
                <div id="ae_keywords_filters_box">
                    <div class="form_outer">
                        <div class="form_top">
                            <div class="form_bottom">
                                <div class="form_left">
                                    <div class="form_right">
                                        <div class="form_bottom_left">
                                            <div class="form_bottom_right">
                                                <div class="form_top_left">
                                                    <div class="form_top_right">
                                                        <div id="ae_keywords_filters_inner_box">
                                                            <form method="get" action="{$basepath}/browse.html">
                                                                <fieldset id="ae_keywords_box">
                                                                    <label for="ae_keywords">Experiment, citation, sample and factor annotations [<a href="javascript:aeClearKeywords()">clear</a>]</label>
                                                                    <input id="ae_keywords" name="keywords" maxlength="200"/>
                                                                    <span>
                                                                        <input id="ae_directsub" name="directsub" type="checkbox" title="By default all data from GEO and ArrayExpress are queried. Select the 'ArrayExpress data only' check box to query data submitted directly to ArrayExpress. If you want to query GEO data only include AND E-GEOD* in your query. E.g. cancer AND E-GEOD8 will retrieve all GEO experiments with cancer annotations."/><label for="ae_directsub" title="By default all data from GEO and ArrayExpress are queried. Select the 'ArrayExpress data only' check box to query data submitted directly to ArrayExpress. If you want to query GEO data only include AND E-GEOD* in your query. E.g. cancer AND E-GEOD8 will retrieve all GEO experiments with cancer annotations.">ArrayExpress data only</label>
                                                                    </span>
                                                                </fieldset>
                                                                <fieldset id="ae_filters_box">
                                                                    <label for="ae_species">Filter on [<a href="javascript:aeResetFilters()">reset</a>]</label>
                                                                    <select id="ae_species" name="species" disabled="true"><option value="">All species (loading options)</option></select>
                                                                    <select id="ae_array" name="array" disabled="true"><option value="">All arrays (loading options)</option></select>
                                                                    <div id="ae_exptype_selector">
                                                                        <select id="ae_expdesign" name="exptype[]" disabled="true"><option value="">All assays by molecule (loading options)</option></select>
                                                                        <span>by</span>
                                                                        <select id="ae_exptech" name="exptype[]" disabled="true"><option value="">All technologies (loading options)</option></select>
                                                                    </div>
                                                                </fieldset>
                                                                <fieldset id="ae_options_box">
                                                                    <label>Display options [<a href="javascript:aeResetOptions()">reset</a>]</label>
                                                                    <div class="select_margin"><select id="ae_pagesize" name="pagesize"><option value="25">25</option><option value="50">50</option><option value="100">100</option><option value="250">250</option><option value="500">500</option></select><label for="ae_pagesize"> experiments per page</label></div>
                                                                    <input id="ae_keyword_filters_submit" type="submit" value="Query"/>
                                                                    <input type="hidden" id="ae_sortby" name="sortby"/>
                                                                    <input type="hidden" id="ae_sortorder" name="sortorder"/>
                                                                    <input type="hidden" id="ae_expandefo" name="expandefo" value="on"/>
                                                                    <div><input id="ae_detailedview" name="detailedview" type="checkbox"/><label for="ae_detailedview">Detailed view</label></div>
                                                                </fieldset>
                                                            </form>

                                                            <div id="ae_login_link"><a href="${interface.application.link.browse_help}"><img src="{$basepath}/assets/images/silk_help.gif" width="16" height="16" alt=""/>ArrayExpress Browser Help</a></div>
                                                            <div id="ae_logo_browse"><a href="${interface.application.base.path}" title="ArrayExpress Home"><img src="{$basepath}/assets/images/ae_logo_browse.gif" alt="ArrayExpress Home"/></a></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="ae_results_area">
                <xsl:if test="not($vFilteredExperiments)">Oops, no experiments found</xsl:if>
                <xsl:apply-templates select="$vFilteredExperiments"/>
            </div>

        </div>
    </xsl:template>

</xsl:stylesheet>
