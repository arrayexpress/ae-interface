<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="aejava search html"
                exclude-result-prefixes="aejava search html"
                version="2.0">

    <xsl:param name="queryid"/>
    <xsl:param name="accession"/>

    <xsl:param name="userid"/>

    <xsl:param name="basepath"/>

    <xsl:variable name="vAccession" select="upper-case($accession)"/>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-experiments-templates.xsl"/>

    <xsl:template match="/experiments">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">
                    <xsl:value-of select="$vAccession"/><xsl:text> | Experiments | ArrayExpress Archive | EBI</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_experiments_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jsdeferred.jquery-0.3.1.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.caret-range-1.0.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.autocomplete-1.1.0m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_experiments_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">

        <xsl:variable name="vExperiment" select="search:queryIndex($queryid)[accession = $vAccession]"/>

        <xsl:choose>
            <xsl:when test="exists($vExperiment)">
                <xsl:call-template name="block-experiment">
                    <xsl:with-param name="pExperiment" select="$vExperiment"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="block-not-found"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="block-experiment">
        <xsl:param name="pExperiment"/>
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
                </div>
                <div id="ae_summary_box">
                    <div id="ae_accession">
                        <a href="{$basepath}/experiments/{$vAccession}">
                            <xsl:text>Experiment </xsl:text>
                            <xsl:value-of select="$vAccession"/>
                        </a>
                        <xsl:if test="not($pExperiment/user/@id = '1')">
                            <img src="{$basepath}/assets/images/silk_lock.gif" width="8" height="9"/>
                        </xsl:if>
                    </div>
                    <div id="ae_title">
                        <div>
                            <xsl:value-of select="$pExperiment/name"/>
                            <xsl:if test="$pExperiment/assays">
                                <xsl:text> (</xsl:text>
                                <xsl:value-of select="$pExperiment/assays"/>
                                <xsl:text> assays)</xsl:text>
                            </xsl:if>
                        </div>
                    </div>
                </div>
                <div id="ae_results_box">
                    <xsl:apply-templates select="$pExperiment"/>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:variable name="vFiles" select="aejava:getAcceleratorValueAsSequence('ftp-folder', $vAccession)"/>

        <div id="ae_experiment_content">
            <div class="ae_detail">
                <div class="tbl">
                    <table cellpadding="0" cellspacing="0" border="0">
                        <xsl:if test="species">
                            <tr>
                                <td class="name"><div>Species</div></td>
                                <td class="value"><div><xsl:value-of select="string-join(species, ', ')"/></div></td>
                            </tr>
                        </xsl:if>

                        <xsl:call-template name="exp-status-section"/>

                        <xsl:call-template name="exp-description-section">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                        </xsl:call-template>

                        <xsl:call-template name="exp-keywords-section">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="exp-contact-section">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="exp-citation-section">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="exp-minseqe-section">
                            <xsl:with-param name="pBasePath" select="$basepath"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="exp-miame-section">
                            <xsl:with-param name="pBasePath" select="$basepath"/>
                        </xsl:call-template>

                        <xsl:call-template name="exp-platforms-section">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pBasePath" select="$basepath"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="exp-samples-section">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pBasePath" select="$basepath"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="exp-protocols-section">
                            <xsl:with-param name="pBasePath" select="$basepath"/>
                        </xsl:call-template>

                        <xsl:if test="not($userid)"> <!-- curator logged in -->
                            <xsl:call-template name="exp-experimental-factors-section">
                                <xsl:with-param name="pQueryId" select="$queryid"/>
                            </xsl:call-template>

                            <xsl:call-template name="exp-sample-attributes-section">
                                <xsl:with-param name="pQueryId" select="$queryid"/>
                            </xsl:call-template>
                        </xsl:if>

                        <xsl:call-template name="exp-files-section">
                            <xsl:with-param name="pBasePath" select="$basepath"/>
                            <xsl:with-param name="pFiles" select="$vFiles"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="exp-links-section">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pBasePath" select="$basepath"/>
                        </xsl:call-template>
                    </table>
                </div>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>
