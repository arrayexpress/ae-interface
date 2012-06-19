<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
    xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
    xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
    xmlns:html="http://www.w3.org/1999/xhtml"
    extension-element-prefixes="ae aejava search"
    exclude-result-prefixes="ae aejava search html fn xs"
    version="2.0">
    
    <xsl:param name="accession"/>
    <xsl:param name="filename"/>
    <xsl:param name="grouping"/>
    <xsl:param name="full"/>
    <xsl:param name="debug"/>

    <xsl:variable name="vGrouping" as="xs:boolean" select="not(not($grouping))"/>
    <xsl:variable name="vFull" as="xs:boolean" select="not(not($full))"/>
    <xsl:variable name="vPageName" select="fn:replace($filename, '[^.]+\.(.+)\.txt', '$1.html')"/>

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:variable name="vSortBy" select="if ($sortby) then fn:replace($sortby, 'col_(\d+)', '$1') cast as xs:integer else 1" as="xs:integer"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'ascending'"/>
    
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>
    <xsl:param name="userid"/>
    
    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    
    <xsl:variable name="vPermittedColType" select="fn:tokenize('source name,sample_description,sample_source_name,characteristics,factorvalue,factor value,unit,array data file,derived array data file,array data matrix file,derived array data matrix file,ena_run,links', '\s*,\s*')"/>
    <xsl:variable name="vLinksColName" select="fn:tokenize('array data file,derived array data file,array data matrix file,derived array data matrix file,ena_run', '\s*,\s*')"/>

    <xsl:template name="add-header-col-info">
        <xsl:param name="pPos"/>
        <xsl:param name="pText"/>

        <xsl:variable name="vIsColComplex" select="not($vFull) and fn:matches($pText, '.+\[.+\].*')"/>
        <xsl:variable name="vIsColComment" select="fn:matches(fn:lower-case($pText), 'comment\s*\[.+\].*')"/>
        <xsl:variable name="vColName" select="if ($vIsColComplex) then fn:replace($pText, '.+\[(.+)\].*', '$1') else $pText"/>
        <xsl:variable name="vColType" select="if (fn:exists(fn:index-of($vLinksColName, lower-case($vColName)))) then 'Links' else (if ($vIsColComplex) then (if ($vIsColComment) then $vColName else fn:replace($pText, '(.+[^\s])\s*\[.+\].*', '$1')) else $pText)"/>
        <xsl:variable name="vColPosition" select="if ($vFull) then $pPos else fn:index-of($vPermittedColType, lower-case($vColType))"/>

        <col pos="{$pPos}" type="{$vColType}" name="{$vColName}" group="{$vColPosition}"/>
    </xsl:template>  
 
    <xsl:variable name="vTableInfo">
        
        <xsl:variable name="vHeaderRow" select="/table/row[col[1] = 'Source Name'][1]"/>
        <xsl:variable name="vHeaderPos" select="fn:count(/table/row[col[1] = 'Source Name'][1]/preceding-sibling::*) + 1"/>
        <xsl:variable name="vDataLastPos" select="fn:count(/table/row[(col[1] = '') and (fn:position() > $vHeaderPos)][1]/preceding-sibling::*)"/>
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
                <xsl:variable name="vNeedFix" as="xs:boolean" select="not($vFull) and (lower-case(@type) = 'unit' or lower-case(@name) = 'timeunit')"/>

                <xsl:variable name="vColType" select="if ($vNeedFix) then (preceding-sibling::*[1]/@type) else @type"/>
                <xsl:variable name="vColName" select="if ($vNeedFix) then '(unit)' else @name"/>
                <xsl:variable name="vColGroup" select="if ($vNeedFix) then (preceding-sibling::*[1]/@group) else @group"/>

                <col pos="{@pos}" type="{$vColType}" name="{$vColName}" group="{$vColGroup}"/>
            </xsl:for-each>
                
        </xsl:variable>
 
        <header pos="{$vHeaderPos}">
            <xsl:for-each select="$vUnitFixedHeaderInfo/col[@group != '']">
                <xsl:sort select="@group" order="ascending" data-type="number"/>
                <xsl:sort select="@pos" order="ascending" data-type="number"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </header>
        <data firstpos="{$vHeaderPos + 1}" lastpos="{if ($vDataLastPos = 0) then count(/table/row) else $vDataLastPos}"/>        
    </xsl:variable>  
    
    <xsl:variable name="vAccession" select="fn:upper-case($accession)"/>
    <xsl:variable name="vMetaData" select="search:queryIndex('experiments', fn:concat('visible:true accession:', $accession, if ($userid) then fn:concat(' userid:(', $userid, ')') else ''))[accession = $vAccession]" />
    <xsl:variable name="vDataFolder" select="aejava:getAcceleratorValueAsSequence('ftp-folder', $vAccession)"/>
    
    <xsl:output omit-xml-declaration="yes" method="html"
        indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>
    
    <xsl:include href="ae-html-page.xsl"/>
    
    <xsl:template match="/">
        <html lang="en">
            <xsl:choose>
                <xsl:when test="not(not($debug))">
                    <xsl:apply-templates select="/table"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="page-header">
                        <xsl:with-param name="pTitle">Samples and Data |
                            <xsl:value-of select="$vAccession"/> | Experiments | ArrayExpress Archive | EBI
                        </xsl:with-param>
                        <xsl:with-param name="pExtraCode">
                            <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_sdrf_view_20.css" type="text/css"/>
                            <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                            <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                            <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                            <script src="{$basepath}/assets/scripts/ae_sdrf_view_20.js" type="text/javascript"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="page-body"/>
                </xsl:otherwise>
            </xsl:choose>
        </html>

