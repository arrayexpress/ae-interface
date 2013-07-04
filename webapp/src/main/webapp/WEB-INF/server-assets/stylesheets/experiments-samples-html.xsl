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
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae search"
                exclude-result-prefixes="ae search html fn xs"
                version="2.0">

    <xsl:param name="queryid"/>
    <xsl:param name="accession"/>
    <xsl:param name="sourcename"/>

    <xsl:param name="grouping"/>
    <xsl:param name="full"/>

    <!-- TODO: fix grouping when we're ready -->
    <xsl:variable name="vGrouping" as="xs:boolean" select="false()"/>
    <xsl:variable name="vFull" as="xs:boolean" select="not(not($full))"/>

    <xsl:param name="s_page"/>
    <xsl:param name="s_pagesize"/>
    <xsl:param name="s_sortby"/>
    <xsl:param name="s_sortorder"/>

    <xsl:variable name="vSortBy" select="if ($s_sortby) then fn:replace($s_sortby, 'col_(\d+)', '$1') cast as xs:integer else 1" as="xs:integer"/>
    <xsl:variable name="vSortOrder" select="if (fn:starts-with($s_sortorder, 'd')) then 'd' else 'a'" as="xs:string"/>

    <xsl:variable name="vPage" select="if ($s_page) then $s_page cast as xs:integer else 1"/>
    <xsl:variable name="vPageSize" select="if ($s_pagesize) then $s_pagesize cast as xs:integer else 25"/>

    <xsl:variable name="vPermittedColType" select="('sourcename','sample_description','sample_source_name','characteristics','factorvalue','unit','links')"/>
    <xsl:variable name="vLinksColName" select="('arraydatafile','derivedarraydatafile','arraydatamatrixfile','derivedarraydatamatrixfile','ena_run','fastq_uri')"/>

    <xsl:variable name="vAccession" select="fn:upper-case($accession)"/>
    <xsl:variable name="vData" select="search:queryIndex('files', fn:concat('accession:', $vAccession))"/>
    <xsl:variable name="vSampleFiles" select="$vData[@kind = 'sdrf' and @extension = 'txt']"/>
    <xsl:variable name="vMetaData" select="search:queryIndex('experiments', fn:concat('visible:true accession:', $vAccession, if ($userid) then fn:concat(' userid:(', $userid, ')') else ''))[accession = $vAccession]" />

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>

    <xsl:template match="/">
        <xsl:call-template name="ae-page">
            <xsl:with-param name="pIsSearchVisible" select="fn:true()"/>
            <xsl:with-param name="pSearchInputValue"/>
            <xsl:with-param name="pTitleTrail">
                <xsl:text>Samples and Data &lt; </xsl:text>
                <xsl:value-of select="$vAccession"/>
                <xsl:text> &lt; Experiments</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="pExtraCSS">
                <link rel="stylesheet" href="{$context-path}/assets/stylesheets/ae-experiment-samples-1.0.130704.css" type="text/css"/>
            </xsl:with-param>
            <xsl:with-param name="pBreadcrumbTrail">
                <a href="{$context-path}/experiments/browse.html">Experiments</a>
                <xsl:text> > </xsl:text>
                <a href="{$context-path}/experiments/{$vAccession}/">
                    <xsl:value-of select="$vAccession"/>
                </a>
                <xsl:text> > Samples and Data</xsl:text>
                <xsl:if test="not($vFull)">
                    <sup><a href="{$context-path}/experiments/{$vAccession}/samples/?full=true" title="Some columns were omitted; please click here to get a full view of samples and data">*</a></sup>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="pExtraJS">
                <script src="{$context-path}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                <script src="{$context-path}/assets/scripts/jquery.ae-samples-view-1.0.130402.js" type="text/javascript"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="ae-content-section">
        <section>
            <div id="ae-content">
                <xsl:choose>
                    <xsl:when test="fn:exists($vSampleFiles) and fn:exists($vMetaData)">
                        <h4>
                            <xsl:if test="not($vMetaData/user/@id = '1')">
                                <xsl:attribute name="class" select="'icon icon-functional'"/>
                                <xsl:attribute name="data-icon" select="'L'"/>
                            </xsl:if>
                            <xsl:value-of select="$vMetaData/accession"/>
                            <xsl:text> - </xsl:text>
                            <xsl:value-of select="fn:string-join($vMetaData/name, ', ')"/>
                        </h4>
                        <div id="ae-results">
                            <xsl:for-each select="$vSampleFiles">
                                <xsl:variable name="vTable" select="ae:tabularDocument($vAccession, @name, fn:concat('--header=1;--page=', $vPage, ';--pagesize=', $vPageSize, ';--sortby=', $vSortBy, ';--sortorder=', $vSortOrder))/table"/>
                                <xsl:choose>
                                    <xsl:when test="fn:not(fn:exists($vTable))">
                                        <xsl:if test="fn:count($vSampleFiles) = 1">
                                            <xsl:value-of select="ae:httpStatus(404)"/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="$vTable">
                                            <xsl:with-param name="pFileName" select="@name"/>
                                        </xsl:apply-templates>
                                        <xsl:if test="fn:position() != fn:last()">
                                            <div class="divider"/>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </div>
                    </xsl:when>
                    <xsl:when test="fn:exists($vSampleFiles) and fn:not(fn:exists($vMetaData))">
                        <xsl:value-of select="ae:httpStatus(403)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ae:httpStatus(404)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </section>
    </xsl:template>

    <xsl:template name="add-header-col-info">
        <xsl:param name="pPos"/>
        <xsl:param name="pText"/>

        <xsl:variable name="vIsColComplex" select="fn:not($vFull) and fn:matches($pText, '.+\[.+\].*')"/>
        <xsl:variable name="vIsColComment" select="fn:matches(fn:lower-case($pText), 'comment\s*\[.+\].*')"/>
        <xsl:variable name="vColName" as="xs:string" select="if ($vIsColComplex) then fn:replace($pText, '.+\[(.+)\].*', '$1') else $pText"/>
        <xsl:variable name="vColType" as="xs:string">
            <xsl:choose>
                <xsl:when test="fn:exists(fn:index-of($vLinksColName, fn:lower-case(fn:replace($vColName, '\s+', ''))))">
                    <xsl:text>Links</xsl:text>
                </xsl:when>
                <xsl:when test="$vIsColComplex and $vIsColComment">
                    <xsl:value-of select="$vColName"/>
                </xsl:when>
                <xsl:when test="$vIsColComplex and fn:not($vIsColComment)">
                    <xsl:value-of select="fn:replace($pText, '(.+[^\s])\s*\[.+\].*', '$1')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$pText"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vAdjustedColType" select="fn:lower-case(fn:replace($vColType, '\s+', ''))"/>
        <xsl:variable name="vColPosition" select="if ($vFull) then $pPos else fn:index-of($vPermittedColType, $vAdjustedColType)"/>
        <xsl:variable name="vColClass" select="if ($vAdjustedColType = 'characteristics') then 'sa' else (if (fn:matches($vAdjustedColType, 'factorvalue')) then 'ef' else '')"/>

        <col pos="{$pPos}" type="{$vAdjustedColType}" name="{$vColName}" group="{$vColPosition}" class="{$vColClass}"/>
    </xsl:template>

    <xsl:template match="table">
        <xsl:param name="pFileName"/>

        <xsl:variable name="vTableInfo">
            <xsl:variable name="vHeaderRow" select="header"/>

            <xsl:variable name="vHeaderInfo">
                <xsl:for-each select="$vHeaderRow/col[fn:matches(text(), '[^\s]')]">
                    <xsl:call-template name="add-header-col-info">
                        <xsl:with-param name="pPos" select="position()"/>
                        <xsl:with-param name="pText" select="text()"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="vUnitFixedHeaderInfo">
                <xsl:for-each select="$vHeaderInfo/col">
                    <xsl:variable name="vHasUnit" as="xs:boolean" select="fn:not($vFull) and following-sibling::*[1]/@type = 'unit'"/>
                    <xsl:variable name="vIsUnit" as="xs:boolean" select="fn:not($vFull) and @type = 'unit'"/>

                    <xsl:if test="fn:not($vIsUnit)">
                        <col pos="{@pos}" type="{@type}" name="{@name}" group="{@group}" class="{@class}">
                            <xsl:if test="$vHasUnit">
                                <xsl:attribute name="unit" select="following-sibling::*[1]/@pos"/>
                            </xsl:if>
                        </col>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <header data-rows="{@rows}">
                <xsl:for-each select="$vUnitFixedHeaderInfo/col[@group != '']">
                    <xsl:sort select="@group" order="ascending" data-type="number"/>
                    <xsl:sort select="@pos" order="ascending" data-type="number"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </header>
        </xsl:variable>

        <div class="ae_samples_table_border">
            <table class="ae_samples_table" border="0" cellpadding="0" cellspacing="0" style="visibility:hidden">
                <col class="col_left_fixed" style=""/>
                <col class="col_middle_scrollable" style="width:100%"/>
                <col class="col_right_fixed" style=""/>
                <thead>
                    <xsl:call-template name="table-pager">
                        <xsl:with-param name="pColumnsToSpan" select="3"/>
                        <xsl:with-param name="pName" select="'row'"/>
                        <xsl:with-param name="pTotal" select="@rows"/>
                        <xsl:with-param name="pPage" select="$vPage"/>
                        <xsl:with-param name="pPageSize" select="$vPageSize"/>
                        <xsl:with-param name="pParamPrefix" select="'s_'"/>
                    </xsl:call-template>
                </thead>
                <tbody>
                    <tr>
                        <td class="left_fixed">
                            <xsl:call-template name="out-source-name-table">
                                <xsl:with-param name="pTableInfo" select="$vTableInfo"/>
                                <xsl:with-param name="pRows" select="row"/>
                            </xsl:call-template>
                        </td>
                        <td class="middle_scrollable" rowspan="2">
                            <xsl:call-template name="out-attributes-table">
                                <xsl:with-param name="pTableInfo" select="$vTableInfo"/>
                                <xsl:with-param name="pRows" select="row"/>
                            </xsl:call-template>
                        </td>
                        <td class="right_fixed">
                            <xsl:call-template name="out-links-table">
                                <xsl:with-param name="pTableInfo" select="$vTableInfo"/>
                                <xsl:with-param name="pRows" select="row"/>
                            </xsl:call-template>
                        </td>
                    </tr>
                    <tr>
                        <td class="bottom_filler"/>
                        <td class="bottom_filler"/>
                    </tr>
                    <tr>
                        <td colspan="3" class="col_footer"><a href="{$context-path}/files/{$vAccession}/{$pFileName}" class="icon icon-functional" data-icon="S">Download Samples and Data table in Tab-delimited format</a></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </xsl:template>

    <xsl:template name="out-source-name-table">
        <xsl:param name="pTableInfo"/>
        <xsl:param name="pRows"/>

        <xsl:variable name="vTableChunkInfo">
            <header data-rows="{$pTableInfo/header/@data-rows}">
                <xsl:copy-of select="$pTableInfo/header/col[1]"/>
            </header>
        </xsl:variable>

        <table class="src_name_table" border="0" cellpadding="0" cellspacing="0">
            <xsl:call-template name="out-header">
                <xsl:with-param name="pTableInfo" select="$vTableChunkInfo"/>
            </xsl:call-template>
            <xsl:call-template name="out-data">
                <xsl:with-param name="pTableInfo" select="$vTableChunkInfo"/>
                <xsl:with-param name="pRows" select="$pRows"/>
            </xsl:call-template>
        </table>
    </xsl:template>

    <xsl:template name="out-attributes-table">
        <xsl:param name="pTableInfo"/>
        <xsl:param name="pRows"/>

        <xsl:variable name="vTableChunkInfo">
            <header data-rows="{$pTableInfo/header/@data-rows}">
                <xsl:copy-of select="$pTableInfo/header/col[@pos &gt; 1 and @type != 'links']"/>
            </header>
        </xsl:variable>
        <div class="attr_table_shadow_container">
           <div class="attr_table_scroll">
                <table class="attr_table" border="0" cellpadding="0" cellspacing="0">
                    <xsl:call-template name="out-header">
                        <xsl:with-param name="pTableInfo" select="$vTableChunkInfo"/>
                    </xsl:call-template>
                    <xsl:call-template name="out-data">
                        <xsl:with-param name="pTableInfo" select="$vTableChunkInfo"/>
                        <xsl:with-param name="pRows" select="$pRows"/>
                    </xsl:call-template>
                </table>
            </div>
            <div class="left_shadow" style="display:none"/>
            <div class="right_shadow" style="display:none"/>
        </div>

    </xsl:template>

    <xsl:template name="out-links-table">
        <xsl:param name="pTableInfo"/>
        <xsl:param name="pRows"/>

        <xsl:variable name="vTableChunkInfo">
            <header data-rows="{$pTableInfo/header/@data-rows}">
                <xsl:copy-of select="$pTableInfo/header/col[@type='links']"/>
            </header>
        </xsl:variable>

        <table class="links_table" border="0" cellpadding="0" cellspacing="0">
            <xsl:call-template name="out-header">
                <xsl:with-param name="pTableInfo" select="$vTableChunkInfo"/>
            </xsl:call-template>
            <xsl:call-template name="out-data">
                <xsl:with-param name="pTableInfo" select="$vTableChunkInfo"/>
                <xsl:with-param name="pRows" select="$pRows"/>
            </xsl:call-template>
        </table>
    </xsl:template>

    <xsl:template name="out-header">
        <xsl:param name="pTableInfo"/>

        <thead>
            <xsl:if test="not($vFull)">
                <tr>
                    <xsl:for-each select="$pTableInfo/header/col">
                        <xsl:variable name="vColInfo" select="."/>
                        <xsl:variable name="vColPos" select="position()"/>
                        <xsl:variable name="vColType" select="$vColInfo/@type"/>
                        <xsl:variable name="vColClass" select="$vColInfo/@class"/>
                        <xsl:variable name="vPrevColType" select="preceding-sibling::*[1]/@type"/>
                        <xsl:variable name="vNextCols" select="following-sibling::*"/>
                        <xsl:variable name="vNextColType" select="$vNextCols[1]/@type"/>
                        <xsl:variable name="vNextGroupCol" select="$vNextCols[@type != $vColType][1]"/>
                        <xsl:variable name="vNextGroupColPos" select="if ($vNextGroupCol) then count($vNextGroupCol/preceding-sibling::*) + 1 else (count($pTableInfo/header/col) + 1)"/>
                        <xsl:if test="not($vPrevColType = $vColType)">
                            <th>
                                <xsl:attribute name="class">
                                    <xsl:text>even</xsl:text>
                                    <xsl:if test="$vColPos = 1">
                                        <xsl:text> col_1</xsl:text>
                                    </xsl:if>
                                    <xsl:if test="$vColClass != ''">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="$vColClass"/>
                                    </xsl:if>
                                </xsl:attribute>
                                <xsl:if test="($vColType = $vNextColType)">
                                    <xsl:attribute name="colspan" select="$vNextGroupColPos - $vColPos"/>
                                </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="$vColClass = 'sa'">
                                        <xsl:text>Sample Characteristics</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$vColClass = 'ef'">
                                        <xsl:text>Factor Values</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$vColInfo/@type = 'links'">
                                        <xsl:text>Links to Data</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>&#160;</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </th>
                        </xsl:if>
                    </xsl:for-each>
                </tr>
            </xsl:if>
            <tr>
                <xsl:for-each select="$pTableInfo/header/col">
                    <xsl:variable name="vColInfo" select="."/>
                    <th>
                        <xsl:attribute name="class">
                            <xsl:text>odd sortable col_</xsl:text>
                            <xsl:value-of select="$vColInfo/@pos"/>
                            <xsl:choose>
                                <xsl:when test="$vFull"> uni</xsl:when>
                                <xsl:when test="$vColInfo/@class != ''">
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$vColInfo/@class"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:if test="$vColInfo/@unit">
                                <xsl:text> right</xsl:text>
                            </xsl:if>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$vFull"><xsl:value-of select="$vColInfo/@name"/></xsl:when>
                            <xsl:when test="fn:lower-case($vColInfo/@name) = 'ena_run'">ENA</xsl:when>
                            <xsl:when test="fn:lower-case($vColInfo/@name) = 'fastq_uri'">FASTQ</xsl:when>
                            <xsl:when test="fn:lower-case($vColInfo/@name) = 'derived array data file'">Processed</xsl:when>
                            <xsl:when test="fn:lower-case($vColInfo/@name) = 'derived array data matrix file'">Processed Matrix</xsl:when>
                            <xsl:when test="fn:lower-case($vColInfo/@name) = 'array data file'">Raw</xsl:when>
                            <xsl:when test="fn:lower-case($vColInfo/@name) = 'array data matrix file'">Raw Matrix</xsl:when>
                            <xsl:when test="$vColInfo/@class != ''">
                                <xsl:call-template name="highlight">
                                    <xsl:with-param name="pQueryId" select="$queryid"/>
                                    <xsl:with-param name="pText" select="$vColInfo/@name"/>
                                    <xsl:with-param name="pFieldName" select="$vColInfo/@class"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$vColInfo/@name"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:call-template name="add-table-sort">
                            <xsl:with-param name="pKind" as="xs:integer" select="$vColInfo/@pos"/>
                            <xsl:with-param name="pSortBy" select="$vSortBy"/>
                            <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                        </xsl:call-template>
                    </th>
                </xsl:for-each>
            </tr>
        </thead>
    </xsl:template>

    <xsl:template name="out-data">
        <xsl:param name="pTableInfo"/>
        <xsl:param name="pRows"/>

        <tbody>
            <xsl:for-each select="$pRows">
                <xsl:variable name="vRowPos" select="fn:position()"/>
                <tr>
                    <xsl:variable name="vRow" select="."/>
                    <xsl:for-each select="$pTableInfo/header/col">
                        <xsl:variable name="vColPos" as="xs:integer" select="@pos"/>
                        <xsl:variable name="vColInfo" select="."/>
                        <xsl:variable name="vCol" select="$vRow/col[$vColPos]"/>
                        <xsl:variable name="vColText" select="$vCol/text()"/>
                        <xsl:variable name="vUnitText" select="if (@unit) then $vCol/following-sibling::*[1]/text() else ''"/>
                        <xsl:variable name="vPrevColText" select="$vRow/preceding-sibling::*[1]/col[$vColPos]/text()"/>
                        <xsl:variable name="vNextRows" select="$vRow/following-sibling::*"/>
                        <xsl:variable name="vNextColText" select="$vNextRows[1]/col[$vColPos]/text()"/>
                        <xsl:variable name="vNextGroupRow" select="$vNextRows[col[$vColPos]/text() != $vColText][1]"/>
                        <xsl:variable name="vNextGroupRowPos" select="if ($vNextGroupRow) then count($vNextGroupRow/preceding-sibling::*) + 1 else ($pTableInfo/header/@data-rows + 1)"/>

                        <xsl:if test="not($vPrevColText = $vColText) or not($vGrouping)">
                            <td>
                                <xsl:attribute name="class">
                                    <xsl:choose>
                                        <xsl:when test="$vRowPos mod 2 = 0">
                                            <xsl:text>even</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>odd</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text> col_</xsl:text><xsl:value-of select="$vColInfo/@pos"/>
                                    <xsl:choose>
                                        <xsl:when test="$vFull"> uni</xsl:when>
                                        <xsl:when test="$vColInfo/@class != ''">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="$vColInfo/@class"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:if test="$vColInfo/@unit">
                                        <xsl:text> right</xsl:text>
                                    </xsl:if>
                                    <xsl:if test="ae:isStringNotEmpty($sourcename) and $vRow/col[1] = $sourcename">
                                        <xsl:text> selected</xsl:text>
                                    </xsl:if>
                                </xsl:attribute>
                                <xsl:if test="$vColText = $vNextColText and $vGrouping">
                                    <xsl:attribute name="rowspan" select="$vNextGroupRowPos - $vRowPos"/>
                                </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="$vColInfo/@type = 'links'">
                                        <xsl:choose>
                                            <xsl:when test="fn:contains(fn:lower-case($vColInfo/@name), 'file')">
                                                <xsl:variable name="vDataKind" select="if (fn:contains(fn:lower-case($vColInfo/@name), 'derived')) then 'processed' else 'raw'"/>
                                                <xsl:variable name="vAvailArchives" select="$vData[@extension = 'zip' and @kind = $vDataKind]/@name"/>
                                                <xsl:variable name="vArchive" select="fn:replace($vCol/following-sibling::*[1]/text(), '^.+/([^/]+)$', '$1')"/>

                                                <xsl:choose>
                                                    <xsl:when test="ae:isStringNotEmpty($vColText) and fn:index-of($vAvailArchives, $vArchive)">
                                                        <a href="{$context-path}/files/{$vAccession}/{$vArchive}/{fn:encode-for-uri($vColText)}" title="Click to download {$vColText}">
                                                            <span class="icon icon-functional" data-icon="="/>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:when test="ae:isStringNotEmpty($vColText) and fn:count($vAvailArchives) = 1">
                                                        <a href="{$context-path}/files/{$vAccession}/{$vAvailArchives}/{fn:encode-for-uri($vColText)}" title="Click to download {$vColText}">
                                                            <span class="icon icon-functional" data-icon="="/>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:when test="ae:isStringNotEmpty($vColText) and $vColText = $vArchive">
                                                        <a href="{$context-path}/files/{$vAccession}/{fn:encode-for-uri($vColText)}" title="Click to download {$vColText}">
                                                            <span class="icon icon-functional" data-icon="="/>
                                                        </a>
                                                        <xsl:if test="fn:ends-with($vColText, '.bam')">
                                                            <xsl:call-template name="ensembl-link">
                                                                <xsl:with-param name="pBAMFile" select="$vColText"/>
                                                            </xsl:call-template>
                                                        </xsl:if>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="'-'"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:when test="fn:lower-case($vColInfo/@name) = 'ena_run' and ae:isStringNotEmpty($vColText)">
                                                <xsl:variable name="vBAMFile" select="fn:concat($vAccession, '.BAM.', $vColText, '.bam')"/>

                                                <a href="http://www.ebi.ac.uk/ena/data/view/{$vColText}" title="Click to go to ENA run summary">
                                                    <span class="icon icon-generic" data-icon="L"/>
                                                    <!-- <img src="{$context-path}/assets/images/data_link_ena.gif" width="23" height="16"/> -->
                                                </a>
                                                <xsl:call-template name="ensembl-link">
                                                    <xsl:with-param name="pBAMFile" select="$vBAMFile"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:when test="fn:lower-case($vColInfo/@name) = 'fastq_uri' and ae:isStringNotEmpty($vColText)">
                                                <xsl:variable name="vFileName" select="fn:replace($vColText, '^.+/([^/]+)$', '$1')"/>
                                                <a href="{$vColText}" title="Click to download {$vFileName}">
                                                    <span class="icon icon-functional" data-icon="="/>
                                                    <!-- <img src="{$context-path}/assets/images/ena_data_save.gif" width="16" height="16"/> -->
                                                </a>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'-'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>

                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when test="$vColInfo/@class != ''">
                                                <xsl:call-template name="highlight">
                                                    <xsl:with-param name="pQueryId" select="$queryid"/>
                                                    <xsl:with-param name="pText" select="$vColText"/>
                                                    <xsl:with-param name="pFieldName" select="if ($vColInfo/@class = 'ef') then 'efv' else ($vColInfo/@class)"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$vColText"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:if test="fn:exists(@unit) and ae:isStringNotEmpty($vUnitText)">
                                            <em>
                                                <xsl:text> (</xsl:text>
                                                <xsl:value-of select="$vUnitText"/>
                                                <xsl:text>)</xsl:text>
                                            </em>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </xsl:if>
                    </xsl:for-each>
                </tr>
            </xsl:for-each>
        </tbody>
    </xsl:template>

    <xsl:template name="ensembl-link">
        <xsl:param name="pBAMFile"/>

        <xsl:variable name="vAvailBAMs" select="$vData[@extension = 'bam']/@name"/>
        <xsl:variable name="vAvailBAMProps" select="$vData[@extension = 'prop']/@name"/>
        <xsl:variable name="vBAMPropFile" select="fn:concat($pBAMFile, '.prop')"/>


        <xsl:if test="fn:index-of($vAvailBAMs, $pBAMFile) and fn:index-of($vAvailBAMProps, $vBAMPropFile)">
            <xsl:variable name="vBAMProps" select="ae:tabularDocument($vAccession, $vBAMPropFile)/table/row[2]"/>
            <xsl:if test="fn:count($vBAMProps/col) = 3">
                <xsl:text> </xsl:text>
                <a href="http://www.ensembl.org/{fn:replace($vBAMProps/col[1], ' ', '_')}/Location/View?r={$vBAMProps/col[3]};contigviewbottom=url:{$host}{$context-path}/files/{$vAccession}/{$pBAMFile};format=Bam" title="Click to view {$pBAMFile} in Ensembl Genome Browser">
                    <img src="http://static.ensembl.org/i/search/ensembl.gif" width="16" height="16"/>
                </a>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:function name="ae:isStringNotEmpty" as="xs:boolean">
        <xsl:param name="pString"/>

        <xsl:value-of select="fn:exists($pString) and fn:not(fn:normalize-space($pString) = '')"/>
    </xsl:function>

</xsl:stylesheet>