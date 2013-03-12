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
                extension-element-prefixes="xs fn ae search html"
                exclude-result-prefixes="xs fn ae search html"
                version="2.0">

    <xsl:param name="page"/>
    <xsl:param name="pagesize"/>

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>

    <xsl:param name="queryid"/>
    <xsl:param name="keywords"/>
    <xsl:param name="id"/>
    <xsl:param name="experiment"/>
    <xsl:param name="ref"/>

    <xsl:variable name="vBrowseMode" select="not($id)"/>
    <xsl:variable name="vRef" select="fn:upper-case($ref)"/>
    <xsl:variable name="vExperimentMode" select="fn:starts-with($relative-uri, '/experiments/') or fn:starts-with($vRef, 'E')"/>
    <xsl:variable name="vExperiment" select="if ($ref) then $vRef else fn:upper-case($experiment)"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-sort-protocols.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>

    <xsl:template match="/">
        <xsl:call-template name="ae-page">
            <xsl:with-param name="pIsFixedWidth" select="fn:false()"/>
            <xsl:with-param name="pIsSearchVisible" select="fn:not($vBrowseMode)"/>
            <xsl:with-param name="pSearchInputValue"/>
            <xsl:with-param name="pTitleTrail">
                <xsl:if test="fn:not($vBrowseMode)">
                    <xsl:value-of select="$id"/>
                    <xsl:text> &lt; </xsl:text>
                </xsl:if>
                <xsl:text>Protocols</xsl:text>
                <xsl:if test="$vExperimentMode">
                    <xsl:text> &lt; </xsl:text>
                    <xsl:value-of select="$vExperiment"/>
                    <xsl:text> &lt; Experiments</xsl:text>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="pExtraCSS">
                <link rel="stylesheet" href="{$context-path}/assets/stylesheets/ae-protocols-browse-1.0.0.css" type="text/css"/>
            </xsl:with-param>
            <xsl:with-param name="pBreadcrumbTrail">
                <xsl:choose>
                    <xsl:when test="$vExperimentMode">
                        <a href="{$context-path}/experiments">Experiments</a>
                        <xsl:text> > </xsl:text>
                        <a href="{$context-path}/experiments/{$vExperiment}">
                            <xsl:value-of select="$vExperiment"/>
                        </a>
                        <xsl:text> > </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$vBrowseMode">Protocols</xsl:when>
                            <xsl:otherwise>
                                <a href="{$context-path}/experiments/{$vExperiment}/protocols.html">Protocols</a>
                                <xsl:text> > </xsl:text>
                                <xsl:value-of select="fn:upper-case($id)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$vBrowseMode">Protocols</xsl:when>
                            <xsl:otherwise>
                                <a href="{$context-path}/protocols">Protocols</a>
                                <xsl:text> > </xsl:text>
                                <xsl:value-of select="upper-case($id)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="pExtraJS">
                <script src="{$context-path}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                <script src="{$context-path}/assets/scripts/jquery.ae-protocols-browse-1.0.0.js" type="text/javascript"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="ae-content-section">
        <section>
            <div id="ae-content">
                <xsl:choose>
                    <xsl:when test="not($vBrowseMode)">
                        <xsl:variable name="vProtocol" select="search:queryIndex($queryid)[id = $id]"/>
                        <xsl:choose>
                            <xsl:when test="exists($vProtocol)">
                                <xsl:call-template name="block-protocol">
                                    <xsl:with-param name="pProtocol" select="$vProtocol"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="ae:httpStatus(404)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="block-browse"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </section>
    </xsl:template>
    <xsl:template name="block-browse">
        <xsl:variable name="vFilteredProtocols" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredProtocols)"/>

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

        <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'id'"/>
        <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'ascending'"/>

        <div id="ae-query">
            <form method="get" action="browse.html">
                <fieldset>
                    <label for="ae-query-keywords">Accessions, names, and description</label>
                    <input id="ae-query-keywords" type="text" name="keywords" value="{$keywords}" maxlength="255"/>
                    <div><input type="submit" value="Query"/></div>
                </fieldset>
            </form>
        </div>

        <xsl:choose>
            <xsl:when test="$vTotal&gt;0">
                <div id="ae-browse" class="persist-area">
                    <table class="persist-header" border="0" cellpadding="0" cellspacing="0">
                        <!--
                        <col class="col_id"/>
                        -->
                        <col class="col_accession"/>
                        <col class="col_name"/>
                        <col class="col_type"/>
                        <thead>
                            <xsl:call-template name="table-pager">
                                <xsl:with-param name="pColumnsToSpan" select="3"/>
                                <xsl:with-param name="pName" select="'protocol'"/>
                                <xsl:with-param name="pTotal" select="$vTotal"/>
                                <xsl:with-param name="pPage" select="$vPage"/>
                                <xsl:with-param name="pPageSize" select="$vPageSize"/>
                            </xsl:call-template>
                            <tr>
                                <!--
                                <th class="col_id sortable">
                                    <xsl:text>ID</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'id'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                                -->
                                <th class="col_accession sortable">
                                    <xsl:text>Accession</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'accession'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_name sortable">
                                    <xsl:text>Name</xsl:text>
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
                            </tr>
                        </thead>
                    </table>
                    <table border="0" cellpadding="0" cellspacing="0">
                        <xsl:attribute name="class">
                            <xsl:text>ae-results-table</xsl:text>
                            <xsl:choose>
                                <xsl:when test="$vExperimentMode"> experiment-mode</xsl:when>
                                <xsl:when test="$vBrowseMode"> browse-mode</xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                        <!--
                        <col class="col_id"/>
                        -->
                        <col class="col_accession"/>
                        <col class="col_name"/>
                        <col class="col_type"/>
                        <tbody>
                            <xsl:call-template name="ae-sort-protocols">
                                <xsl:with-param name="pProtocols" select="$vFilteredProtocols"/>
                                <xsl:with-param name="pFrom" select="$vFrom"/>
                                <xsl:with-param name="pTo" select="$vTo"/>
                                <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                            </xsl:call-template>
                        </tbody>
                    </table>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div id="ae-infotext">
                    <span class="alert">There are no protocols matching your search criteria found in ArrayExpress.</span>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="protocol">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <tr>
                <!--
                <td class="col_id">
                    <div>
                        <xsl:variable name="vIdText">
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pQueryId" select="$queryid"/>
                                <xsl:with-param name="pText" select="id"/>
                                <xsl:with-param name="pFieldName" select="'id'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$vExperimentMode">
                                <xsl:value-of select="$vIdText"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <a href="{$context-path}/protocols/{id}">
                                    <xsl:value-of select="$vIdText"/>
                                </a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </td>
                -->
                <td class="col_accession">
                    <div>
                        <xsl:variable name="vLabel">
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pQueryId" select="$queryid"/>
                                <xsl:with-param name="pText" select="accession"/>
                                <xsl:with-param name="pFieldName" select="'accession'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$vExperimentMode or fn:true()"> <!-- TODO: remove this when we implement protocol detail view -->
                                <xsl:value-of select="$vLabel"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <a href="{$context-path}/protocols/{id}">
                                    <xsl:value-of select="$vLabel"/>
                                </a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </td>
                <td class="col_name">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="name"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_type">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="type"/>
                            <xsl:with-param name="pFieldName" select="'type'"/>
                        </xsl:call-template>
                    </div>
                </td>
            </tr>
            <xsl:if test="$vExperimentMode">
            <tr>
                <td class="col_detail" colspan="3">
                    <xsl:for-each select="text">
                        <xsl:apply-templates select="." mode="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </td>
            </tr>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template name="block-protocol">
        <xsl:param name="pProtocol"/>
        <xsl:value-of select="ae:httpStatus(404)"/>
    </xsl:template>

    <xsl:template name="detail-table">
        <xsl:variable name="vExpsWithProtocol" select="search:queryIndex('experiments', concat('visible:true protocol:', id, if ($userid) then concat(' userid:(', $userid, ')') else ''))"/>

        <table border="0" cellpadding="0" cellspacing="0">
            <tbody>
                <xsl:if test="not($userid)">
                    <xsl:call-template name="detail-section">
                        <xsl:with-param name="pName" select="'Source'"/>
                        <xsl:with-param name="pContent"><div>AE2</div></xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Description'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue" select="text"/>
                </xsl:call-template>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="if (count(parameter) &gt; 1) then 'Parameters' else 'Parameter'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue"><xsl:value-of select="string-join(parameter, ', ')"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Hardware'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue" select="hardware"/>
                </xsl:call-template>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Software'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue" select="software"/>
                </xsl:call-template>
                <xsl:call-template name="detail-section">
                    <xsl:with-param name="pName" select="'Links'"/>
                    <xsl:with-param name="pContent">
                        <xsl:choose>
                            <xsl:when test="count($vExpsWithProtocol) > 10">
                               <a href="{$context-path}/browse.html?keywords=protocol:{id}">All <xsl:value-of select="count($vExpsWithProtocol)"/> experiments using protocol <xsl:value-of select="accession"/></a>
                            </xsl:when>
                            <xsl:when test="count($vExpsWithProtocol) > 1">
                                <a href="{$context-path}/browse.html?keywords=protocol:{id}">All experiments using protocol <xsl:value-of select="accession"/></a>
                                <xsl:text>: (</xsl:text>
                                    <xsl:for-each select="$vExpsWithProtocol">
                                        <xsl:sort select="accession"/>
                                        <a href="{$context-path}/experiments/{accession}">
                                            <xsl:value-of select="accession"/>
                                        </a>
                                        <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                    </xsl:for-each>
                                <xsl:text>)</xsl:text>
                            </xsl:when>
                            <xsl:when test="count($vExpsWithProtocol) = 1">
                                <a href="{$context-path}/experiments/{$vExpsWithProtocol/accession}">
                                    <xsl:text>Experiment </xsl:text><xsl:value-of select="$vExpsWithProtocol/accession"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template name="detail-row">
        <xsl:param name="pName"/>
        <xsl:param name="pFieldName"/>
        <xsl:param name="pValue"/>
        <xsl:if test="$pValue/node() and fn:string($pValue) != ''">
            <xsl:call-template name="detail-section">
                <xsl:with-param name="pName" select="$pName"/>
                <xsl:with-param name="pContent">
                    <xsl:for-each select="$pValue">
                        <xsl:apply-templates select="." mode="highlight">
                            <xsl:with-param name="pFieldName" select="$pFieldName"/>
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="detail-section">
        <xsl:param name="pName"/>
        <xsl:param name="pContent"/>
        <tr>
            <td class="name">
                <div>
                    <xsl:value-of select="$pName"/>
                </div>
            </td>
            <td class="value">
                <xsl:copy-of select="$pContent"/>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
