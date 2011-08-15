<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="aejava search html"
                exclude-result-prefixes="aejava search html"
                version="2.0">
    
    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'releasedate'"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'descending'"/>

    <xsl:param name="queryid"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">
        <html lang="en">
            <xsl:call-template name="page-header-plain">
                <xsl:with-param name="pTitle">
                    <xsl:text>Experiments | ArrayExpress Archive | EBI</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_common_20.css" type="text/css"/>
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_browse_printer_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_browse_printer_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body-plain"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredExperiments)"/>

        <div class="ae_left_container_100pc">
            <div id="ae_header"><img src="{$basepath}/assets/images/ae_header.gif" alt="ArrayExpress"/></div>
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
                        <xsl:text> matching your search criteria found in ArrayExpress Archive.</xsl:text>
                        <span id="ae_print_controls" class="noprint"><a href="javascript:window.print()"><img src="{$basepath}/assets/images/silk_print.gif" width="16" height="16" alt="Print"/>Print this window</a>.</span>
                    </div>
                    <table id="ae_results_table" border="0" cellpadding="0" cellspacing="0">
                        <thead>
                            <tr>
                                <th class="col_accession sortable">
                                    <xsl:text>ID</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'accession'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_name sortable">
                                    <xsl:text>Title</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'name'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_assays sortable">
                                    <xsl:text>Assays</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'assays'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_species sortable">
                                    <xsl:text>Species</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'species'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_releasedate sortable">
                                    <xsl:text>Release Date</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'releasedate'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_fgem sortable">
                                    <xsl:text>Processed</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'fgem'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_raw sortable">
                                    <xsl:text>Raw</xsl:text>
                                    <xsl:call-template name="add-sort">
                                        <xsl:with-param name="pKind" select="'raw'"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_atlas sortable">
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
                                <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                            </xsl:call-template>
                        </tbody>
                    </table>
                </xsl:when>
                <xsl:otherwise>
                    <div id="ae_infotext">
                        <div>There are no experiments matching your search criteria found in ArrayExpress Archive.</div>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:variable name="vAccession" select="accession"/>
        
        <tr>
            <td class="col_accession">
                <div>
                    <a href="{$basepath}/experiments/{accession}">
                        <xsl:apply-templates select="accession" mode="copy" />
                    </a>
                    <xsl:if test="not(user/@id = '1')">
                        <img src="{$basepath}/assets/images/silk_lock.gif" width="8" height="9"/>
                    </xsl:if>
                </div>
            </td>
            <td class="col_name">
                <div>
                    <xsl:apply-templates select="name" mode="copy" />
                    <xsl:if test="count(name) = 0">&#160;</xsl:if>
                </div>
            </td>
            <td class="col_assays">
                <div>
                    <xsl:apply-templates select="assays" mode="copy" />
                    <xsl:if test="count(assays) = 0">&#160;</xsl:if>
                </div>
            </td>
            <td class="col_species">
                <div>
                    <xsl:for-each select="species">
                        <xsl:apply-templates select="." mode="copy" />
                        <xsl:if test="position() != last()">, </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(species) = 0"><xsl:text>&#160;</xsl:text></xsl:if>
                </div>
            </td>
            <td class="col_releasedate">
                <div>
                    <xsl:apply-templates select="releasedate" mode="copy" />
                    <xsl:if test="count(releasedate) = 0">&#160;</xsl:if>
                </div>
            </td>
            <td class="col_fgem">
                <div>
                    <xsl:call-template name="data-files-main">
                        <xsl:with-param name="pAccession" select="$vAccession"/>
                        <xsl:with-param name="pKind" select="'fgem-files'"/>
                    </xsl:call-template>
                </div>
            </td>
            <td class="col_raw">
                <div>
                    <xsl:call-template name="data-files-main">
                        <xsl:with-param name="pAccession" select="$vAccession"/>
                        <xsl:with-param name="pKind" select="'raw-files'"/>
                    </xsl:call-template>
                </div>
            </td>
            <td class="col_atlas">
                <div>
                    <xsl:choose>
                        <xsl:when test="@loadedinatlas"><a href="${interface.application.link.atlas.exp_query.url}{accession}"><img src="{$basepath}/assets/images/basic_tick.gif" width="16" height="16" alt="*"/></a></xsl:when>
                        <xsl:otherwise><img src="{$basepath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/></xsl:otherwise>
                    </xsl:choose>
                </div>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="data-files-main">
        <xsl:param name="pAccession"/>
        <xsl:param name="pKind"/>
        <xsl:choose>
            <xsl:when test="'0' != aejava:getAcceleratorValue($pKind, $pAccession)"><img src="{$basepath}/assets/images/basic_tick.gif" width="16" height="16" alt="*"/></xsl:when>
            <xsl:otherwise><img src="{$basepath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="add-sort">
        <xsl:param name="pKind"/>
        <xsl:if test="$pKind = $vSortBy">
            <xsl:choose>
                <xsl:when test="'ascending' = $vSortOrder"><img src="{$basepath}/assets/images/mini_arrow_up.gif" width="12" height="16" alt="^"/></xsl:when>
                <xsl:otherwise><img src="{$basepath}/assets/images/mini_arrow_down.gif" width="12" height="16" alt="v"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="copy">
        <xsl:value-of select="."/>
    </xsl:template>
</xsl:stylesheet>
