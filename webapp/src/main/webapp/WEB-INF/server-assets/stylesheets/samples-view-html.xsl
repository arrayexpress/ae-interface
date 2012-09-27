<?xml version="1.0" encoding="UTF-8"?>
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

    <xsl:param name="grouping"/>
    <xsl:param name="full"/>

    <!-- TODO: fix this when we're ready -->
    <xsl:variable name="vGrouping" as="xs:boolean" select="false()"/>
    <xsl:variable name="vFull" as="xs:boolean" select="not(not($full))"/>

    <xsl:param name="colsortby"/>
    <xsl:param name="colsortorder"/>

    <xsl:variable name="vSortBy" select="if ($colsortby) then fn:replace($colsortby, 'col_(\d+)', '$1') cast as xs:integer else 1" as="xs:integer"/>
    <xsl:variable name="vSortOrder" select="if ($colsortorder) then $colsortorder else 'ascending'"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>
    <xsl:param name="userid"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:variable name="vPermittedColType" select="fn:tokenize('source name,sample_description,sample_source_name,characteristics,factorvalue,factor value,unit,array data file,derived array data file,array data matrix file,derived array data matrix file,ena_run,links', '\s*,\s*')"/>
    <xsl:variable name="vLinksColName" select="fn:tokenize('array data file,derived array data file,array data matrix file,derived array data matrix file,ena_run', '\s*,\s*')"/>

    <xsl:variable name="vAccession" select="fn:upper-case($accession)"/>
    <xsl:variable name="vData" select="search:queryIndex('files', fn:concat('accession:', $vAccession))"/>
    <xsl:variable name="vSdrfFiles" select="$vData[@kind='sdrf']"/>
    <xsl:variable name="vMetaData" select="search:queryIndex('experiments', fn:concat('visible:true accession:', $vAccession, if ($userid) then fn:concat(' userid:(', $userid, ')') else ''))[accession = $vAccession]" />

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">Samples and Data |
                    <xsl:value-of select="$vAccession"/> | Experiments | ArrayExpress Archive | EBI
                </xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_samples_view_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_samples_view_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>

    </xsl:template>

    <xsl:template name="ae-contents">
        <xsl:choose>
            <xsl:when test="fn:exists($vSdrfFiles) and fn:exists($vMetaData)">
                <div id="ae_contents_box_100pc">
                    <div id="ae_content">
                        <div id="ae_navi">
                            <a href="${interface.application.link.www_domain}/">EBI</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}">ArrayExpress</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments">Experiments</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments/{$vAccession}">
                                <xsl:value-of select="$vAccession"/>
                            </a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments/{$vAccession}/samples.html">
                                <xsl:text>Samples and Data</xsl:text>
                            </a>
                            <xsl:if test="not($vFull)">
                                <sup><a href="{$basepath}/experiments/{$vAccession}/samples.html?full=true" title="Some columns were omitted from this view; please click here to get full SDRF view">*</a></sup>
                            </xsl:if>
                        </div>
                        <div id="ae_summary_box">
                            <div id="ae_accession">
                                <a href="{$basepath}/experiments/{$vAccession}">
                                    <xsl:text>Experiment </xsl:text>
                                    <xsl:value-of select="$vAccession"/>
                                </a>
                                <xsl:if test="not($vMetaData/user/@id = '1')">
                                    <img src="{$basepath}/assets/images/silk_lock.gif" alt="Access to the data is restricted" width="8" height="9"/>
                                </xsl:if>
                            </div>
                            <div id="ae_title">
                                <div>
                                    <xsl:value-of select="$vMetaData/name"/>
                                    <xsl:if test="$vMetaData/samples">
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="$vMetaData/samples"/>
                                        <xsl:text> samples)</xsl:text>
                                    </xsl:if>
                                </div>
                            </div>
                        </div>
                        <div id="ae_results_box">
                            <xsl:for-each select="$vSdrfFiles">
                                <xsl:apply-templates select="ae:tabularDocument(fn:concat(../../@root, ../@location, '/', @name))/table">
                                    <xsl:with-param name="pLocation" select="fn:concat(../../@root, ../@location)"/>
                                </xsl:apply-templates>
                                <xsl:if test="fn:position() != fn:last()">
                                    <div class="divider"/>
                                </xsl:if>
                            </xsl:for-each>
                        </div>
                    </div>
                </div>
            </xsl:when>
            <xsl:when test="fn:exists($vSdrfFiles) and fn:not(fn:exists($vMetaData))">
                <xsl:call-template name="block-access-restricted"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="block-not-found"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="add-header-col-info">
        <xsl:param name="pPos"/>
        <xsl:param name="pText"/>

        <xsl:variable name="vIsColComplex" select="not($vFull) and fn:matches($pText, '.+\[.+\].*')"/>
        <xsl:variable name="vIsColComment" select="fn:matches(fn:lower-case($pText), 'comment\s*\[.+\].*')"/>
        <xsl:variable name="vColName" select="if ($vIsColComplex) then fn:replace($pText, '.+\[(.+)\].*', '$1') else $pText"/>
        <xsl:variable name="vColType" select="if (fn:exists(fn:index-of($vLinksColName, lower-case($vColName)))) then 'Links' else (if ($vIsColComplex) then (if ($vIsColComment) then $vColName else fn:replace($pText, '(.+[^\s])\s*\[.+\].*', '$1')) else $pText)"/>
        <xsl:variable name="vColPosition" select="if ($vFull) then $pPos else fn:index-of($vPermittedColType, lower-case($vColType))"/>
        <xsl:variable name="vColClass" select="if (fn:lower-case($vColType) = 'characteristics') then 'sa' else (if (fn:matches(fn:lower-case($vColType), 'factor\s*value')) then 'ef' else '')"/>

        <col pos="{$pPos}" type="{$vColType}" name="{$vColName}" group="{$vColPosition}" class="{$vColClass}"/>
    </xsl:template>

    <xsl:template match="table">
        <xsl:param name="pLocation"/>
        <xsl:variable name="vTableInfo">
            <xsl:variable name="vHeaderRow" select="row[col[1] = 'Source Name'][1]"/>
            <xsl:variable name="vHeaderPos" select="fn:count(row[col[1] = 'Source Name'][1]/preceding-sibling::*) + 1"/>
            <xsl:variable name="vDataLastPos" select="fn:count(row[(col[1] = '') and (fn:position() > $vHeaderPos)][1]/preceding-sibling::*)"/>

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
                    <xsl:variable name="vNeedsFix" as="xs:boolean" select="not($vFull) and (lower-case(@type) = 'unit' or lower-case(@name) = 'timeunit')"/>

                    <xsl:variable name="vColType" select="if ($vNeedsFix) then (preceding-sibling::*[1]/@type) else @type"/>
                    <xsl:variable name="vColName" select="if ($vNeedsFix) then '(unit)' else @name"/>
                    <xsl:variable name="vColGroup" select="if ($vNeedsFix) then (preceding-sibling::*[1]/@group) else @group"/>
                    <xsl:variable name="vColClass" select="if ($vNeedsFix) then (preceding-sibling::*[1]/@class) else @class"/>

                    <col pos="{@pos}" type="{$vColType}" name="{$vColName}" group="{$vColGroup}" class="{$vColClass}"/>
                </xsl:for-each>
            </xsl:variable>

            <header pos="{$vHeaderPos}">
                <xsl:for-each select="$vUnitFixedHeaderInfo/col[@group != '']">
                    <xsl:sort select="@group" order="ascending" data-type="number"/>
                    <xsl:sort select="@pos" order="ascending" data-type="number"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </header>
            <data firstpos="{$vHeaderPos + 1}" lastpos="{if ($vDataLastPos = 0) then count(row) else $vDataLastPos}"/>
        </xsl:variable>

        <xsl:variable name="vSortedData">
            <xsl:for-each select="row[(position() >= $vTableInfo/data/@firstpos) and (position() &lt;= $vTableInfo/data/@lastpos)]">
                <xsl:sort select="col[$vSortBy]" data-type="number" order="{$vSortOrder}"/>
                <xsl:sort select="col[$vSortBy]" order="{$vSortOrder}"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>

        <div class="ae_samples_table_border">
            <table class="ae_samples_table" border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td class="left_fixed">
                        <xsl:call-template name="out-source-name-table">
                            <xsl:with-param name="pTableInfo" select="$vTableInfo"/>
                            <xsl:with-param name="pRows" select="$vSortedData/row"/>
                        </xsl:call-template>
                    </td>
                    <td class="middle_scrollable" rowspan="2">
                        <xsl:call-template name="out-attributes-table">
                            <xsl:with-param name="pTableInfo" select="$vTableInfo"/>
                            <xsl:with-param name="pRows" select="$vSortedData/row"/>
                        </xsl:call-template>
                    </td>
                    <td class="right_fixed">
                        <xsl:call-template name="out-links-table">
                            <xsl:with-param name="pTableInfo" select="$vTableInfo"/>
                            <xsl:with-param name="pRows" select="$vSortedData/row"/>
                            <xsl:with-param name="pLocation" select="$pLocation"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <td class="bottom_filler"/>
                    <td class="bottom_filler"/>
                </tr>
            </table>
        </div>
    </xsl:template>

    <xsl:template name="out-source-name-table">
        <xsl:param name="pTableInfo"/>
        <xsl:param name="pRows"/>

        <xsl:variable name="vTableChunkInfo">
            <header pos="{$pTableInfo/header/@pos}">
                <xsl:copy-of select="$pTableInfo/header/col[1]"/>
            </header>
            <xsl:copy-of select="$pTableInfo/data"/>
        </xsl:variable>

        <table class="src_name_table" border="0" cellpadding="0" cellspacing="0">
            <xsl:call-template name="out-header">
                <xsl:with-param name="pTableInfo" select="$vTableChunkInfo"/>
            </xsl:call-template>
            <xsl:call-template name="out-data">
                <xsl:with-param name="pTableInfo" select="$vTableChunkInfo"/>
                <xsl:with-param name="pRows" select="$pRows"/>
                <xsl:with-param name="pLocation"/>
            </xsl:call-template>
        </table>
    </xsl:template>

    <xsl:template name="out-attributes-table">
        <xsl:param name="pTableInfo"/>
        <xsl:param name="pRows"/>

        <xsl:variable name="vTableChunkInfo">
            <header pos="{$pTableInfo/header/@pos}">
                <xsl:copy-of select="$pTableInfo/header/col[@pos &gt; 1 and @type != 'Links']"/>
            </header>
            <xsl:copy-of select="$pTableInfo/data"/>
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
                        <xsl:with-param name="pLocation"/>
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
        <xsl:param name="pLocation"/>

        <xsl:variable name="vTableChunkInfo">
            <header pos="{$pTableInfo/header/@pos}">
                <xsl:copy-of select="$pTableInfo/header/col[@type='Links']"/>
            </header>
            <xsl:copy-of select="$pTableInfo/data"/>
        </xsl:variable>

        <table class="links_table" border="0" cellpadding="0" cellspacing="0">
            <xsl:call-template name="out-header">
                <xsl:with-param name="pTableInfo" select="$vTableChunkInfo"/>
            </xsl:call-template>
            <xsl:call-template name="out-data">
                <xsl:with-param name="pTableInfo" select="$vTableChunkInfo"/>
                <xsl:with-param name="pRows" select="$pRows"/>
                <xsl:with-param name="pLocation" select="$pLocation"/>
            </xsl:call-template>
        </table>
    </xsl:template>

    <xsl:template name="out-header">
        <xsl:param name="pTableInfo"/>
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
                                <xsl:when test="fn:lower-case($vColInfo/@type) = 'links'">
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
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$vFull"><xsl:value-of select="$vColInfo/@name"/></xsl:when>
                        <xsl:when test="fn:lower-case($vColInfo/@name) = 'ena_run'">ENA</xsl:when>
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
                    <xsl:call-template name="add-sort">
                        <xsl:with-param name="pKind" as="xs:integer" select="$vColInfo/@pos"/>
                    </xsl:call-template>
                </th>
            </xsl:for-each>
        </tr>
    </xsl:template>

    <xsl:template name="out-data">
        <xsl:param name="pTableInfo"/>
        <xsl:param name="pRows"/>
        <xsl:param name="pLocation"/>

        <xsl:for-each select="$pRows">
            <xsl:variable name="vRowPos" select="fn:position()"/>
            <tr>
                <xsl:variable name="vRow" select="."/>
                <xsl:for-each select="$pTableInfo/header/col">
                    <xsl:variable name="vColPos" as="xs:integer" select="@pos"/>
                    <xsl:variable name="vColInfo" select="."/>
                    <xsl:variable name="vCol" select="$vRow/col[$vColPos]"/>
                    <xsl:variable name="vColText" select="$vCol/text()"/>
                    <xsl:variable name="vPrevColText" select="$vRow/preceding-sibling::*[1]/col[$vColPos]/text()"/>
                    <xsl:variable name="vNextRows" select="$vRow/following-sibling::*"/>
                    <xsl:variable name="vNextColText" select="$vNextRows[1]/col[$vColPos]/text()"/>
                    <xsl:variable name="vNextGroupRow" select="$vNextRows[col[$vColPos]/text() != $vColText][1]"/>
                    <xsl:variable name="vNextGroupRowPos" select="if ($vNextGroupRow) then count($vNextGroupRow/preceding-sibling::*) + 1 else ($pTableInfo/data/@lastpos - $pTableInfo/data/@firstpos + 2)"/>

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
                            </xsl:attribute>
                            <xsl:if test="($vColText = $vNextColText) and $vGrouping">
                                <xsl:attribute name="rowspan" select="$vNextGroupRowPos - $vRowPos"/>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="fn:lower-case($vColInfo/@type) = 'links'">
                                    <xsl:choose>
                                        <xsl:when test="fn:contains(fn:lower-case($vColInfo/@name),'file')">
                                            <xsl:variable name="vDataKind" select="if (fn:contains(fn:lower-case($vColInfo/@name),'derived')) then 'fgem' else 'raw'"/>
                                            <xsl:variable name="vAvailArchives" select="$vData[@extension = 'zip' and @kind = $vDataKind]/@name"/>
                                            <xsl:variable name="vArchive" select="fn:replace($vCol/following-sibling::*[1]/text(), '^.+/([^/]+)$', '$1')"/>

                                            <xsl:choose>
                                                <xsl:when test="($vColText) and (fn:index-of($vAvailArchives, $vArchive))">
                                                    <a href="{$basepath}/files/{$vAccession}/{$vArchive}/{fn:encode-for-uri($vColText)}" title="{$vColText}">
                                                        <xsl:choose>
                                                            <xsl:when test="fn:ends-with(fn:lower-case($vColText), '.cel')">
                                                                <img src="{$basepath}/assets/images/silk_data_save_affy.gif" width="16" height="16"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <img src="{$basepath}/assets/images/silk_data_save.gif" width="16" height="16"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </a>
                                                </xsl:when>
                                                <xsl:when test="($vColText) and count($vAvailArchives) = 1">
                                                    <a href="{$basepath}/files/{$vAccession}/{$vAvailArchives}/{fn:encode-for-uri($vColText)}" title="{$vColText}">
                                                        <xsl:choose>
                                                            <xsl:when test="fn:ends-with(fn:lower-case($vColText), '.cel')">
                                                                <img src="{$basepath}/assets/images/silk_data_save_affy.gif" width="16" height="16"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <img src="{$basepath}/assets/images/silk_data_save.gif" width="16" height="16"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$vColText"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:when test="fn:lower-case($vColInfo/@name) = 'ena_run'">
                                            <xsl:variable name="vAvailBAMs" select="$vData[@extension = 'bam']/@name"/>
                                            <xsl:variable name="vBAMFile" select="fn:concat($vAccession, '.BAM.', $vColText, '.bam')"/>
                                            <xsl:variable name="vAvailBAMProps" select="$vData[@extension = 'prop']/@name"/>
                                            <xsl:variable name="vBAMPropFile" select="fn:concat($vBAMFile, '.prop')"/>

                                            <a href="http://www.ebi.ac.uk/ena/data/view/{$vColText}" title="Click to go to ENA run summary">
                                                <img src="{$basepath}/assets/images/data_link_ena.gif" width="23" height="16"/>
                                            </a>
                                            <xsl:if test="fn:index-of($vAvailBAMs, $vBAMFile) and fn:index-of($vAvailBAMProps, $vBAMPropFile)">
                                                <xsl:variable name="vBAMProps" select="ae:tabularDocument(fn:concat($pLocation, '/', $vBAMPropFile, ''))/table/row[2]"/>
                                                <xsl:text> </xsl:text>
                                                <a href="http://www.ensembl.org/{fn:replace($vBAMProps/col[1], ' ', '_')}/Location/View?r={$vBAMProps/col[3]};contigviewbottom=url:{$vBaseUrl}/files/{$vAccession}/{$vBAMFile};format=Bam" title="Click to add a track to Ensembl Genome Browser">
                                                    <img src="http://static.ensembl.org/i/search/ensembl.gif" width="16" height="16"/>
                                                </a>
                                            </xsl:if>
                                        </xsl:when>
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
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </xsl:if>
                </xsl:for-each>
            </tr>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="add-sort">
        <xsl:param name="pKind"/>
        <xsl:if test="$pKind = $vSortBy">
            <xsl:choose>
                <xsl:when test="'ascending' = $vSortOrder"><img src="{$basepath}/assets/images/tsorta.gif" width="12" height="6" alt="^"/></xsl:when>
                <xsl:otherwise><img src="{$basepath}/assets/images/tsortd.gif" width="12" height="6" alt="v"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>