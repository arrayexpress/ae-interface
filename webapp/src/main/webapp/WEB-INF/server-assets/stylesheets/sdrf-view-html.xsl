<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae aejava search html xs"
                exclude-result-prefixes="ae aejava search html xs"
                version="2.0">

    <xsl:param name="accession"/>
    <xsl:param name="filename"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>
    <xsl:param name="userid"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:variable name="vPermittedColType" select="tokenize('source name,characteristics,unit,factorvalue,factor value', '\s*,\s*')"/>
    <xsl:variable name="vPermittedComment" select="tokenize('sample_description,sample_source_name,arrayexpress ftp file,derived arrayexpress ftp file', '\s*,\s*')"/>
    <xsl:variable name="vHeader" select="/table/row[col[1] = 'Source Name'][1]"/>
    <xsl:variable name="vAccession" select="upper-case($accession)"/>
    <xsl:variable name="vMetaData" select="search:queryIndex('experiments', concat('visible:true accession:', $accession, if ($userid) then concat(' userid:(', $userid, ')') else ''))[accession = $vAccession]" />
    
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
                    <script src="{$basepath}/assets/scripts/jquery.cookie-1.0.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_sdrf_view_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">
        <xsl:choose>
            <xsl:when test="exists($vHeader) and exists($vMetaData)">
                <div id="ae_contents_box_100pc">
                    <div id="ae_content">
                        <div id="ae_navi">
                            <a href="${interface.application.link.www_domain}/">EBI</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}">ArrayExpress</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments">Experiments</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments/{upper-case($accession)}">
                                <xsl:value-of select="upper-case($accession)"/>
                            </a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments/{upper-case($accession)}/sdrf">
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
                            <span id="ae_title">
                                <xsl:value-of select="$vMetaData/name"/>
                                <xsl:if test="$vMetaData/samples">
                                    <xsl:text> (</xsl:text>
                                    <xsl:value-of select="$vMetaData/samples"/>
                                    <xsl:text> samples)</xsl:text>
                                </xsl:if>
                            </span>
                        </div>
                        <div id="ae_results_box">
                            <xsl:apply-templates select="/table"/>
                        </div>
                    </div>
                </div>
            </xsl:when>
            <xsl:when test="exists($vHeader) and not(exists($vMetaData))">
                <xsl:call-template name="block-access-restricted"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="block-not-found"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="table">
        <table id="ae_results_table" border="0" cellpadding="0" cellspacing="0">
            <xsl:apply-templates select="row"/>
        </table>
    </xsl:template>

    <xsl:template match="row">
        <xsl:if test="col > ''">
            <xsl:variable name="vIsHeader" select="(. = $vHeader)"/>
            <tr>
                <xsl:for-each select="col">
                    <xsl:variable name="vColNum" select="position()"/>
                    <xsl:variable name="vIsColComplex" select="matches($vHeader/col[$vColNum], '.+\[.+\].*')"/>
                    <xsl:variable name="vColType" select="if ($vIsColComplex) then replace($vHeader/col[$vColNum], '(.+[^\s])\s*\[.+\].*', '$1') else $vHeader/col[$vColNum]"/>
                    <xsl:variable name="vColName" select="if ($vIsColComplex) then replace($vHeader/col[$vColNum], '.+\[(.+)\].*', '$1') else $vHeader/col[$vColNum]"/>
                    <xsl:choose>
                        <xsl:when test="($vColType = 'Comment' and index-of($vPermittedComment, lower-case($vColName))) or index-of($vPermittedColType, lower-case($vColType))">
                            <xsl:choose>
                                <xsl:when test="$vIsHeader">
                                    <th>
                                        <xsl:if test="$vColNum = 1">
                                            <xsl:attribute name="class" select="'col_source_name'"/>
                                        </xsl:if>
                                        <xsl:if test="not($vColType = 'Unit' or $vColName = 'TimeUnit')">
                                            <xsl:value-of select="$vColName"/>
                                        </xsl:if>
                                        <xsl:if test="$vColType = 'Unit' or $vColName = 'TimeUnit'">
                                            <xsl:text>&#160;</xsl:text>
                                        </xsl:if>
                                    </th>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="$vColType = 'Comment' and $vColName = 'ArrayExpress FTP file'">
                                            <td class="ae_align_center">
                                                <a href="{replace(text(), '^.+/experiment/[^/]+/', concat($basepath, '/files/'))}">
                                                    <xsl:value-of select="replace(text(), '^.+/([^/]+)$', '$1')"/>
                                                </a>
                                            </td>
                                        </xsl:when>
                                        <xsl:when test="$vColType = 'Comment' and $vColName = 'Derived ArrayExpress FTP file'">
                                            <td class="ae_align_center">
                                                <a href="{replace(text(), '^.+/experiment/[^/]+/', concat($basepath, '/files'))}">
                                                    <xsl:value-of select="replace(text(), '^.+/([^/]+)$', '$1')"/>
                                                </a>
                                            </td>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <td>
                                                <xsl:if test="$vColNum = 1">
                                                    <xsl:attribute name="class" select="'col_source_name'"/>
                                                </xsl:if>
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

</xsl:stylesheet>
