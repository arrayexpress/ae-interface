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

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-sort-experiments.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>
    <xsl:include href="ae-date-functions.xsl"/>

    <xsl:variable name="vSearchMode" select="fn:ends-with($relative-uri, 'search.html')"/>

    <xsl:template match="/">
        <xsl:variable name="vTitle" select="if ($vSearchMode) then fn:concat('Search results for &quot;', $keywords, '&quot;') else 'Experiments'"/>

        <xsl:call-template name="ae-page">
            <xsl:with-param name="pIsFixedWidth" select="fn:false()"/>
            <xsl:with-param name="pIsSearchVisible" select="fn:true()"/>
            <xsl:with-param name="pSearchInputValue" select="if (fn:true()) then $keywords else ''"/>
            <xsl:with-param name="pTitleTrail" select="$vTitle"/>
            <xsl:with-param name="pExtraCSS">
                <link rel="stylesheet" href="{$context-path}/assets/stylesheets/ae-experiments-browse-1.0.0.css" type="text/css"/>
            </xsl:with-param>
            <xsl:with-param name="pBreadcrumbTrail" select="$vTitle"/>
            <xsl:with-param name="pExtraJS">
                <xsl:if test="fn:true()">
                    <script src="//www.ebi.ac.uk/web_guidelines/js/ebi-global-search-run.js" type="text/javascript"/>
                    <script src="//www.ebi.ac.uk/web_guidelines/js/ebi-global-search.js" type="text/javascript"/>
                </xsl:if>
                <script src="{$context-path}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                <script src="{$context-path}/assets/scripts/jquery.ae-experiments-browse-1.0.0.js" type="text/javascript"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="ae-content-section">
        <xsl:variable name="vFilteredExperiments" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredExperiments)"/>

        <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'releasedate'"/>
        <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'descending'"/>

        <xsl:variable name="vPage" select="if ($page) then $page cast as xs:integer else 1"/>
        <xsl:variable name="vPageSize" select="if ($pagesize) then $pagesize cast as xs:integer else 25"/>

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
                <xsl:if test="$vSearchMode">
                    <section class="grid_18 alpha">
                        <h2>ArrayExpress results for <span class="searchterm"><xsl:value-of select="$keywords"/></span></h2>
                    </section>
                    <aside class="grid_6 omega shortcuts expander" id="search-extras">
                        <div id="ebi_search_results"><h3 class="slideToggle icon icon-functional" data-icon="u">Show more data from EMBL-EBI</h3>
                        </div>
                    </aside>
                </xsl:if>
                <section>
                    <xsl:if test="$vSearchMode">
                        <xsl:attribute name="class" select="'grid_24 alpha omega'"/>
                    </xsl:if>
                    <div id="ae-content">
                        <div id="ae-browse">
                            <div id="ae-filters">
                                <form method="get" action="{$context-path}/experiments/browse.html">
                                    <fieldset>
                                        <legend>Filter experiments</legend>
                                        <!--
                                        <label for="ae-keywords" class="block">Experiment, citation, sample and factor annotations</label>
                                        -->
                                        <input id="ae-keywords" type="hidden" name="keywords" value="{$keywords}" maxlength="255"/>
                                        <label id="ae-organism-label" for="ae-organism">By organism</label>
                                        <label  id="ae-array-label" for="ae-array">By array</label>
                                        <label  id="ae-exptype-label" for="ae-expdesign">By experiment type</label>
                                        <select id="ae-organism" name="organism" disabled="on"><option value="">All organisms (loading options)</option></select>
                                        <select id="ae-array" name="array" disabled="on"><option value="">All arrays (loading options)</option></select>
                                        <select id="ae-expdesign" name="exptype[]" disabled="on"><option value="">All assays by molecule (loading options)</option></select>
                                        <select id="ae-exptech" name="exptype[]" disabled="on"><option value="">All technologies (loading options)</option></select>
                                        <div>
                                            <xsl:if test="not($userid = '1')">
                                                <div class="option">
                                                    <input id="ae-private" name="private" type="checkbox" title="Select the 'My private data only' check box to query private data only."/>
                                                    <label for="ae-private" title="Select the 'My private data only' check box to query private data only.">My private data only</label>
                                                </div>
                                            </xsl:if>
                                            <div class="option">
                                                <input id="ae-directsub" name="directsub" type="checkbox" title="By default all data from GEO and ArrayExpress are queried. Select the 'ArrayExpress data only' check box to query data submitted directly to ArrayExpress. If you want to query GEO data only include AND E-GEOD* in your query. E.g. cancer AND E-GEOD* will retrieve all GEO experiments with cancer annotations."/>
                                                <label for="ae-directsub" title="By default all data from GEO and ArrayExpress are queried. Select the 'ArrayExpress data only' check box to query data submitted directly to ArrayExpress. If you want to query GEO data only include AND E-GEOD* in your query. E.g. cancer AND E-GEOD* will retrieve all GEO experiments with cancer annotations.">ArrayExpress data only</label>
                                            </div>
                                            <div id="ae-submit-box"><input id="ae-query-submit" type="submit" value="Filter"/></div>
                                        </div>
                                    </fieldset>
                                </form>
                            </div>
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
                                    <col class="col_atlas"/>
                                    <thead>
                                        <xsl:call-template name="table-pager">
                                            <xsl:with-param name="pColumnsToSpan" select="9"/>
                                            <xsl:with-param name="pName" select="'experiment'"/>
                                            <xsl:with-param name="pTotal" select="$vTotal"/>
                                            <xsl:with-param name="pPage" select="$vPage"/>
                                            <xsl:with-param name="pPageSize" select="$vPageSize"/>
                                        </xsl:call-template>
                                        <tr>
                                            <th class="col_accession sortable">
                                                <xsl:text>Accession</xsl:text>
                                                <xsl:call-template name="table-sort">
                                                    <xsl:with-param name="pKind" select="'accession'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_name sortable">
                                                <xsl:text>Title</xsl:text>
                                                <xsl:call-template name="table-sort">
                                                    <xsl:with-param name="pKind" select="'name'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_type sortable">
                                                <xsl:text>Type</xsl:text>
                                                <xsl:call-template name="table-sort">
                                                    <xsl:with-param name="pKind" select="'type'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_organism sortable">
                                                <xsl:text>Organism</xsl:text>
                                                <xsl:call-template name="table-sort">
                                                    <xsl:with-param name="pKind" select="'organism'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_assays sortable">
                                                <xsl:text>Assays</xsl:text>
                                                <xsl:call-template name="table-sort">
                                                    <xsl:with-param name="pKind" select="'assays'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_releasedate sortable">
                                                <xsl:text>Released</xsl:text>
                                                <xsl:call-template name="table-sort">
                                                    <xsl:with-param name="pKind" select="'releasedate'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_processed sortable">
                                                <xsl:text>Processed</xsl:text>
                                                <xsl:call-template name="table-sort">
                                                    <xsl:with-param name="pKind" select="'processed'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_raw sortable">
                                                <xsl:text>Raw</xsl:text>
                                                <xsl:call-template name="table-sort">
                                                    <xsl:with-param name="pKind" select="'raw'"/>
                                                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                                </xsl:call-template>
                                            </th>
                                            <th class="col_atlas sortable">
                                                <xsl:text>Atlas</xsl:text>
                                                <xsl:call-template name="table-sort">
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
                                    <col class="col_atlas"/>
                                    <tbody>
                                        <xsl:call-template name="ae-sort-experiments">
                                            <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                                            <xsl:with-param name="pFrom" select="$vFrom"/>
                                            <xsl:with-param name="pTo" select="$vTo"/>
                                            <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                            <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                        </xsl:call-template>
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

        <xsl:variable name="vQueryString" select="if ($query-string) then fn:concat('?', $query-string) else ''"/>

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
                            <xsl:with-param name="pText" select="name[1]"/>
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
                            <xsl:with-param name="pFiles" select="$vFiles"/>
                            <xsl:with-param name="pKind" select="'processed'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_raw">
                    <div>
                        <xsl:call-template name="data-files-main">
                            <xsl:with-param name="pAccession" select="$vAccession"/>
                            <xsl:with-param name="pFiles" select="$vFiles"/>
                            <xsl:with-param name="pKind" select="'raw'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_atlas">
                    <div>
                        <xsl:choose>
                            <xsl:when test="@loadedinatlas">
                                <a href="${interface.application.link.atlas.exp_query.url}{accession}">
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
        <xsl:param name="pFiles"/>
        <xsl:param name="pKind"/>

        <xsl:variable name="vFiles" select="$pFiles/file[@kind = $pKind]"/>
        <xsl:choose>
            <xsl:when test="fn:count($vFiles) > 1">
                <a href="{$context-path}/experiments/{$pAccession}/files/{$pKind}/">
                    <span class="icon icon-generic" data-icon="L"/>
                </a>
            </xsl:when>
            <xsl:when test="fn:count($vFiles) = 1">
                <a href="{$context-path}/files/{$pAccession}/{$vFiles[1]/@name}">
                    <span class="icon icon-functional" data-icon="="/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="fn:not($pKind = 'raw' and fn:exists(seqdatauri))"><xsl:text>-</xsl:text></xsl:if>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="fn:exists($vFiles) and $pKind = 'raw' and fn:exists(seqdatauri)">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$pKind = 'raw' and fn:contains(seqdatauri[1], '/ega/')">
                <a href="{seqdatauri[1]}" title="Click to go to EGA study"><img src="{$context-path}/assets/images/data_link_ega.gif" width="16" height="16" alt="EGA"/></a>
            </xsl:when>
            <xsl:when test="$pKind = 'raw' and fn:contains(seqdatauri[1], '/ena/')">
                <a href="{seqdatauri[1]}" title="Click to go to ENA"><img src="{$context-path}/assets/images/data_link_ena.gif" width="16" height="16" alt="ENA"/></a>
            </xsl:when>
            <xsl:when test="$pKind = 'raw' and fn:exists(seqdatauri)">
                <a href="{seqdatauri[1]}">
                    <span class="icon icon-generic" data-icon="L"/>
                </a>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="browse-no-results">
        <h2 id="noresults">No ArrayExpress results found</h2>
        <p class="alert">We're sorry but we couldn't find anything that matched your search for "<xsl:value-of select="$keywords"/>"</p>

        <section class="grid_16 alpha">
            <!-- TODO:
            <h3>Did you mean...</h3>
            <ul>
                <li>Suggestion 1</li>
                <li>Suggestion 2</li>
                <li>Suggestion 3</li>
            </ul>
            -->
            <p>&#160;</p>
            <xsl:if test="$vSearchMode">
                <h3>Try Experiments Browser</h3>
                <p>You can browse available experiments and create a more complex query using our <a href="{$context-path}/experiments/browse.html" title="Click to go to Experiments Browser">Experiments Browser</a>.</p>
            </xsl:if>
            <!-- TODO:
            <h4>Still can't find what you're looking for?</h4>
            <p>Please <a href="#" title="">contact our support service</a> for help if you still get no results.</p>
            -->
        </section>

        <aside class="grid_8 omega shortcuts" id="search-extras">
            <div id="ebi_search_results"><h3>More data from EMBL-EBI</h3></div>
        </aside>
    </xsl:template>
</xsl:stylesheet>
