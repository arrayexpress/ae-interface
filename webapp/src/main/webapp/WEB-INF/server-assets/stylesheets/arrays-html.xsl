<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="search html"
                exclude-result-prefixes="search html"
                version="2.0">

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>

    <xsl:param name="queryid"/>

    <!-- dynamically set by QueryServlet: host name (as seen from client) and base context path of webapp -->
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="ISO-8859-1" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-sort-arrays.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">
                    <xsl:text>Platform Designs | ArrayExpress Archive | EBI</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_common_20.css" type="text/css"/>
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_arrays_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_arrays_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">

        <xsl:variable name="vFilteredArrays" select="search:queryIndex('arrays', $queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredArrays)"/>

        <div class="ae_left_container_100pc assign_font">
            <div id="ae_content">
                <div id="ae_header"><img src="{$basepath}/assets/images/ae_header.gif" alt="ArrayExpress"/></div>
                <xsl:choose>
                    <xsl:when test="$vTotal&gt;0">
                        <div id="ae_results_header">
                            <xsl:text>There </xsl:text>
                            <xsl:choose>
                                <xsl:when test="$vTotal = 1">
                                    <xsl:text>is a platform design </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>are </xsl:text>
                                    <xsl:value-of select="$vTotal"/>
                                    <xsl:text> platform designs </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> matching your search criteria found in ArrayExpress Archive.</xsl:text>
                            <span id="ae_print_controls" class="noprint"><a href="javascript:window.print()"><img src="{$basepath}/assets/images/silk_print.gif" width="16" height="16" alt="Print"/>Print this window</a>.</span>
                        </div>
                        <table id="ae_results_table" border="0" cellpadding="0" cellspacing="0">
                            <thead>
                                <tr>
                                    <th class="col_accession sortable">
                                        <xsl:text>Accession</xsl:text>
                                        <xsl:call-template name="add-sort">
                                            <xsl:with-param name="pKind" select="'accession'"/>
                                        </xsl:call-template>
                                    </th>
                                    <th class="col_name sortable">
                                        <xsl:text>Name</xsl:text>
                                        <xsl:call-template name="add-sort">
                                            <xsl:with-param name="pKind" select="'name'"/>
                                        </xsl:call-template>
                                    </th>
                                    <th class="col_species sortable">
                                        <xsl:text>Species</xsl:text>
                                        <xsl:call-template name="add-sort">
                                            <xsl:with-param name="pKind" select="'species'"/>
                                        </xsl:call-template>
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:call-template name="ae-sort-arrays">
                                    <xsl:with-param name="pArrays" select="$vFilteredArrays"/>
                                    <xsl:with-param name="pFrom"/>
                                    <xsl:with-param name="pTo"/>
                                    <xsl:with-param name="pSortBy" select="$sortby"/>
                                    <xsl:with-param name="pSortOrder" select="$sortorder"/>
                                </xsl:call-template>
                            </tbody>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="block-warning">
                            <xsl:with-param name="pStyle" select="'ae_warn_area'"/>
                            <xsl:with-param name="pMessage">
                                <xsl:text>There are no platform designs matching your search criteria found in ArrayExpress Archive.</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="array_design">
        <tr>
            <td class="col_accession">
                <div>
                    <a href="{$basepath}/arrays/{accession}">
                        <xsl:value-of select="accession"/>
                    </a>
                    <xsl:if test="not(user/@id = '1')">
                        <img src="{$basepath}/assets/images/silk_lock.gif" width="8" height="9"/>
                    </xsl:if>
                </div>
            </td>
            <td class="col_name">
                <div>
                    <xsl:value-of select="name"/>
                    <xsl:if test="count(name) = 0">&#160;</xsl:if>
                </div>
            </td>
            <td class="col_species">
                <div>
                    <xsl:value-of select="string-join(species, ', ')"/>
                    <xsl:if test="count(species) = 0"><xsl:text>&#160;</xsl:text></xsl:if>
                </div>
            </td>
        </tr>
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

</xsl:stylesheet>
