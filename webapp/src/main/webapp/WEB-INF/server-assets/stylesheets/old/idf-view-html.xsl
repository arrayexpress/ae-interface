<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae search html xs"
                exclude-result-prefixes="ae search html xs"
                version="2.0">

    <xsl:param name="accession"/>
    <xsl:param name="filename"/>

    <xsl:param name="host"/>
    <xsl:param name="context-path"/>
    <xsl:param name="userid"/>

    <xsl:variable name="vBaseUrl"><xsl:value-of select="$host"/><xsl:value-of select="$context-path"/></xsl:variable>

    <xsl:variable name="vAccession" select="upper-case($accession)"/>
    <xsl:variable name="vMetaData" select="search:queryIndex('experiments', concat('visible:true accession:', $accession, if ($userid) then concat(' userid:(', $userid, ')') else ''))[accession = $vAccession]" />

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="../ae-html-page.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">IDF | <xsl:value-of select="$vAccession"/> | Experiments | ArrayExpress Archive | EBI</xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$context-path}/assets/stylesheets/ae_idf_view_20.css" type="text/css"/>
                    <script src="{$context-path}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$context-path}/assets/scripts/jquery.cookie-1.0.js" type="text/javascript"/>
                    <script src="{$context-path}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$context-path}/assets/scripts/_old_ae_idf_view_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">
        <xsl:choose>
            <xsl:when test="exists($vMetaData)">
                <div id="ae_contents_box_100pc">
                    <div id="ae_content">
                        <div id="ae_navi">
                            <a href="${interface.application.link.www_domain}/">EBI</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$context-path}">ArrayExpress</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$context-path}/experiments">Experiments</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$context-path}/experiments/{upper-case($accession)}">
                                <xsl:value-of select="upper-case($accession)"/>
                            </a>
                            <xsl:text> > </xsl:text>
                            <a href="{$context-path}/experiments/{upper-case($accession)}/idf.html">
                                <xsl:text>Investigation Description View</xsl:text>
                            </a>
                        </div>
                        <div id="ae_summary_box">
                            <div id="ae_accession">
                                <a href="{$context-path}/experiments/{$vAccession}">
                                    <xsl:text>Experiment </xsl:text>
                                    <xsl:value-of select="$vAccession"/>
                                </a>
                                <xsl:if test="not($vMetaData/user/@id = '1')">
                                    <img src="{$context-path}/assets/images/silk_lock.gif" alt="Access to the data is restricted" width="8" height="9"/>
                                </xsl:if>
                            </div>

                            <div id="ae_title">
                                <div><xsl:value-of select="$vMetaData/name"/></div>
                            </div>
                        </div>
                        <div id="ae_results_box">
                            <xsl:apply-templates select="/table"/>
                        </div>
                    </div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="block-access-restricted"/>
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
            <xsl:variable name="vRowName" select="col[1]"/>
            <tr>
                <td class="col_1"><xsl:value-of select="$vRowName"/></td>
                <td class="col_2"><xsl:value-of select="string-join(col[position() > 1 and text() > ''], ', ')"/></td>
            </tr>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
