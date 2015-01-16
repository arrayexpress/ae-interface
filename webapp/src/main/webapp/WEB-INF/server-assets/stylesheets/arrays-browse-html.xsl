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
                extension-element-prefixes="xs fn ae search html"
                exclude-result-prefixes="xs fn ae search html"
                version="2.0">

    <xsl:param name="page"/>
    <xsl:param name="pagesize"/>

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>

    <xsl:param name="queryid"/>
    <xsl:param name="keywords"/>
    <xsl:param name="directsub"/>
    <xsl:param name="accession"/>
    <xsl:param name="experiment"/>
    <xsl:param name="ref"/>

    <xsl:variable name="vBrowseMode" select="fn:not($accession)"/>
    <xsl:variable name="vAccession" select="fn:upper-case($accession)"/>
    <xsl:variable name="vRef" select="fn:upper-case($ref)"/>
    <xsl:variable name="vExperimentMode" select="fn:starts-with($relative-uri, '/experiments/') or fn:starts-with($vRef, 'E')"/>
    <xsl:variable name="vExperiment" select="if ($ref) then $vRef else fn:upper-case($experiment)"/>
    <xsl:variable name="vReference" select="if ($vExperimentMode) then $vExperiment else if (fn:not($vBrowseMode)) then $vAccession else ''"/>
    <xsl:variable name="vQueryString" as="xs:string" select="if ($vExperimentMode) then fn:concat('?ref=', $vReference) else (if ($query-string) then fn:concat('?', $query-string) else '')"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-experiments-templates.xsl"/>
    <xsl:include href="ae-sort-arrays.xsl"/>

    <xsl:template match="/">
        <xsl:call-template name="ae-page">
            <xsl:with-param name="pIsSearchVisible" select="fn:not($vBrowseMode)"/>
            <xsl:with-param name="pSearchInputValue"/>
            <xsl:with-param name="pExtraSearchFields"/>
            <xsl:with-param name="pTitleTrail">
                <xsl:if test="fn:not($vBrowseMode)">
                    <xsl:value-of select="$vAccession"/>
                    <xsl:text> &lt; </xsl:text>
                </xsl:if>
                <xsl:text>Arrays</xsl:text>
                <xsl:if test="$vExperimentMode">
                    <xsl:text> &lt; </xsl:text>
                    <xsl:value-of select="$vExperiment"/>
                    <xsl:text> &lt; Experiments</xsl:text>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="pExtraCSS">
                <link rel="stylesheet" href="{$context-path}/assets/stylesheets/ae-arrays-browse-1.0.130313.css" type="text/css"/>
            </xsl:with-param>
            <xsl:with-param name="pBreadcrumbTrail">
                <xsl:choose>
                    <xsl:when test="$vExperimentMode">
                        <a href="{$context-path}/experiments/browse.html">Experiments</a>
                        <xsl:text> > </xsl:text>
                        <a href="{$context-path}/experiments/{$vExperiment}/">
                            <xsl:value-of select="$vExperiment"/>
                        </a>
                        <xsl:text> > </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$vBrowseMode">Arrays</xsl:when>
                            <xsl:otherwise>
                                <a href="{$context-path}/experiments/{$vExperiment}/arrays/">Arrays</a>
                                <xsl:text> > </xsl:text>
                                <xsl:value-of select="fn:upper-case($accession)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                           <xsl:when test="$vBrowseMode">Arrays</xsl:when>
                            <xsl:otherwise>
                                <a href="{$context-path}/arrays/browse.html?directsub=on">Arrays</a>
                                <xsl:text> > </xsl:text>
                                <xsl:value-of select="upper-case($accession)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="pEBISearchWidget"/>
            <xsl:with-param name="pExtraJS">
                <script src="{$context-path}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                <script src="{$context-path}/assets/scripts/jquery.ae-arrays-browse-1.0.0.js" type="text/javascript"/>
            </xsl:with-param>
            <xsl:with-param name="pExtraBodyClasses"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="ae-content-section">
        <section>
            <div id="ae-content">
                <xsl:choose>
                    <xsl:when test="not($vBrowseMode)">
                        <xsl:variable name="vArray" select="search:queryIndex($queryid)[accession = $vAccession]"/>
                        <xsl:choose>
                            <xsl:when test="exists($vArray)">
                                <xsl:call-template name="block-array">
                                    <xsl:with-param name="pArray" select="$vArray"/>
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
        <xsl:variable name="vFilteredArrays" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredArrays)"/>

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

        <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'accession'"/>
        <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'ascending'"/>
        <xsl:if test="fn:not($vExperimentMode)">
            <div id="ae-query">
                <form method="get" action="{$context-path}/arrays/browse.html">
                    <fieldset>
                        <label for="ae-keywords-field">Search arrays by accessions, names, descriptions, or providers</label>
                        <input id="ae-keywords-field" type="text" name="keywords" value="{$keywords}" maxlength="255"/>
                        <div class="option">
                            <input id="ae-directsub-field" name="directsub" type="checkbox" title="Select the 'ArrayExpress data only' check box to query for platform designs submitted directly to ArrayExpress. If you want to query GEO data only include AND A-GEOD* in your query.">
                                <xsl:if test="$directsub = 'on'">
                                    <xsl:attribute name="checked"/>
                                </xsl:if>
                            </input>
                            <label for="ae-directsub-field" title="Select the 'ArrayExpress data only' check box to query for platform designs submitted directly to ArrayExpress. If you want to query GEO data only include AND A-GEOD* in your query">ArrayExpress data only</label>
                        </div>
                        <div><input class="submit" type="submit" value="Search"/></div>
                    </fieldset>
                </form>
            </div>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$vTotal&gt;0">
                <div id="ae-browse" class="persist-area">
                    <table class="persist-header" border="0" cellpadding="0" cellspacing="0">
                        <col class="col_accession"/>
                        <col class="col_name"/>
                        <col class="col_organism"/>
                        <col class="col_files"/>
                        <thead>
                            <tr>
                                <xsl:call-template name="table-pager">
                                    <xsl:with-param name="pColumnsToSpan" select="4"/>
                                    <xsl:with-param name="pName" select="'array'"/>
                                    <xsl:with-param name="pTotal" select="$vTotal"/>
                                    <xsl:with-param name="pPage" select="$vPage"/>
                                    <xsl:with-param name="pPageSize" select="$vPageSize"/>
                                </xsl:call-template>
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
                                <th class="col_organism sortable">
                                    <xsl:text>Organism</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'organism'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_files">
                                    <xsl:text>Files</xsl:text>
                                </th>
                            </tr>
                        </thead>
                    </table>
                    <table border="0" cellpadding="0" cellspacing="0">
                        <col class="col_accession"/>
                        <col class="col_name"/>
                        <col class="col_organism"/>
                        <col class="col_files"/>
                        <tbody>
                            <xsl:call-template name="ae-sort-arrays">
                                <xsl:with-param name="pArrays" select="$vFilteredArrays"/>
                                <xsl:with-param name="pFrom" select="$vFrom"/>
                                <xsl:with-param name="pTo" select="$vTo"/>
                                <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                            </xsl:call-template>
                            <tr>
                                <td colspan="4" class="col_footer">&#160;</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div id="ae-infotext">
                    <span class="alert">There are no array designs matching your search criteria found in ArrayExpress.</span>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="array_design">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <xsl:variable name="vArrFolder" select="ae:getMappedValue('ftp-folder', accession)"/>
            <tr>
                <td class="col_accession">
                    <div>
                        <a href="{$context-path}/arrays/{accession}/{$vQueryString}">
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
                            <xsl:with-param name="pText" select="name"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_organism">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="string-join(organism, ', ')"/>
                            <xsl:with-param name="pFieldName" select="'organism'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_files">
                    <div>
                        <xsl:choose>
                            <xsl:when test="count($vArrFolder/file) > 0">
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="fn:concat($context-path, '/files/', accession, '/')"/>
                                        <xsl:text>?ref=</xsl:text>
                                        <xsl:choose>
                                            <xsl:when test="$vExperimentMode">
                                                <xsl:value-of select="$vExperiment"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="accession"/>
                                            </xsl:otherwise>
                                        </xsl:choose>

                                    </xsl:attribute>
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

    <xsl:template name="block-array">
        <xsl:param name="pArray"/>

        <xsl:variable name="vFiles" select="ae:getMappedValue('ftp-folder', $vAccession)"/>
        <xsl:variable name="vExpsWithArray" select="search:queryIndex('experiments', concat('visible:true array:', $vAccession, if ($userid) then concat(' userid:(', $userid, ')') else ''))"/>

        <h4>
            <xsl:if test="not($pArray/user/@id = '1')">
                <xsl:attribute name="class" select="'icon icon-functional'"/>
                <xsl:attribute name="data-icon" select="'L'"/>
            </xsl:if>
            <xsl:value-of select="$vAccession"/>
            <xsl:text> - </xsl:text>
            <xsl:value-of select="$pArray/name"/>
        </h4>
        <div id="ae-detail">
            <table border="0" cellpadding="0" cellspacing="0">
                <tbody>
                    <xsl:call-template name="detail-row">
                        <xsl:with-param name="pName" select="'Organism'"/>
                        <xsl:with-param name="pQueryId" select="$queryid"/>
                        <xsl:with-param name="pFieldName" select="'organism'"/>
                        <xsl:with-param name="pNode" select="$pArray/organism"/>
                    </xsl:call-template>
                    <xsl:call-template name="detail-row">
                        <xsl:with-param name="pName" select="'Description'"/>
                        <xsl:with-param name="pQueryId" select="$queryid"/>
                        <xsl:with-param name="pFieldName"/>
                        <xsl:with-param name="pNode" select="$pArray/description"/>
                    </xsl:call-template>
                    <xsl:call-template name="detail-row">
                        <xsl:with-param name="pName" select="'Version'"/>
                        <xsl:with-param name="pQueryId" select="$queryid"/>
                        <xsl:with-param name="pFieldName"/>
                        <xsl:with-param name="pNode" select="$pArray/version"/>
                    </xsl:call-template>
                    <xsl:call-template name="detail-row">
                        <xsl:with-param name="pName" select="'Provider'"/>
                        <xsl:with-param name="pQueryId" select="$queryid"/>
                        <xsl:with-param name="pFieldName" select="'provider'"/>
                        <xsl:with-param name="pNode" select="$pArray/provider"/>
                    </xsl:call-template>
                    <xsl:call-template name="detail-section">
                        <xsl:with-param name="pName" select="'Links'"/>
                        <xsl:with-param name="pContent">
                            <xsl:choose>
                                <xsl:when test="count($vExpsWithArray) > 10">
                                   <a href="{$context-path}/experiments/browse.html?array={$vAccession}">All <xsl:value-of select="count($vExpsWithArray)"/> experiments done using <xsl:value-of select="$vAccession"/></a>
                                </xsl:when>
                                <xsl:when test="count($vExpsWithArray) > 1">
                                    <a href="{$context-path}/experiments/browse.html?array={$vAccession}">All experiments done using <xsl:value-of select="$vAccession"/></a>
                                    <xsl:text>: (</xsl:text>
                                        <xsl:for-each select="$vExpsWithArray">
                                            <xsl:sort select="accession"/>
                                            <a href="{$context-path}/experiments/{accession}/">
                                                <xsl:value-of select="accession"/>
                                            </a>
                                            <xsl:if test="fn:position() != fn:last()"><xsl:text>, </xsl:text></xsl:if>
                                        </xsl:for-each>
                                    <xsl:text>)</xsl:text>
                                </xsl:when>
                                <xsl:when test="count($vExpsWithArray) = 1">
                                    <a href="{$context-path}/experiments/{$vExpsWithArray/accession}/">
                                        <xsl:text>Experiment </xsl:text><xsl:value-of select="$vExpsWithArray/accession"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise/>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:if test="fn:count($vFiles/file) > 0">
                        <xsl:call-template name="detail-section">
                            <xsl:with-param name="pName" select="'Files'"/>
                            <xsl:with-param name="pContent">
                                <xsl:variable name="vADFile" select="$vFiles/file[@kind = 'adf' and @extension = 'txt']"/>
                                <xsl:if test="fn:count($vADFile) > 0">
                                    <div>
                                        <table cellspacing="0" cellpadding="0" border="0">
                                            <tbody>
                                                <tr>
                                                    <td class="name">Array Design</td>
                                                    <td class="value">
                                                        <xsl:for-each select="$vADFile">
                                                            <xsl:sort select="fn:lower-case(@name)"/>
                                                            <a href="{$context-path}/files/{$vAccession}/{@name}" title="Click to download {@name}" class="icon icon-functional" data-icon="=">
                                                                <xsl:value-of select="@name"/>
                                                            </a>
                                                            <xsl:if test="fn:position() != fn:last()">
                                                                <xsl:text>, </xsl:text>
                                                            </xsl:if>
                                                        </xsl:for-each>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </xsl:if>
                                <div>
                                    <a class="icon icon-awesome" data-icon="&#xf07b;" href="{$context-path}/files/{$vAccession}/?ref={$vReference}">
                                        <xsl:text>Browse all available files</xsl:text>
                                    </a>
                                </div>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                </tbody>
            </table>
        </div>
    </xsl:template>

</xsl:stylesheet>
