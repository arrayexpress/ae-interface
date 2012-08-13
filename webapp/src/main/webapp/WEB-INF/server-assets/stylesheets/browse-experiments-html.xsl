<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="xs ae search html"
                exclude-result-prefixes="xs ae search html"
                version="2.0">

    <xsl:param name="page"/>
    <xsl:param name="pagesize"/>
    
    <xsl:variable name="vPage" select="if ($page) then $page cast as xs:integer else 1"/>
    <xsl:variable name="vPageSize" select="if ($pagesize) then $pagesize cast as xs:integer else 25"/>
    
    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'releasedate'"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'descending'"/>
    
    <xsl:param name="queryid"/>
    <xsl:param name="userid"/>

    <xsl:param name="detailedview"/>

    <xsl:param name="basepath"/>
    <xsl:param name="querystring"/>

    <xsl:output omit-xml-declaration="yes" method="html" indent="no" encoding="UTF-8"/>

    <xsl:include href="ae-sort-experiments.xsl"/>
    <xsl:include href="ae-experiments-templates.xsl"/>

    <xsl:variable name="vDetailedViewMainTrClass">tr_main<xsl:if test="'true' = $detailedview"> exp_expanded</xsl:if></xsl:variable>
    <xsl:variable name="vDetailedViewExtStyle"><xsl:if test="'true' != $detailedview">display:none</xsl:if></xsl:variable>
    <xsl:variable name="vDetailedViewMainTdClass">td_main<xsl:if test="'true' = $detailedview"> td_expanded</xsl:if></xsl:variable>

    <xsl:template match="/experiments">
        <xsl:variable name="vFilteredExperiments" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredExperiments)"/>
        <xsl:variable name="vTotalSamples" select="sum($vFilteredExperiments/samples)"/>
        <xsl:variable name="vTotalAssays" select="sum($vFilteredExperiments/assays)"/>

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

        <tr id="ae_results_summary_info">
            <td colspan="9">
                <div id="ae_results_total"><xsl:value-of select="$vTotal"/></div>
                <div id="ae_results_total_samples"><xsl:value-of select="$vTotalSamples"/></div>
                <div id="ae_results_total_assays"><xsl:value-of select="$vTotalAssays"/></div>
                <div id="ae_results_from"><xsl:value-of select="$vFrom"/></div>
                <div id="ae_results_to"><xsl:value-of select="$vTo"/></div>
                <div id="ae_results_page"><xsl:value-of select="$vPage"/></div>
                <div id="ae_results_pagesize"><xsl:value-of select="$vPageSize"/></div>
            </td>
        </tr>
        <xsl:choose>
            <xsl:when test="$vTotal > 0">
                <xsl:call-template name="ae-sort-experiments">
                    <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                    <xsl:with-param name="pFrom" select="$vFrom"/>
                    <xsl:with-param name="pTo" select="$vTo"/>
                    <xsl:with-param name="pSortBy" select="$vSortBy"/>
                    <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <tr class="ae_results_tr_error">
                    <td colspan="9">
                            <div>There are no experiments matching your search criteria found in ArrayExpress Archive.</div>
                            <div>More information on query syntax available in <a href="${interface.application.link.query_help}">ArrayExpress Query Help</a>.</div>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:variable name="vExpId" select="id" as="xs:string"/>
        <xsl:variable name="vAccession" select="accession" as="xs:string"/>
        <xsl:variable name="vFiles" select="ae:getAcceleratorValue('ftp-folder', $vAccession)"/>

        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <tr id="{$vExpId}_main" class="{$vDetailedViewMainTrClass}">
                <td class="{$vDetailedViewMainTdClass}"><div class="table_row_expand"/></td>
                <td class="{$vDetailedViewMainTdClass}">
                    <div class="acc">
                        <div>
                            <a href="{$basepath}/experiments/{accession}">
                                <xsl:call-template name="highlight">
                                    <xsl:with-param name="pQueryId" select="$queryid"/>
                                    <xsl:with-param name="pText" select="accession" />
                                    <xsl:with-param name="pFieldName" select="'accession'" />
                                </xsl:call-template>
                            </a>
                        </div>
                        <div>
                            <xsl:attribute name="class">
                                <xsl:text>acc_status</xsl:text>
                            <xsl:if test="source/@migrated = 'true'">
                                <xsl:text> migrated</xsl:text>
                            </xsl:if>
                            <xsl:if test="source/@identical = 'true'">
                                <xsl:text> identical</xsl:text>
                            </xsl:if>
                            </xsl:attribute>

                        <xsl:if test="not(user/@id = '1')">
                            <span class="lock">&#160;</span>
                        </xsl:if>
                        </div>
                    </div>
                </td>
                <td class="{$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="name[1]"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="ae_align_right {$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="assays"/>
                            <xsl:with-param name="pFieldName" select="'assaycount'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="{$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="string-join(species, ', ')"/>
                            <xsl:with-param name="pFieldName" select="'species'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="{$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="releasedate"/>
                            <xsl:with-param name="pFieldName" select="'date'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="td_main_img ae_align_center {$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="exp-data-files-main">
                            <xsl:with-param name="pKind" select="'fgem'"/>
                            <xsl:with-param name="pFiles" select="$vFiles"/>
                            <xsl:with-param name="pBasePath" select="$basepath"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="td_main_img ae_align_center {$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="exp-data-files-main">
                            <xsl:with-param name="pKind" select="'raw'"/>
                            <xsl:with-param name="pFiles" select="$vFiles"/>
                            <xsl:with-param name="pBasePath" select="$basepath"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="td_main_img ae_align_center {$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:choose>
                            <xsl:when test="@loadedinatlas"><a href="${interface.application.link.atlas.exp_query.url}{$vAccession}?ref=aebrowse"><img src="{$basepath}/assets/images/basic_tick.gif" width="16" height="16" alt="*"/></a></xsl:when>
                            <xsl:otherwise><img src="{$basepath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/></xsl:otherwise>
                        </xsl:choose>
                    </div>
                </td>
            </tr>
            <tr id="{$vExpId}_ext" style="{$vDetailedViewExtStyle}">
                <td colspan="9" class="td_ext">
                    <div class="tbl">
                        <table cellpadding="0" cellspacing="0" border="0">

                            <xsl:call-template name="exp-samples-section">
                                <xsl:with-param name="pQueryString" select="$querystring"/>
                                <xsl:with-param name="pQueryId" select="$queryid"/>
                                <xsl:with-param name="pBasePath" select="$basepath"/>
                            </xsl:call-template>

                            <xsl:call-template name="exp-platforms-section">
                                <xsl:with-param name="pQueryId" select="$queryid"/>
                                <xsl:with-param name="pBasePath" select="$basepath"/>
                            </xsl:call-template>

                            <xsl:call-template name="exp-protocols-section">
                                <xsl:with-param name="pBasePath" select="$basepath"/>
                            </xsl:call-template>

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

                            <xsl:if test="not($userid)">
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

                            <xsl:call-template name="exp-status-section"/>
                        </table>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
