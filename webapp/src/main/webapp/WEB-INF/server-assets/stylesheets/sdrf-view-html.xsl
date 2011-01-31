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
    
    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:variable name="vSortBy" select="if ($sortby) then replace($sortby, 'col_(\d+)', '$1') cast as xs:integer else 1" as="xs:integer"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'ascending'"/>
    
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>
    <xsl:param name="userid"/>
    
    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    
    <xsl:variable name="vTableInfo">
        <xsl:variable name="vHeaderRow" select="/table/row[col[1] = 'Source Name'][1]"/>
        <xsl:variable name="vHeaderPos" select="fn:count(/table/row[col[1] = 'Source Name'][1]/preceding-sibling::*) + 1"/>
        <xsl:variable name="vDataLastPos" select="fn:count(/table/row[(col[1] = '') and (fn:position() > $vHeaderPos)][1]/preceding-sibling::*)"/>
        
        <header pos="{$vHeaderPos}">
            <xsl:for-each select="$vHeaderRow/col">
                <xsl:variable name="vColPos" select="fn:position()"/>
                <xsl:variable name="vIsColComplex" select="fn:matches(text(), '.+\[.+\].*')"/>
                <xsl:variable name="vColType" select="if ($vIsColComplex) then fn:replace(text(), '(.+[^\s])\s*\[.+\].*', '$1') else text()"/>
                <xsl:variable name="vColName" select="if ($vIsColComplex) then fn:replace(text(), '.+\[(.+)\].*', '$1') else text()"/>
                <col pos="{$vColPos}" type="{$vColType}" name="{$vColName}"/>
            </xsl:for-each>
        </header>
        <data firstpos="{$vHeaderPos + 1}" lastpos="{if ($vDataLastPos = 0) then count(/table/row) else $vDataLastPos}"/>        
    </xsl:variable> 
    
    <xsl:variable name="vPermittedColType" select="fn:tokenize('source name,characteristics,unit,factorvalue,factor value,array data file,derived array data file,array data matrix file,derived array data matrix file', '\s*,\s*')"/>
    <xsl:variable name="vPermittedComment" select="fn:tokenize('sample_description,sample_source_name', '\s*,\s*')"/>
    <xsl:variable name="vAccession" select="fn:upper-case($accession)"/>
    <xsl:variable name="vMetaData" select="search:queryIndex('experiments', fn:concat('visible:true accession:', $accession, if ($userid) then fn:concat(' userid:(', $userid, ')') else ''))[accession = $vAccession]" />
    <xsl:variable name="vDataFolder" select="aejava:getAcceleratorValueAsSequence('ftp-folder', $vAccession)"/>
    
    <xsl:output omit-xml-declaration="yes" method="html"
        indent="no" encoding="ISO-8859-1" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>
    
    <xsl:include href="ae-html-page.xsl"/>
    
    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">SDRF | <xsl:value-of select="$vAccession"/> | Experiments | ArrayExpress Archive | EBI</xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_sdrf_view_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_sdrf_view_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
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
                            <a href="{$basepath}/experiments/{fn:upper-case($accession)}/sdrf">
                                <xsl:text>Sample and Data Relationship</xsl:text>
                            </a>
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
            <xsl:apply-templates select="row[number($vTableInfo/header/@pos)]">
                <xsl:with-param name="pIsHeader" select="true()"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="row[(position() >= $vTableInfo/data/@firstpos) and (position() &lt;= $vTableInfo/data/@lastpos)]">
                <xsl:with-param name="pIsHeader" select="false()"/>
                <xsl:sort select="col[$vSortBy]" data-type="number" order="{$vSortOrder}"/>
                <xsl:sort select="col[$vSortBy]" order="{$vSortOrder}"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>
    
    <xsl:template match="row">
        <xsl:param name="pIsHeader"/>
        
        <xsl:if test="col > ''">
            <tr>
                <xsl:for-each select="col">
                    <xsl:variable name="vColPos" select="fn:position()"/>
                    <xsl:variable name="vColInfo" select="$vTableInfo/header/col[$vColPos]"/>
                    <xsl:choose>
                        <xsl:when test="($vColInfo/@type = 'Comment' and (fn:index-of($vPermittedComment, lower-case($vColInfo/@name)))) or (fn:index-of($vPermittedColType, lower-case($vColInfo/@type)))">
                            <xsl:choose>
                                <xsl:when test="$pIsHeader">
                                    <th class="col_{$vColInfo/@pos}">
                                        <xsl:if test="not($vColInfo/@type = 'Unit' or $vColInfo/@name = 'TimeUnit')">
                                            <xsl:value-of select="$vColInfo/@name"/>
                                        </xsl:if>
                                        <xsl:if test="$vColInfo/@type = 'Unit' or $vColInfo/@name = 'TimeUnit'">
                                            <xsl:text>(unit)</xsl:text>
                                        </xsl:if>
                                        <xsl:call-template name="add-sort">
                                            <xsl:with-param name="pKind" as="xs:integer" select="$vColInfo/@pos"/>
                                        </xsl:call-template>
                                    </th>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="fn:contains(fn:lower-case($vColInfo/@type),'file')">
                                            <xsl:variable name="vDataKind" select="if (fn:contains(fn:lower-case($vColInfo/@type),'derived')) then 'fgem' else 'raw'"/>
                                            <xsl:variable name="vAvailArchives" select="$vDataFolder/file[@extension = 'zip' and @kind = $vDataKind]/@name"/>
                                            <xsl:variable name="vArchive" select="fn:replace(following-sibling::col[1]/text(), '^.+([^/]+)$', '$1')"/>
                                            <td class="col_{$vColInfo/@pos}">
                                                <xsl:choose>
                                                    <xsl:when test="(text()) and (fn:index-of($vAvailArchives, $vArchive))">
                                                        <a href="{$basepath}/files/{$vAccession}/{$vArchive}/{fn:encode-for-uri(text())}">
                                                            <xsl:value-of select="text()"/>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:when test="(text()) and count($vAvailArchives) = 1">
                                                        <a href="{$basepath}/files/{$vAccession}/{$vAvailArchives}/{fn:encode-for-uri(text())}">
                                                            <xsl:value-of select="text()"/>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="text()"/>
                                                        <xsl:if test="not(text())">
                                                            <xsl:text>&#160;</xsl:text>
                                                        </xsl:if>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <td class="col_{$vColInfo/@pos}">
                                                <xsl:value-of select="text()"/>
                                                <xsl:if test="not(text())">
                                                    <xsl:text>&#160;</xsl:text>
                                                </xsl:if>
                                            </td>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>   
                    </xsl:choose>
                </xsl:for-each>
            </tr>
        </xsl:if>
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

</xsl:stylesheet>
