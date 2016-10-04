<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2014 European Molecular Biology Laboratory
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
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae fn search html xs"
                exclude-result-prefixes="ae fn search html xs"
                version="2.0">

    <xsl:param name="page"/>
    <xsl:param name="pagesize"/>
    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>

    <xsl:param name="queryid"/>
    <xsl:param name="keywords"/>
    <xsl:param name="directsub"/>
    <xsl:param name="private"/>
    <xsl:param name="organism"/>
    <xsl:param name="array"/>
    <xsl:param name="exptype"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>
    <xsl:include href="ae-sort-experiments.xsl"/>
    <xsl:include href="ae-date-functions.xsl"/>

    <xsl:variable name="vSearchMode" select="$keywords != ''"/>
    <xsl:variable name="vFilterMode" select="$organism != '' or $exptype != '' or $array != '' or $directsub != '' or $private != ''"/>
    <xsl:variable name="vQueryString" select="if ($query-string) then fn:concat('?', $query-string) else ''"/>
    <xsl:variable name="vUnrestrictedAccess" select="fn:not($userid)"/>

    <xsl:variable name="vFilteredExperiments" select="search:queryIndex($queryid)"/>
    <xsl:variable name="vTotal" select="count($vFilteredExperiments)"/>

    <xsl:template match="/">
        <xsl:variable name="vTitle" select="if ($vSearchMode) then fn:concat('Search results for &quot;', $keywords, '&quot;') else 'Browse'"/>

        <xsl:call-template name="ae-page">
            <xsl:with-param name="pIsSearchVisible" select="fn:true()"/>
            <xsl:with-param name="pSearchInputValue" select="$keywords"/>
            <xsl:with-param name="pExtraSearchFields">
                <xsl:if test="$organism != ''">
                    <input type="hidden" name="organism" value="{$organism}"/>
                </xsl:if>
                <xsl:if test="$array != ''">
                    <input type="hidden" name="array" value="{$array}"/>
                </xsl:if>
                <xsl:if test="$exptype[1] != ''">
                    <input type="hidden" name="exptype[]" value="{$exptype[1]}"/>
                </xsl:if>
                <xsl:if test="$exptype[2] != ''">
                    <input type="hidden" name="exptype[]" value="{$exptype[2]}"/>
                </xsl:if>
                <xsl:if test="$directsub != ''">
                    <input type="hidden" name="directsub" value="{$directsub}"/>
                </xsl:if>
                <xsl:if test="$private != ''">
                    <input type="hidden" name="private" value="{$private}"/>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="pTitleTrail" select="$vTitle"/>
            <xsl:with-param name="pExtraCSS">
                <link rel="stylesheet" href="{$context-path}/assets/stylesheets/ae-experiments-browse-1.0.150225.css" type="text/css"/>
            </xsl:with-param>
            <xsl:with-param name="pBreadcrumbTrail"/>
            <!--
            <xsl:if test="$vTotal > 0"><xsl:value-of select="$vTitle"/></xsl:if></xsl:with-param>
            -->
            <xsl:with-param name="pExtraJS">
                <script src="//www.ebi.ac.uk/web_guidelines/js/ebi-global-search-run.js" type="text/javascript"/>
                <script src="//www.ebi.ac.uk/web_guidelines/js/ebi-global-search.js" type="text/javascript"/>
                <script src="{$context-path}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                <script src="{$context-path}/assets/scripts/jquery.ae-experiments-browse-1.0.150312.js" type="text/javascript"/>
            </xsl:with-param>
            <xsl:with-param name="pExtraBodyClasses" select="if ($vTotal = 0) then 'noresults' else ''"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="ae-content-section">
        <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'releasedate'"/>
        <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'descending'"/>

        <xsl:variable name="vPage" select="if ($page and $page castable as xs:integer) then $page cast as xs:integer else 1" as="xs:integer"/>
        <xsl:variable name="vPageSize" select="if ($pagesize and $pagesize castable as xs:integer) then $pagesize cast as xs:integer else 25" as="xs:integer"/>

        <xsl:variable name="vFrom" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$vPage > 0"><xsl:value-of select="1 + ( $vPage - 1 ) * $vPageSize"/></xsl:when>
                <xsl:when test="$vTotal = 0">0</xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vTo" as="xs:integer">
            <xsl:choose>
                <xsl:when test="( $vFrom + $vPageSize - 1 ) > $vTotal"><xsl:value-of select="$vTotal"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$vFrom + $vPageSize - 1"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <xsl:choose>
            <xsl:when test="$vTotal&gt;0">
                <section class="grid_6 alpha shortcuts expander" id="search-filters">
                    <div id="ae-filters">
                        <h3 class="slideToggle icon icon-functional" data-icon="f">Filter search results<i class="fa fa-spinner fa-pulse"/></h3>
                        <form id="ae-filters-expanded" method="get" style="display:none">
                            <input id="ae-keywords" type="hidden" name="keywords" value="{$keywords}" maxlength="255"/>
                            <label for="ae-organism">By organism:</label>
                            <select id="ae-organism" name="organism" disabled="on">
                                <option value="">All organisms (loading options)</option>
                            </select>
                            <label for="ae-expdesign">By experiment type:</label>
                            <select id="ae-expdesign" name="exptype[]" disabled="on">
                                <option value="">All assays by molecule (loading options)</option>
                            </select>
                            <select id="ae-exptech" name="exptype[]" disabled="on">
                                <option value="">All technologies (loading options)</option>
                            </select>
                            <label for="ae-array">By array:</label>
                            <select id="ae-array" name="array" disabled="on">
                                <option value="">All arrays (loading options)</option>
                            </select>
                            <xsl:if test="not($userid = '1')">
                                <div class="option">
                                    <input id="ae-private" name="private" type="checkbox" title="Select the 'My private data only' check box to query private data only.">
                                        <xsl:if test="$private = 'on'">
                                            <xsl:attribute name="checked"/>
                                        </xsl:if>
                                    </input>
                                    <label for="ae-private" title="Select the 'My private data only' check box to query private data only.">My private data only</label>
                                </div>
                            </xsl:if>
                            <div class="option">
                                <input id="ae-directsub" name="directsub" type="checkbox" title="By default all data from GEO and ArrayExpress are queried. Select the 'ArrayExpress data only' check box to query data submitted directly to ArrayExpress. If you want to query GEO data only include AND E-GEOD* in your query. E.g. cancer AND E-GEOD* will retrieve all GEO experiments with cancer annotations.">
                                    <xsl:if test="$directsub = 'on'">
                                        <xsl:attribute name="checked"/>
                                    </xsl:if>
                                </input>
                                <label for="ae-directsub" title="By default all data from GEO and ArrayExpress are queried. Select the 'ArrayExpress data only' check box to query data submitted directly to ArrayExpress. If you want to query GEO data only include AND E-GEOD* in your query. E.g. cancer AND E-GEOD* will retrieve all GEO experiments with cancer annotations.">ArrayExpress data only</label>
                            </div>
                            <a href="#" class="reset">Reset filters</a>
                            <input id="ae-filters-submit" class="submit" type="submit" value="Filter"/>
                        </form>
                    </div>
                    <xsl:text>&#160;</xsl:text>
                </section>
                <section class="grid_12 search-title">
                    <xsl:if test="$vSearchMode">
                        <h3>
                            <xsl:text>Search results for </xsl:text>
                            <span class="ae_keywords"><xsl:value-of select="$keywords"/></span>
                        </h3>
                    </xsl:if>
                    <xsl:if test="$vFilterMode">
                        <h5>
                            <xsl:text>Filtered by </xsl:text>
                            <xsl:call-template name="ae-filter-desc">
                                <xsl:with-param name="pFields" select="('organism', 'experiment type', 'experiment type', 'array', 'AE only', 'private')"/>
                                <xsl:with-param name="pValues" select="(fn:string($organism), fn:string($exptype[1]), fn:string($exptype[2]), fn:string($array), fn:string($directsub), fn:string($private))"/>
                            </xsl:call-template>
                        </h5>
                    </xsl:if>
                    <xsl:if test="fn:not($vSearchMode) and fn:not($vFilterMode)"><xsl:text>&#160;</xsl:text></xsl:if>
                </section>
                <xsl:if test="$vSearchMode">
                    <aside class="grid_6 omega shortcuts expander" id="search-extras">
                        <div id="ebi_search_results">
                            <h3 class="slideToggle icon icon-functional" data-icon="u">Show more data from EMBL-EBI<i class="fa fa-spinner fa-pulse"/></h3>
                        </div>
                    </aside>
                </xsl:if>
                <section class="grid_24 alpha omega">
                    <div id="ae-content">
                        <div id="ae-browse">
                            <div class="persist-area">
                                <table class="persist-header" border="0" cellpadding="0" cellspacing="0">
                                    <col class="col_accession"/>
                                    <col class="col_name"/>
                                    <col class="col_type"/>
                                    <col class="col_organism"/>
                                    <col class="col_assays"/>
                                    <col class="col_releasedate"/>
                                    <col class="col_processed"/>
                                    <col class="col_raw"/>
                                    <col class="col_views"/>
                                    <xsl:if test="$vUnrestrictedAccess">
                                        <col class="col_downloads"/>
                                        <col class="col_complete_downloads"/>
                                    </xsl:if>
                                    <col class="col_atlas"/>
                                    <thead>
                                        <xsl:call-template name="table-pager">
                                            <xsl:with-param name="pColumnsToSpan" select="if ($vUnrestrictedAccess) then 12 else 10"/>
                                            <xsl:with-param name="pName" select="'experiment'"/>
                                            <xsl:with-param name="pTotal" select="$vTotal"/>
                                            <xsl:with-param name="pPage" select="$vPage"/>
                                            <xsl:with-param name="pPageSize" select="$vPageSize"/>
                                        </xsl:call-template>
                                        <tr>
                                            <th class="col_accession sortable">
                                                <xsl:text>Accession</xsl:text>
                                                <xsl:call-template name="add-table-sort">
                                                    <xsl:with-param name="pKind" select="'accession'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_name sortable">
                                                <xsl:text>Title</xsl:text>
                                                <xsl:call-template name="add-table-sort">
                                                    <xsl:with-param name="pKind" select="'name'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_type sortable">
                                                <xsl:text>Type</xsl:text>
                                                <xsl:call-template name="add-table-sort">
                                                    <xsl:with-param name="pKind" select="'type'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_organism sortable">
                                                <xsl:text>Organism</xsl:text>
                                                <xsl:call-template name="add-table-sort">
                                                    <xsl:with-param name="pKind" select="'organism'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_assays sortable">
                                                <xsl:text>Assays</xsl:text>
                                                <xsl:call-template name="add-table-sort">
                                                    <xsl:with-param name="pKind" select="'assays'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_releasedate sortable">
                                                <xsl:text>Released</xsl:text>
                                                <xsl:call-template name="add-table-sort">
                                                    <xsl:with-param name="pKind" select="'releasedate'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_processed sortable">
                                                <xsl:text>Processed</xsl:text>
                                                <xsl:call-template name="add-table-sort">
                                                    <xsl:with-param name="pKind" select="'processed'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_raw sortable">
                                                <xsl:text>Raw</xsl:text>
                                                <xsl:call-template name="add-table-sort">
                                                    <xsl:with-param name="pKind" select="'raw'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_views sortable">
                                                <xsl:text>Views</xsl:text>
                                                <xsl:call-template name="add-table-sort">
                                                    <xsl:with-param name="pKind" select="'views'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <xsl:if test="$vUnrestrictedAccess">
                                                <th class="col_downloads sortable">
                                                    <xsl:text>DL Attempts</xsl:text>
                                                    <xsl:call-template name="add-table-sort">
                                                        <xsl:with-param name="pKind" select="'downloads'"/>
                                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                    </xsl:call-template>
                                                </th>
                                                <th class="col_complete_downloads sortable">
                                                    <xsl:text>Complete DLs</xsl:text>
                                                    <xsl:call-template name="add-table-sort">
                                                        <xsl:with-param name="pKind" select="'complete_downloads'"/>
                                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <th class="col_atlas sortable">
                                                <xsl:text>Atlas</xsl:text>
                                                <xsl:call-template name="add-table-sort">
                                                    <xsl:with-param name="pKind" select="'atlas'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                        </tr>
                                    </thead>
                                </table>
                                <table class="experiments" border="0" cellpadding="0" cellspacing="0">
                                    <col class="col_accession"/>
                                    <col class="col_name"/>
                                    <col class="col_type"/>
                                    <col class="col_organism"/>
                                    <col class="col_assays"/>
                                    <col class="col_releasedate"/>
                                    <col class="col_processed"/>
                                    <col class="col_raw"/>
                                    <col class="col_views"/>
                                    <xsl:if test="$vUnrestrictedAccess">
                                        <col class="col_downloads"/>
                                        <col class="col_complete_downloads"/>
                                    </xsl:if>
                                    <col class="col_atlas"/>
                                    <tbody>
                                        <xsl:call-template name="ae-sort-experiments">
                                            <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                                            <xsl:with-param name="pFrom" select="$vFrom"/>
                                            <xsl:with-param name="pTo" select="$vTo"/>
                                            <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                            <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                        </xsl:call-template>
                                        <tr>
                                            <td colspan="{if ($vUnrestrictedAccess) then '12' else '10'}" class="col_footer">
                                                <a href="{$context-path}/ArrayExpress-Experiments.txt{$vQueryString}" class="icon icon-functional" data-icon="S">Export table in Tab-delimited format</a>
                                                <a href="{$context-path}/xml/v2/experiments{$vQueryString}" class="icon  icon-functional" data-icon="S">Export matching metadata in XML format</a>
                                                <a href="{$context-path}/rss/v2/experiments{$vQueryString}" class="icon icon-socialmedia" data-icon="R">Subscribe to RSS feed matching this search</a>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </section>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="browse-no-results"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>



        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <xsl:variable name="vAccession" select="accession"/>
            <xsl:variable name="vFiles" select="ae:getMappedValue('ftp-folder', $vAccession)"/>

            <tr>
                <td class="col_accession">
                    <div>
                        <a href="{$context-path}/experiments/{accession}/{$vQueryString}">
                            <xsl:if test="not(user/@id = '1')">
                                <xsl:attribute name="class" select="'icon icon-functional'"/>
                                <xsl:attribute name="data-icon" select="'L'"/>
                            </xsl:if>
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pQueryId" select="$queryid"/>
                                <xsl:with-param name="pText" select="accession"/>
                                <xsl:with-param name="pFieldName" select="'accession'"/>
                            </xsl:call-template>
                        </a>
                    </div>
                </td>
                <td class="col_name">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="fn:string-join(name, ', ')"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>

                    </div>
                </td>
                <td class="col_type">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="fn:string-join(experimenttype, ', ')"/>
                            <xsl:with-param name="pFieldName" select="'exptype'"/>
                        </xsl:call-template>

                    </div>
                </td>
                <td class="col_organism">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="fn:string-join(organism, ', ')"/>
                            <xsl:with-param name="pFieldName" select="'organism'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_assays">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="assays"/>
                            <xsl:with-param name="pFieldName" select="'assaycount'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_releasedate">
                    <div>
                        <xsl:value-of select="ae:formatDateShort(releasedate)"/>
                        <!-- TODO: implement proper highlighting (and date search TBH)
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="releasedate"/>
                            <xsl:with-param name="pFieldName" select="'date'"/>
                        </xsl:call-template>
                        -->
                    </div>
                </td>
                <td class="col_processed">
                    <div>
                        <xsl:call-template name="data-files-main">
                            <xsl:with-param name="pAccession" select="$vAccession"/>
                            <xsl:with-param name="pEnaAccession" select="secondaryaccession[fn:matches(text(), '^(DRP|ERP|SRP)\d+$')]"/>
                            <xsl:with-param name="pFiles" select="$vFiles"/>
                            <xsl:with-param name="pKind" select="'processed'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_raw">
                    <div>
                        <xsl:call-template name="data-files-main">
                            <xsl:with-param name="pAccession" select="$vAccession"/>
                            <xsl:with-param name="pEnaAccession" select="secondaryaccession[fn:matches(text(), '^(DRP|ERP|SRP)\d+$')]"/>
                            <xsl:with-param name="pFiles" select="$vFiles"/>
                            <xsl:with-param name="pKind" select="'raw'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_views">
                    <div>
                        <xsl:choose>
                            <xsl:when test="@views">
                                <xsl:value-of select="@views"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>-</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </td>
                <xsl:if test="$vUnrestrictedAccess">
                    <td class="col_downloads">
                        <div>
                            <xsl:choose>
                                <xsl:when test="@downloads">
                                    <xsl:value-of select="@downloads"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>-</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </td>
                    <td class="col_complete_downloads">
                        <div>
                            <xsl:choose>
                                <xsl:when test="@completedownloads">
                                    <xsl:value-of select="@completedownloads"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>-</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </td>
                </xsl:if>
                <td class="col_atlas">
                    <div>
                        <xsl:choose>
                            <xsl:when test="@loadedinatlas">
                                <a href="${interface.application.link.atlas.exp_query.url}{accession}" title="Link to Atlas">
                                    <span class="icon icon-generic" data-icon="L"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>-</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="data-files-main">
        <xsl:param name="pAccession"/>
        <xsl:param name="pEnaAccession"/>
        <xsl:param name="pFiles"/>
        <xsl:param name="pKind"/>

        <xsl:variable name="vFiles" select="$pFiles/file[@kind = $pKind]"/>
        <xsl:choose>
            <xsl:when test="fn:count($vFiles) > 1">
                <a href="{$context-path}/experiments/{$pAccession}/files/{$pKind}/" title="Link to file download page">
                    <span class="icon icon-generic" data-icon="L"/>
                </a>
            </xsl:when>
            <xsl:when test="fn:count($vFiles) = 1">
                <a href="{$context-path}/files/{$pAccession}/{$vFiles[1]/@name}" title="Direct download">
                    <span class="icon icon-functional" data-icon="="/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="fn:not($pKind = 'raw' and fn:exists(seqdatauri))"><xsl:text>-</xsl:text></xsl:if>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$pKind = 'raw'">
            <xsl:if test="fn:exists($vFiles) and fn:exists(seqdatauri)">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:for-each-group select="seqdatauri" group-by="fn:contains(., '/ena/')">
                <xsl:choose>
                    <xsl:when test="fn:current-grouping-key()">
                        <xsl:choose>
                            <xsl:when test="fn:count(fn:current-group()) = 1
                                            and fn:matches(fn:current-group()[1], '/[DES]RR\d+$')">
                                <a href="{fn:current-group()[1]}" title="Go to European Nucleotide Archive run"><img src="{$context-path}/assets/images/ena-icon-16.svg" width="22" height="16" alt="ENA"/></a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="$pEnaAccession">
                                    <a href="http://www.ebi.ac.uk/ena/data/view/{.}" title="Go to European Nucleotide Archive to download all raw files for this experiment"><img src="{$context-path}/assets/images/ena-icon-16.svg" width="22" height="16" alt="ENA"/></a>
                                    <xsl:if test="fn:position() != fn:last()">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="fn:current-group()">
                            <xsl:choose>
                                <xsl:when test="fn:contains(., '/ega/')">
                                    <a href="{.}" title="Go to European Genome-phenome Archive study"><img src="{$context-path}/assets/images/ega-icon-16.png" width="16" height="16" alt="EGA"/></a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a href="{.}">
                                        <span class="icon icon-generic" data-icon="L"/>
                                    </a>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="fn:position() != fn:last()">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:if>

    </xsl:template>

    <xsl:template name="browse-no-results">

        <section class="grid_18 alpha">
            <h2 class="alert">We’re sorry that we couldn’t find any matching experiments</h2>
            <p>Your search for <span class="alert"><xsl:value-of select="$keywords"/></span> returned no results.</p>
            <h3>Can’t find what you’re looking for?</h3>
            <p>Please <a href="#" class="feedback">contact us</a> for help if you get no or unexpected results.</p>
            <!-- TODO:
            <h3>Did you mean...</h3>
            <ul>
                <li>Suggestion 1</li>
                <li>Suggestion 2</li>
                <li>Suggestion 3</li>
            </ul>
            -->
        </section>
        <aside class="grid_6 omega shortcuts" id="search-extras">
            <div id="ebi_search_results">
                <h3>More data from EMBL-EBI</h3>
            </div>
        </aside>

    </xsl:template>

    <xsl:template name="ae-filter-desc">
        <xsl:param name="pFields" as="xs:string*"/>
        <xsl:param name="pValues" as="xs:string*"/>
        <xsl:variable name="vDescs">
            <xsl:for-each select="$pValues">
                <xsl:variable name="vPos" select="fn:position()"/>
                <xsl:if test=". != ''">
                    <d>
                        <span class="ae_field"><xsl:value-of select="$pFields[$vPos]"/></span>
                        <xsl:text>&#160;</xsl:text>
                        <span class="ae_value"><xsl:value-of select="$pValues[$vPos]"/></span>
                    </d>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$vDescs/d">
            <xsl:copy-of select="*|text()"/>
            <xsl:if test="fn:position() != fn:last()">, </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
