<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/xslt"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae search html"
                exclude-result-prefixes="ae search html"
                version="2.0">

    <xsl:param name="userid"/>

    <!-- dynamically set by QueryServlet: host name (as seen from client) and base context path of webapp -->
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:include href="ae-file-functions.xsl"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="ISO-8859-1" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">Administration | ArrayExpress Archive | EBI</xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_common_20.css" type="text/css"/>
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_admin_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_files_100924.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">
        <div class="ae_left_container_100pc assign_font">
            <xsl:choose>
                <xsl:when test="not($userid)">
                    <xsl:variable name="vTotalVisibleExperiments" select="count(search:queryIndex2('experiments', 'visible:true'))"/>
                    <xsl:variable name="vPublicVisibleExperiments" select="count(search:queryIndex2('experiments', 'visible:true userid:1'))"/>
                    <xsl:variable name="vPrivateVisibleExperiments" select="$vTotalVisibleExperiments - $vPublicVisibleExperiments"/>

                    <xsl:variable name="vTotalAe1Experiments" select="count(search:queryIndex2('experiments', 'source:ae1'))"/>
                    <xsl:variable name="vMigratedAe1Experiments" select="count(search:queryIndex2('experiments', 'source:ae1 migrated:true'))"/>
                    <xsl:variable name="vOldAe1Experiments" select="$vTotalAe1Experiments - $vMigratedAe1Experiments"/>

                    <xsl:variable name="vTotalAe2Experiments" select="count(search:queryIndex2('experiments', 'source:ae2'))"/>
                    <xsl:variable name="vMigratedAe2Experiments" select="count(search:queryIndex2('experiments', 'source:ae2 migrated:true'))"/>
                    <xsl:variable name="vNewAe2Experiments" select="$vTotalAe2Experiments - $vMigratedAe2Experiments"/>

                    <xsl:variable name="vVisibleAe1Experiments" select="count(search:queryIndex2('experiments', 'visible:true source:ae1'))"/>
                    <xsl:variable name="vVisibleAe2Experiments" select="count(search:queryIndex2('experiments', 'visible:true source:ae2'))"/>

                    <xsl:variable name="vLastUpdatedAe1">
                        <xsl:for-each select="search:queryIndex2('events', 'category:experiments-update-ae1 success:true')">
                            <xsl:sort select="id" order="descending"/>
                            <xsl:if test="position() = 1">
                                <xsl:copy-of select="*"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="vLastUpdatedAe2">
                        <xsl:for-each select="search:queryIndex2('events', 'category:experiments-update-ae2 success:true')">
                            <xsl:sort select="id" order="descending"/>
                            <xsl:if test="position() = 1">
                                <xsl:copy-of select="*"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>

                    <div id="ae_admin_content">
                        <div class="ae_adm_app_name"><xsl:value-of select="/application/@name"/></div>
                        <div class="ae_adm_section_hdr">Statistics</div>
                        <div class="ae_adm_section_body">
                            <p>
                                <xsl:text>Visible experiments (public/private/total):</xsl:text>
                                <xsl:value-of select="$vPublicVisibleExperiments"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$vPrivateVisibleExperiments"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$vTotalVisibleExperiments"/>
                            </p>
                            <div class="ae_twotone_bar">
                                <div class="ae_total">
                                    <div class="ae_value" style="width:{ae:format-percent($vPublicVisibleExperiments, $vTotalVisibleExperiments)}">
                                    </div>
                                </div>
                            </div>
                            <p>
                                <xsl:text>Experiments from ArrayExpress 1 (migrated/old/total):</xsl:text>
                                <xsl:value-of select="$vMigratedAe1Experiments"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$vOldAe1Experiments"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$vTotalAe1Experiments"/>
                            </p>
                            <p>
                                <xsl:text>Last updated: </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="$vLastUpdatedAe1">
                                        <xsl:value-of select="ae:format-datetime($vLastUpdatedAe1/datetime)"/>
                                        <xsl:text> - </xsl:text>
                                        <xsl:value-of select="$vLastUpdatedAe1/description"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>(never)</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </p>
                            <p>
                                <xsl:text>Experiments from ArrayExpress 2 (migrated/new/total):</xsl:text>
                                <xsl:value-of select="$vMigratedAe2Experiments"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$vNewAe2Experiments"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$vTotalAe2Experiments"/>
                            </p>
                            <p>
                                <xsl:text>Last updated: </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="$vLastUpdatedAe2">
                                        <xsl:value-of select="ae:format-datetime($vLastUpdatedAe2/datetime)"/>
                                        <xsl:text> - </xsl:text>
                                        <xsl:value-of select="$vLastUpdatedAe2/description"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>(never)</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </p>
                            <div class="ae_tritone_bar">
                                <div class="ae_total">
                                    <div class="ae_left" style="width:{ae:format-percent($vOldAe1Experiments, $vTotalVisibleExperiments)}"/>
                                    <div class="ae_right" style="width:{ae:format-percent($vNewAe2Experiments, $vTotalVisibleExperiments)}"/> 
                                </div>
                            </div>
                        </div>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="block-access-restricted"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:function name="ae:format-datetime">
        <xsl:param name="pDateTime"/>
        <xsl:value-of select="format-dateTime($pDateTime, '[D01] [MNn] [Y0001], [H01]:[m01]:[s01]', 'en', (), ())"/>
    </xsl:function>

    <xsl:function name="ae:format-percent">
        <xsl:param name="pValue"/>
        <xsl:param name="pTotal"/>
        <xsl:choose>
            <xsl:when test="$pTotal = 0">
                <xsl:text>0%</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="round(($pValue div $pTotal)*1000) div 10"/>
                <xsl:text>%</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