</xsl:template>
    
    <xsl:template name="ae-contents">
        <xsl:choose>
            <xsl:when test="($vTableInfo/header/@pos != 0) and exists($vMetaData)">
                <div id="ae_contents_box_100pc">
                    <div id="ae_content">
                        <div id="ae_navi">
                            <a href="${interface.application.link.www_domain}/">EBI</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}">ArrayExpress</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments">Experiments</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments/{fn:upper-case($accession)}">
                                <xsl:value-of select="fn:upper-case($accession)"/>
                            </a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments/{fn:upper-case($accession)}/{$vPageName}">
                                <xsl:text>Samples and Data</xsl:text>
                            </a>
                            <xsl:if test="not($vFull)">
                                <sup><a href="{$basepath}/experiments/{fn:upper-case($accession)}/{$vPageName}?full=true" title="Some columns were omitted from this view; please click here to get full SDRF view">*</a></sup>
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
                            <xsl:apply-templates select="/table"/>
                        </div>
                    </div>
                </div>
            </xsl:when>
            <xsl:when test="($vTableInfo/header/@pos != 0) and not(fn:exists($vMetaData))">
                <xsl:call-template name="block-access-restricted"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="block-not-found"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="table">
        <table id="ae_results_table" border="0" cellpadding="0" cellspacing="0">
            <xsl:call-template name="out-header"/>
            <xsl:variable name="vSortedData">
                <xsl:for-each select="row[(position() >= $vTableInfo/data/@firstpos) and (position() &lt;= $vTableInfo/data/@lastpos)]">
                    <xsl:sort select="col[$vSortBy]" data-type="number" order="{$vSortOrder}"/>
                    <xsl:sort select="col[$vSortBy]" order="{$vSortOrder}"/>
                    <xsl:copy-of select="."/>                    
                </xsl:for-each>
            </xsl:variable>
            <xsl:call-template name="out-data">
                <xsl:with-param name="pRows" select="$vSortedData/row"/>
            </xsl:call-template>
        </table>
    </xsl:template>
    
    <xsl:template name="out-header">
        <thead>
            <xsl:if test="not($vFull)">
                <tr>
                    <xsl:for-each select="$vTableInfo/header/col">
                        <xsl:variable name="vColInfo" select="."/>
                        <xsl:variable name="vColPos" select="position()"/>
                        <xsl:variable name="vColType" select="$vColInfo/@type"/>
                        <xsl:variable name="vPrevColType" select="preceding-sibling::*[1]/@type"/>
                        <xsl:variable name="vNextCols" select="following-sibling::*"/>
                        <xsl:variable name="vNextColType" select="$vNextCols[1]/@type"/>
                        <xsl:variable name="vNextGroupCol" select="$vNextCols[@type != $vColType][1]"/>
                        <xsl:variable name="vNextGroupColPos" select="if ($vNextGroupCol) then count($vNextGroupCol/preceding-sibling::*) + 1 else (count($vTableInfo/header/col) + 1)"/>
                        <xsl:if test="not($vPrevColType = $vColType)">
                            <th>
                                <xsl:attribute name="class">
                                    <xsl:text>col_group</xsl:text>
                                    <xsl:if test="$vColPos = 1">
                                        <xsl:text> col_1</xsl:text>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="$vColType = 'Characteristics'">
                                            <xsl:text> col_sc</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="matches(lower-case($vColType), 'factor\s*value')">
                                            <xsl:text> col_fv</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="matches(lower-case($vColType), 'links')">
                                            <xsl:text> col_links</xsl:text>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:if test="($vColType = $vNextColType)">
                                    <xsl:attribute name="colspan" select="$vNextGroupColPos - $vColPos"/>
                                </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="fn:lower-case($vColInfo/@type) = 'characteristics'">
                                        <xsl:text>Sample Characteristics</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="matches(lower-case($vColType), 'factor\s*value')">
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
                <xsl:for-each select="$vTableInfo/header/col">
                    <xsl:variable name="vColInfo" select="."/>
                    <th>
                        <xsl:attribute name="class">
                            <xsl:text>col_sort col_</xsl:text>
                            <xsl:value-of select="$vColInfo/@pos"/>
                            <xsl:choose>
                                <xsl:when test="$vFull"> col_uni</xsl:when>
                                <xsl:when test="fn:lower-case($vColInfo/@type) = 'characteristics'">
                                    <xsl:text> col_sc</xsl:text>
                                </xsl:when>
                                <xsl:when test="fn:matches(lower-case($vColInfo/@type), 'factor\s*value')">
                                    <xsl:text> col_fv</xsl:text>
                                </xsl:when>
                                <xsl:when test="fn:lower-case($vColInfo/@type) = 'links'">
                                    <xsl:text> col_links</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="fn:lower-case($vColInfo/@name) = 'ena_run'">ENA</xsl:when>
                            <xsl:otherwise><xsl:value-of select="$vColInfo/@name"/></xsl:otherwise>
                        </xsl:choose>
                        <xsl:call-template name="add-sort">
                            <xsl:with-param name="pKind" as="xs:integer" select="$vColInfo/@pos"/>
                        </xsl:call-template>
                    </th>
                </xsl:for-each>
            </tr>
        </thead>
    </xsl:template>
    
    <xsl:template name="out-data">
        <xsl:param name="pRows"/>
        <xsl:for-each select="$pRows">
            <xsl:variable name="vRowPos" select="1 + position() - 1"/>
            <tr>
                <xsl:variable name="vRow" select="."/>
                <xsl:for-each select="$vTableInfo/header/col">
                    <xsl:variable name="vColPos" as="xs:integer" select="@pos"/>
                    <xsl:variable name="vColInfo" select="."/>
                    <xsl:variable name="vCol" select="$vRow/col[$vColPos]"/>
                    <xsl:variable name="vColText" select="$vCol/text()"/>
                    <xsl:variable name="vPrevColText" select="$vRow/preceding-sibling::*[1]/col[$vColPos]/text()"/>
                    <xsl:variable name="vNextRows" select="$vRow/following-sibling::*"/>
                    <xsl:variable name="vNextColText" select="$vNextRows[1]/col[$vColPos]/text()"/>
                    <xsl:variable name="vNextGroupRow" select="$vNextRows[col[$vColPos]/text() != $vColText][1]"/>
                    <xsl:variable name="vNextGroupRowPos" select="if ($vNextGroupRow) then count($vNextGroupRow/preceding-sibling::*) + 1 else ($vTableInfo/data/@lastpos - $vTableInfo/data/@firstpos + 2)"/>
                    
                    <xsl:if test="not($vPrevColText = $vColText) or not($vGrouping)">
                        <td class="col_{$vColInfo/@pos}">
                            <xsl:if test="($vColText = $vNextColText) and $vGrouping">
                                <xsl:attribute name="rowspan" select="$vNextGroupRowPos - $vRowPos"/>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="fn:lower-case($vColInfo/@type) = 'links'">
                                    <xsl:choose>
                                        <xsl:when test="fn:contains(fn:lower-case($vColInfo/@name),'file')">
                                            <xsl:variable name="vDataKind" select="if (fn:contains(fn:lower-case($vColInfo/@type),'derived')) then 'fgem' else 'raw'"/>
                                            <xsl:variable name="vAvailArchives" select="$vDataFolder/file[@extension = 'zip' and @kind = $vDataKind]/@name"/>
                                            <xsl:variable name="vArchive" select="fn:replace($vCol/following-sibling::*[1]/text(), '^.+/([^/]+)$', '$1')"/>

                                            <xsl:choose>
                                                <xsl:when test="($vColText) and (fn:index-of($vAvailArchives, $vArchive))">
                                                    <a href="{$basepath}/files/{$vAccession}/{$vArchive}/{fn:encode-for-uri($vColText)}">
                                                        <xsl:value-of select="$vColText"/>
                                                    </a>
                                                </xsl:when>
                                                <xsl:when test="($vColText) and count($vAvailArchives) = 1">
                                                    <a href="{$basepath}/files/{$vAccession}/{$vAvailArchives}/{fn:encode-for-uri($vColText)}">
                                                        <xsl:value-of select="$vColText"/>
                                                    </a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$vColText"/>
                                                    <xsl:if test="not($vColText)">
                                                        <xsl:text>&#160;</xsl:text>
                                                    </xsl:if>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:when test="fn:lower-case($vColInfo/@name) = 'ena_run'">
                                            <xsl:variable name="vAvailBAMs" select="$vDataFolder/file[@extension = 'bam']/@name"/>
                                            <xsl:variable name="vBAMFile" select="fn:concat($vAccession, '.BAM.', $vColText, '.bam')"/>
                                            <xsl:attribute name="style" select="'padding:2px 5px 0 5px'"/>

                                            <a href="http://www.ebi.ac.uk/ena/data/view/{$vColText}">
                                                <img src="{$basepath}/assets/images/data_link_ena.gif" width="23" height="16" alt="Link to ENA run data page"/>
                                            </a>
                                            <xsl:if test="fn:index-of($vAvailBAMs, $vBAMFile)">
                                                <xsl:text> </xsl:text>
                                                <a href="http://www.ensembl.org/Homo_sapiens/Location/View?r=1:69311767-69437746;contigviewbottom=url:{$vBaseUrl}/files/{$vAccession}/{$vBAMFile};format=Bam">
                                                    <img src="http://static.ensembl.org/i/search/ensembl.gif" width="16" height="16" alt="Add a track to Ensembl Genome Browser"/>
                                                </a>
                                            </xsl:if>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>

                                <xsl:otherwise>
                                    <xsl:value-of select="$vColText"/>
                                    <xsl:if test="not($vColText)">
                                        <xsl:text>&#160;</xsl:text>
                                    </xsl:if>
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
