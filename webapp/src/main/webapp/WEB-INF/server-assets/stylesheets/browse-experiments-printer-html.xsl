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

    <!-- dynamically set by QueryServlet: host name (as seen from client) and base context path of webapp -->
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:variable name="vQueryDesc" select="ae:describeQuery($queryid)"/>

    <xsl:output omit-xml-declaration="yes" method="html" indent="no" encoding="ISO-8859-1" />

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">
        <html lang="en">
            <xsl:call-template name="page-header-plain">
                <xsl:with-param name="pTitle">
                    <xsl:text>ArrayExpress Archive Experiments</xsl:text>
                    <xsl:if test="string-length($vQueryDesc)>0">
                        <xsl:text> </xsl:text><xsl:value-of select="$vQueryDesc"/>
                    </xsl:if>
                </xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="assets/stylesheets/ae_common-1.4.css" type="text/css"/>
                    <link rel="stylesheet" href="assets/stylesheets/ae_browse_printer-1.4.css" type="text/css"/>
                    <script src="assets/scripts/jquery-1.3.1.min.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body-plain"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex('experiments', $queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredExperiments)"/>

        <div class="ae_left_container_100pc assign_font">
            <div id="ae_header"><img src="assets/images/ae_header.gif" alt="ArrayExpress"/></div>
            <xsl:choose>
                <xsl:when test="$vTotal&gt;0">
                    <div id="ae_results_header">
                        <xsl:text>There </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$vTotal = 1">
                                <xsl:text>is an experiment </xsl:text>                                
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>are </xsl:text>
                                <xsl:value-of select="$vTotal"/>
                                <xsl:text> experiments </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <strong><xsl:value-of select="$vQueryDesc"/></strong>
                        <xsl:text> found in ArrayExpress Archive.</xsl:text>
                        <span id="ae_print_controls" class="noprint"><a href="javascript:window.print()"><img src="{$basepath}/assets/images/silk_print.gif" width="16" height="16" alt="Print"/>Print this window</a>.</span>
                    </div>
                    <table id="ae_results_table" border="0" cellpadding="0" cellspacing="0">
                        <thead>
                            <tr>
                                <th class="col_accession">
                                    <xsl:text>ID</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'accession'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_title">
                                    <xsl:text>Title</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'name'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_assays">
                                    <xsl:text>Assays</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'assays'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_species">
                                    <xsl:text>Species</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'species'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_releasedate">
                                    <xsl:text>Release Date</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'releasedate'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_processed">
                                    <xsl:text>Processed</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'fgem'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_raw">
                                    <xsl:text>Raw</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'raw'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_inatlas">
                                    <xsl:text>Atlas</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'atlas'"/>
                                    </xsl:call-template>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:call-template name="ae-sort-experiments">
                                <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                                <xsl:with-param name="pFrom"/>
                                <xsl:with-param name="pTo"/>
                                <xsl:with-param name="pSortBy" select="$sortby"/>
                                <xsl:with-param name="pSortOrder" select="$sortorder"/>
                            </xsl:call-template>
                        </tbody>
                    </table>
                </xsl:when>
                <xsl:otherwise>
                    <div id="ae_infotext">
                        <div>There are no experiments <strong><xsl:value-of select="$vQueryDesc"/></strong> found in ArrayExpress Archive.</div>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:variable name="vExpId" select="id"/>
        <tr>
            <td class="col_accession">
                <div>
                    <xsl:apply-templates select="accession" mode="highlight" />
                    <xsl:if test="not(user = '1')">
                        <img src="{$basepath}/assets/images/silk_lock.gif" width="8" height="9"/>
                    </xsl:if>
                </div>
            </td>
            <td class="col_title">
                <div>
                    <xsl:apply-templates select="name" mode="highlight" />
                    <xsl:if test="count(name) = 0">&#160;</xsl:if>
                </div>
            </td>
            <td class="col_assays">
                <div>
                    <xsl:apply-templates select="assays" mode="highlight" />
                    <xsl:if test="count(assays) = 0">&#160;</xsl:if>
                </div>
            </td>
            <td class="col_species">
                <div>
                    <xsl:for-each select="species">
                        <xsl:apply-templates select="." mode="highlight" />
                        <xsl:if test="position() != last()">, </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(species) = 0"><xsl:text>&#160;</xsl:text></xsl:if>
                </div>
            </td>
            <td class="col_releasedate">
                <div>
                    <xsl:apply-templates select="releasedate" mode="highlight" />
                    <xsl:if test="count(releasedate) = 0">&#160;</xsl:if>
                </div>
            </td>
            <td class="col_processed">
                <div>
                    <xsl:call-template name="data-files-main"><xsl:with-param name="pKind" select="'fgem'"/></xsl:call-template>
                </div>
            </td>
            <td class="col_raw">
                <div>
                    <xsl:call-template name="data-files-main"><xsl:with-param name="pKind" select="'raw'"/></xsl:call-template>
                </div>
            </td>
            <td class="col_inatlas">
                <div>
                    <xsl:choose>
                        <xsl:when test="@loadedinatlas"><a href="${interface.application.link.atlas.exp_query.url}{accession}"><img src="{$basepath}/assets/images/silk_tick.gif" width="16" height="16" alt="*"/></a></xsl:when>
                        <xsl:otherwise><img src="{$basepath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/></xsl:otherwise>
                    </xsl:choose>
                </div>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="data-files-main">
        <xsl:param name="pKind"/>
        <xsl:variable name="vFiles" select="file[kind = $pKind]"/>
        <xsl:choose>
            <xsl:when test="$vFiles"><img src="{$basepath}/assets/images/silk_tick.gif" width="16" height="16" alt="*"/></xsl:when>
            <xsl:otherwise><img src="{$basepath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="add-sort">
        <xsl:param name="pKind"/>
        <xsl:if test="$pKind = $sortby">
            <xsl:choose>
                <xsl:when test="'ascending' = $sortorder"><img src="{$basepath}/assets/images/mini_arrow_up.gif" width="12" height="16" alt="^"/></xsl:when>
                <xsl:otherwise><img src="{$basepath}/assets/images/mini_arrow_down.gif" width="12" height="16" alt="v"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="highlight">
        <xsl:value-of select="."/>
    </xsl:template>
</xsl:stylesheet>
