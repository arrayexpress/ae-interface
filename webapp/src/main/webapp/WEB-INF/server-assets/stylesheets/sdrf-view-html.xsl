<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae search html xs"
                exclude-result-prefixes="ae search html xs"
                version="2.0">

    <xsl:param name="accession"/>
    <xsl:param name="filename"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:variable name="vPermittedColType" select="tokenize('Source Name,Characteristics,Unit,FactorValue,Factor Value', '\s*,\s*')"/>
    <xsl:variable name="vPermittedComment" select="tokenize('ArrayExpress FTP file,Derived ArrayExpress FTP file', '\s*,\s*')"/>
    <xsl:variable name="vHeader" select="/table/row[col[1] = 'Source Name'][1]"/>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="ISO-8859-1" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">SDRF Viewer | ArrayExpress Archive | EBI</xsl:with-param>
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
                    <a href="{$basepath}/experiments/{upper-case($accession)}/{$filename}?view">
                        <xsl:value-of select="$filename"/>
                    </a>
                </div>
                <div id="ae_results_box">
                    <xsl:apply-templates select="/table"/>
                </div>
            </div>
        </div>
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
                        <xsl:when test="($vColType = 'Comment' and index-of($vPermittedComment, $vColName)) or index-of($vPermittedColType, $vColType)">
                            <xsl:choose>
                                <xsl:when test="$vIsHeader">
                                    <th>
                                        <xsl:if test="not($vColType = 'Unit' or $vColName = 'TimeUnit')">
                                            <xsl:value-of select="$vColName"/>
                                        </xsl:if>
                                    </th>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="$vColType = 'Comment' and $vColName = 'ArrayExpress FTP file'">
                                            <td class="ae_align_center">
                                                <a href="replace(text(), 'ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/experiment/[^\/]+/', concat($basepath, '/files'))"><img src="{$basepath}/assets/images/silk_data_save.gif" width="16" height="16" alt="Click to download raw data"/></a>
                                            </td>
                                        </xsl:when>
                                        <xsl:when test="$vColType = 'Comment' and $vColName = 'Derived ArrayExpress FTP file'">
                                            <td class="ae_align_center">
                                                <a href="replace(text(), 'ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/experiment/[^\/]+/', concat($basepath, '/files'))"><img src="{$basepath}/assets/images/silk_data_save.gif" width="16" height="16" alt="Click to download processed data"/></a>
                                            </td>
                                        </xsl:when>
                                        <xsl:otherwise><td><xsl:value-of select="text()"/></td></xsl:otherwise>
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
