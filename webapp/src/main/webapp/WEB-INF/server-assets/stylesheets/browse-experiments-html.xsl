<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="xs ae search html"
                exclude-result-prefixes="xs ae search html"
                version="2.0">

    <xsl:param name="queryid"/>
    <xsl:param name="userid"/>
    <xsl:param name="page"/>
    <xsl:param name="pagesize"/>
    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>

    <xsl:param name="detailedview"/>

    <!-- dynamically set by QueryServlet: host name (as seen from client) and base context path of webapp -->
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    <xsl:variable name="vFilesDoc" select="doc('files.xml')"/>

    <xsl:output omit-xml-declaration="yes" method="html" indent="no" encoding="ISO-8859-1"/>

    <xsl:include href="ae-sort-experiments.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>

    <xsl:variable name="vDetailedViewMainTrClass">tr_main<xsl:if test="'true' = $detailedview"> exp_expanded</xsl:if></xsl:variable>
    <xsl:variable name="vDetailedViewExtStyle"><xsl:if test="'true' != $detailedview">display:none</xsl:if></xsl:variable>
    <xsl:variable name="vDetailedViewMainTdClass">td_main<xsl:if test="'true' = $detailedview"> td_expanded</xsl:if></xsl:variable>

    <xsl:template match="/experiments">
        <xsl:variable name="vFilteredExperiments" select="search:queryIndex('experiments', $queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredExperiments)"/>
        <xsl:variable name="vTotalSamples" select="sum($vFilteredExperiments/samples)"/>
        <xsl:variable name="vTotalAssays" select="sum($vFilteredExperiments/assays)"/>

        <xsl:variable name="vPage" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$page"><xsl:value-of select="number($page)"/></xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="vPageSize" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$pagesize"><xsl:value-of select="number($pagesize)"/></xsl:when>
                <xsl:otherwise>25</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

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
                    <xsl:with-param name="pSortBy" select="$sortby"/>
                    <xsl:with-param name="pSortOrder" select="$sortorder"/>
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
        <xsl:variable name="vExpId" select="string(id)"/>
        <xsl:variable name="vAccession" select="string(accession)"/>
        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <tr id="{$vExpId}_main" class="{$vDetailedViewMainTrClass}">
                <td class="{$vDetailedViewMainTdClass}"><div class="table_row_expand"/></td>
                <td class="{$vDetailedViewMainTdClass}">
                    <div class="table_row_accession">
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="accession" />
                            <xsl:with-param name="pFieldName" select="'accession'" />
                        </xsl:call-template>
                    </div>
                    <xsl:if test="not($userid)"> <!-- curator logged in -->
                        <xsl:choose>
                            <xsl:when test="source/@id = 'ae1' and source/@multi != 'true'"><span class="ae1"><xsl:if test="source/@preferred = 'true'">*</xsl:if>1</span></xsl:when>
                            <xsl:when test="source/@id = 'ae1' and source/@multi = 'true'"><span class="ae1m"><xsl:if test="source/@preferred = 'true'">*</xsl:if>m1</span></xsl:when>
                            <xsl:when test="source/@id = 'ae2'"><span class="ae2"><xsl:if test="source/@preferred = 'true'">*</xsl:if><xsl:if test="source/@multi = 'true'">m</xsl:if>2</span></xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="not(user/@id = '1')">
                        <div class="lock">&#160;</div>
                    </xsl:if>
                </td>
                <td class="{$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="name"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="align_right {$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="assays"/>
                            <xsl:with-param name="pFieldName" select="'assaycount'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="{$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="string-join(species, ', ')"/>
                            <xsl:with-param name="pFieldName" select="'species'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="{$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="releasedate"/>
                            <xsl:with-param name="pFieldName" select="'date'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="td_main_img align_center {$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="data-files-main">
                            <xsl:with-param name="pKind" select="'fgem'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="td_main_img align_center {$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:call-template name="data-files-main">
                            <xsl:with-param name="pKind" select="'raw'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="td_main_img align_center {$vDetailedViewMainTdClass}">
                    <div>
                        <xsl:choose>
                            <xsl:when test="@loadedinatlas"><a href="${interface.application.link.atlas.exp_query.url}{$vAccession}&amp;ref=aebrowse"><img src="{$basepath}/assets/images/basic_tick.gif" width="16" height="16" alt="*"/></a></xsl:when>
                            <xsl:otherwise><img src="{$basepath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/></xsl:otherwise>
                        </xsl:choose>
                    </div>
                </td>
            </tr>
            <tr id="{$vExpId}_ext" style="{$vDetailedViewExtStyle}">
                <td colspan="9" class="td_ext">
                    <div class="tbl">
                        <table cellpadding="0" cellspacing="0" border="0">
                            <xsl:variable name="vDescription" select="description[string-length(text) > 0 and not(contains(text, '(Generated description)'))]"/>
                            <xsl:if test="$vDescription">
                                <tr>
                                    <td class="name"><div>Description</div></td>
                                    <td class="value">
                                        <xsl:for-each select="$vDescription">
                                            <xsl:sort select="id" data-type="number"/>
                                            <xsl:apply-templates select="text" mode="highlight"/>
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:if>

                            <xsl:if test="miamescores">
                                <tr>
                                    <td class="name"><div>MIAME score</div></td>
                                    <td class="value">
                                        <div>
                                            <xsl:call-template name="miame-score">
                                                <xsl:with-param name="pScores" select="miamescores"/>
                                            </xsl:call-template>
                                        </div>
                                    </td>
                                </tr>
                            </xsl:if>

                            <xsl:if test="provider[role!='data_coder']">
                                <tr>
                                    <td class="name"><div>Contact<xsl:if test="count(provider[role!='data_coder']) > 1">s</xsl:if></div></td>
                                    <td class="value">
                                        <div>
                                            <xsl:call-template name="providers"/>
                                        </div>
                                    </td>
                                </tr>
                            </xsl:if>

                            <xsl:if test="bibliography/*">
                                <tr>
                                    <td class="name"><div>Citation<xsl:if test="count(bibliography/*) > 1">s</xsl:if></div></td>
                                    <td class="value"><xsl:apply-templates select="bibliography" /></td>
                                </tr>
                            </xsl:if>

                            <tr>
                                <td class="name"><div>Links</div></td>
                                <td class="value">
                                    <xsl:if test="@loadedinatlas">
                                        <div><a href="${interface.application.link.atlas.exp_query.url}{$vAccession}&amp;ref=aebrowse">Query Gene Expression Atlas</a></div>
                                    </xsl:if>
                                    <div>
                                        <xsl:if test="secondaryaccession">
                                            <xsl:call-template name="secondaryaccession"/>
                                        </xsl:if>
                                    </div>
                                    <xsl:if test="arraydesign">
                                        <xsl:for-each select="arraydesign">
                                            <div>
                                                <a href="${interface.application.link.aer_old.base.url}/result?queryFor=PhysicalArrayDesign&amp;aAccession={accession}">
                                                    <xsl:text>Array design </xsl:text>
                                                    <xsl:call-template name="highlight">
                                                        <xsl:with-param name="pText" select="concat(accession, ' - ', name)"/>
                                                        <xsl:with-param name="pFieldName" select="'array'"/>
                                                    </xsl:call-template>
                                                    <xsl:text> (old interface)</xsl:text>
                                                </a>
                                            </div>
                                        </xsl:for-each>
                                    </xsl:if>
                                    <div>
                                        <a href="${interface.application.link.aer_old.base.url}/details?class=MAGE.Experiment_protocols&amp;criteria=Experiment%3D{$vExpId}&amp;contextClass=MAGE.Protocol&amp;templateName=Protocol.vm">
                                            <xsl:text>Experimental protocols (old interface)</xsl:text>
                                        </a>
                                    </div>
                                    <div>
                                        <a href="${interface.application.link.aer_old.base.url}/result?queryFor=Experiment&amp;eAccession={$vAccession}">Experiment Page (old interface)</a>

                                    </div>
                                </td>
                            </tr>

                            <tr>
                                <td class="name"><div>Files</div></td>
                                <xsl:choose>
                                    <xsl:when test="$vFilesDoc/files/folder[@accession = $vAccession]/file[@kind='raw' or @kind='fgem' or @kind='adf' or @kind='idf' or @kind='sdrf' or @kind='biosamples']">

                                        <td class="attrs">
                                            <div>
                                                <table cellpadding="0" cellspacing="0" border="0">
                                                    <tbody>
                                                        <xsl:call-template name="data-files"/>
                                                        <xsl:call-template name="magetab-files"/>
                                                        <xsl:call-template name="image-files"/>
                                                        <xsl:call-template name="magetab-files-array"/>
                                                    </tbody>
                                                </table>
                                            </div>
                                            <div>
                                                <a href="{$basepath}/files/{$vAccession}">
                                                    <img src="{$basepath}/assets/images/silk_ftp.gif" width="16" height="16" alt=""/>
                                                    <xsl:text>Browse all available files</xsl:text>
                                                </a>
                                            </div>

                                        </td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td class="value">
                                            <div>
                                                <a href="{$basepath}/files/{$vAccession}">
                                                    <img src="{$basepath}/assets/images/silk_ftp.gif" width="16" height="16" alt=""/>
                                                    <xsl:text>Browse all available files</xsl:text>
                                                </a>
                                            </div>    
                                        </td>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </tr>
                            <xsl:variable name="vExpTypeAndDesign" select="experimenttype | experimentdesign"/>
                            <xsl:if test="$vExpTypeAndDesign">
                                <tr>

                                    <td class="name"><div>Experiment type<xsl:if test="count($vExpTypeAndDesign) > 1">s</xsl:if></div></td>
                                    <td class="value">
                                        <div>
                                            <xsl:call-template name="highlight">
                                                <xsl:with-param name="pText" select="string-join(experimenttype, ', ')"/>
                                                <xsl:with-param name="pFieldName" select="'exptype'"/>
                                            </xsl:call-template>
                                            <xsl:if test="count(experimenttype) > 0 and count(experimentdesign) > 0">, </xsl:if>
                                            <xsl:call-template name="highlight">
                                                <xsl:with-param name="pText" select="string-join(experimentdesign, ', ')"/>
                                                <xsl:with-param name="pFieldName" select="'expdesign'"/>
                                            </xsl:call-template>
                                        </div>
                                    </td>
                                </tr>
                            </xsl:if>

                            <xsl:if test="experimentalfactor/name">
                                <tr>
                                    <td class="name"><div>Experimental factors</div></td>
                                    <td class="attrs"><div>
                                        <table cellpadding="0" cellspacing="0" border="0">
                                            <thead>
                                                <tr>
                                                    <th class="attr_name">Factor name</th>
                                                    <th class="attr_value">Factor values</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <xsl:for-each select="experimentalfactor">
                                                    <tr>
                                                        <td class="attr_name">
                                                            <xsl:call-template name="highlight">
                                                                <xsl:with-param name="pText" select="name"/>
                                                                <xsl:with-param name="pFieldName" select="'ef'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td class="attr_value">
                                                            <xsl:call-template name="highlight">
                                                                <xsl:with-param name="pText" select="string-join(value, ', ')"/>
                                                                <xsl:with-param name="pFieldName" select="'efv'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                    </tr>
                                                </xsl:for-each>
                                            </tbody>
                                        </table></div>
                                   </td>
                                </tr>
                            </xsl:if>

                            <xsl:if test="sampleattribute/category">
                                <tr>
                                    <td class="name"><div>Sample attributes</div></td>
                                    <td class="attrs"><div>
                                        <table cellpadding="0" cellspacing="0" border="0">
                                            <thead>
                                                <tr>
                                                    <th class="attr_name">Attribute name</th>
                                                    <th class="attr_value">Attribute values</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <xsl:for-each select="sampleattribute">
                                                    <tr>
                                                        <td class="attr_name">
                                                            <xsl:call-template name="highlight">
                                                                <xsl:with-param name="pText" select="category"/>
                                                                <xsl:with-param name="pFieldName"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td class="attr_value">
                                                            <xsl:call-template name="highlight">
                                                                <xsl:with-param name="pText" select="string-join(value, ', ')"/>
                                                                <xsl:with-param name="pFieldName" select="'sa'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                    </tr>
                                                </xsl:for-each>
                                            </tbody>
                                        </table></div>
                                    </td>
                                </tr>
                            </xsl:if>
                        </table>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="bibliography">
        <div>
            <xsl:variable name="publication_title">
                <xsl:if test="string-length(title) > 0"><xsl:call-template name="highlight"><xsl:with-param name="pText" select="ae:trimTrailingDot(title)"/><xsl:with-param name="pFieldName"/></xsl:call-template>. </xsl:if>
                <xsl:if test="string-length(authors) > 0"><xsl:call-template name="highlight"><xsl:with-param name="pText" select="ae:trimTrailingDot(authors)"/><xsl:with-param name="pFieldName"/></xsl:call-template>. </xsl:if>
            </xsl:variable>
            <xsl:variable name="publication_link_title">
                <xsl:if test="string-length(publication) > 0">
                    <em>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="publication"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                    </em><xsl:text>&#160;</xsl:text></xsl:if>
                <xsl:if test="string-length(volume) > 0">
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="volume"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                    <xsl:if test="string-length(issue) > 0">
                        <xsl:text>(</xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="issue"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="string-length(pages) > 0">
                    <xsl:text>:</xsl:text>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="pages"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="string-length(year) > 0">
                    <xsl:text>&#160;(</xsl:text>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="publication"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="uri[starts-with(., 'http')]">
                    <xsl:copy-of select="$publication_title"/>
                    <a href="{uri}"><xsl:copy-of select="$publication_link_title"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$publication_title"/>
                    <xsl:copy-of select="$publication_link_title"/>
                    <xsl:if test="string-length(uri) > 0">
                        <xsl:text> (</xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="uri"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="accession">
                <xsl:if test="number(accession) > 0">
                    <xsl:text>, </xsl:text>
                    <a href="http://www.ncbi.nlm.nih.gov/pubmed/{accession}">
                        <xsl:text>PubMed </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="accession"/>
                            <xsl:with-param name="pFieldName" select="'pmid'"/>
                        </xsl:call-template>
                    </a>
                </xsl:if>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="secondaryaccession">
        <xsl:for-each select="secondaryaccession">
            <xsl:choose>
                <xsl:when test="string-length(.) = 0"/>
                <xsl:when test="substring(., 1, 3)='GSE' or substring(., 1, 3)='GDS'">
                    <a href="http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?acc={.}">
                        <xsl:text>GEO - </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="."/>
                            <xsl:with-param name="pFieldName" select="'accession'"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:when test="substring(., 1, 2)='E-' and substring(., 7, 1)='-'">
                    <a href="{$basepath}/experiments/{.}">
                        <xsl:text>ArrayExpress - </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="."/>
                            <xsl:with-param name="pFieldName" select="'accession'"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:when test="substring(., 1, 3)='SRP' or substring(., 1, 3)='ERP'">
                    <a href="http://www.ebi.ac.uk/ena/data/view/{.}">
                        <xsl:text>ENA - </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="."/>
                            <xsl:with-param name="pFieldName" select="'accession'"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="."/>
                        <xsl:with-param name="pFieldName" select="'accession'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() != last() and string-length(.) > 0">, </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="providers">
        <xsl:for-each select="provider[not(contact=following-sibling::provider/contact) and role!='data_coder']">
            <xsl:sort select="role='submitter'" order="descending"/>
            <xsl:sort select="lower-case(contact)"/>
            <xsl:choose>
                <xsl:when test="role='submitter' and string-length(email) > 0">
                    <a href="mailto:{email}">
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="concat(contact, ' &lt;', email, '&gt;')"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="contact"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position()!=last()">, </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="description">
        <xsl:param name="pText"/>
        <xsl:choose>
            <xsl:when test="contains($pText, '&lt;br&gt;')">
                <div class="desc">
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="substring-before($pText, '&lt;br&gt;')"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                </div>
                <xsl:call-template name="description">
                    <xsl:with-param name="pText" select="substring-after($pText,'&lt;br&gt;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <div class="desc">
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="$pText"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="miame-star">
        <xsl:param name="stars" />
        <xsl:param name="count" />
        <xsl:if test="$count &lt; 5">
            <xsl:choose>
                <xsl:when test="$count &lt; $stars">
                    <img src="{$basepath}/assets/images/miame_star.gif" width="14" height="13" alt="*"/>
                </xsl:when>
                <xsl:otherwise>
                    <img src="{$basepath}/assets/images/miame_nostar.gif" width="14" height="13" alt="."/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="miame-star">
                <xsl:with-param name="stars" select="$stars"/>
                <xsl:with-param name="count" select="$count + 1" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="miame-desc">
        <xsl:param name="pScores"/>
        <xsl:param name="pFilter"/>

        <xsl:if test="$pScores/reportersequencescore = $pFilter">
            <xsl:text>arrays</xsl:text>
            <xsl:if test="($pScores//protocolscore = $pFilter) or ($pScores/factorvaluescore = $pFilter) or ($pScores/derivedbioassaydatascore = $pFilter) or ($pScores/measuredbioassaydatascore = $pFilter)">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="$pScores/protocolscore = $pFilter">
            <xsl:text>protocols</xsl:text>
            <xsl:if test="($pScores/factorvaluescore = $pFilter) or ($pScores/derivedbioassaydatascore = $pFilter) or ($pScores/measuredbioassaydatascore = $pFilter)">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="$pScores/factorvaluescore = $pFilter">
            <xsl:text>factors</xsl:text>
            <xsl:if test="($pScores/derivedbioassaydatascore = $pFilter) or ($pScores/measuredbioassaydatascore = $pFilter)">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="$pScores/derivedbioassaydatascore = $pFilter">
            <xsl:text>processed data</xsl:text>
            <xsl:if test="$pScores/measuredbioassaydatascore = $pFilter">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="$pScores/measuredbioassaydatascore = $pFilter">
            <xsl:text>raw data</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="miame-score">
        <xsl:param name="pScores"/>

        <table class="miame-tbl" border="0" cellpadding="0" cellspacing="0">
            <thead>
                <tr>
                    <th>Array designs</th>
                    <th>Protocols</th>
                    <th>Factors</th>
                    <th>Processed data</th>
                    <th>Raw data</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        <xsl:call-template name="miame-tick">
                            <xsl:with-param name="pValue" select="$pScores/reportersequencescore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="miame-tick">
                            <xsl:with-param name="pValue" select="$pScores/protocolscore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="miame-tick">
                            <xsl:with-param name="pValue" select="$pScores/factorvaluescore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="miame-tick">
                            <xsl:with-param name="pValue" select="$pScores/derivedbioassaydatascore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="miame-tick">
                            <xsl:with-param name="pValue" select="$pScores/measuredbioassaydatascore"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template name="miame-tick">
        <xsl:param name="pValue"/>

        <xsl:choose>
            <xsl:when test="$pValue='1'">
                <img src="{$basepath}/assets/images/basic_tick.gif" width="16" height="16" alt="*"/>
            </xsl:when>
            <xsl:otherwise>
                <img src="{$basepath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="data-files">
        <xsl:variable name="vAccession" select="string(accession)"/>
        <xsl:variable name="vFiles" select="$vFilesDoc/files/folder[@accession = $vAccession]/file[@kind = 'raw' or @kind = 'fgem']"/>
        <xsl:if test="$vFiles">
            <tr>
                <td class="attr_name">Data Archives</td>
                <td class="attr_value">
                    <xsl:for-each select="$vFiles">
                        <xsl:sort select="@kind"/>
                        <xsl:sort select="lower-case(@name)"/>
                        <a href="{$vBaseUrl}/files/{$vAccession}/{@name}">
                            <xsl:value-of select="@name"/>
                        </a>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="magetab-files">
        <xsl:variable name="vAccession" select="string(accession)"/>
        <xsl:variable name="vFiles" select="$vFilesDoc/files/folder[@accession = $vAccession]/file[@extension = 'txt' and (@kind = 'idf' or @kind = 'sdrf')]"/>
        <xsl:if test="$vFiles">
            <xsl:for-each-group select="$vFiles" group-by="@kind">
                <xsl:sort select="@kind"/>
                <tr>
                    <td class="attr_name">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key() = 'idf'">Investigation Description</xsl:when>
                            <xsl:when test="current-grouping-key() = 'sdrf'">Sample and Data Relationship</xsl:when>
                        </xsl:choose>
                    </td>
                    <td class="attr_value">
                        <xsl:for-each select="current-group()">
                            <xsl:sort select="lower-case(@name)"/>
                            <a href="{$vBaseUrl}/files/{$vAccession}/{@name}">
                                <xsl:value-of select="@name"/>
                            </a>
                            <xsl:if test="position() != last()">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>

            </xsl:for-each-group>

        </xsl:if>
    </xsl:template>

    <xsl:template name="magetab-files-array">
        <xsl:variable name="vArrayAccession" select="distinct-values(arraydesign/accession)"/>
        <xsl:variable name="vFiles" select="$vFilesDoc/files/folder[@accession = $vArrayAccession]/file[@extension = 'txt' and @kind = 'adf']"/>
        <xsl:if test="$vFiles">
            <tr>
                <td class="attr_name">Array Design</td>
                <td class="attr_value">
                    <xsl:for-each select="$vFiles">
                        <xsl:sort select="@name"/>
                        <a href="{$vBaseUrl}/files/{../@accession}/{@name}"><xsl:value-of select="@name"/></a>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="image-files">
        <xsl:variable name="vAccession" select="string(accession)"/>
        <xsl:variable name="vFiles" select="$vFilesDoc/files/folder[@accession = $vAccession]/file[@kind = 'biosamples' and (@extension = 'png' or @extension = 'svg')]"/>
        <xsl:if test="$vFiles">
            <tr>
                <td class="attr_name">Experiment Design Images</td>
                <td class="attr_value">
                    <xsl:for-each select="$vFiles">
                        <xsl:sort select="lower-case(@extension)"/>
                        <a href="{$vBaseUrl}/files/{$vAccession}/{@name}"><xsl:value-of select="@name"/></a>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="data-files-main">
        <xsl:param name="pKind"/>
        <xsl:variable name="vAccession" select="string(accession)"/>
        <xsl:variable name="vFiles" select="$vFilesDoc/files/folder[@accession = $vAccession]/file[@kind = $pKind]"/>
        <xsl:variable name="vImg">
            <xsl:choose>
                <xsl:when test="$pKind = 'raw' and seqdatauri">
                    <img src="{$basepath}/assets/images/data_link_ena.gif" width="23" height="16" alt="Link to sequence data"/>
                </xsl:when>
                <xsl:when test="$pKind = 'raw' and contains($vFiles[1]/@dataformat, 'CEL')">
                    <img src="{$basepath}/assets/images/silk_data_save_affy.gif" width="16" height="16" alt="Click to download Affymetrix data"/>
                </xsl:when>
                <xsl:when test="$pKind = 'raw'">
                    <img src="{$basepath}/assets/images/silk_data_save.gif" width="16" height="16" alt="Click to download raw data"/>
                </xsl:when>
                <xsl:otherwise>
                    <img src="{$basepath}/assets/images/silk_data_save.gif" width="16" height="16" alt="Click to download processed data"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="vLinkUrl">
            <xsl:choose>
                <xsl:when test="$pKind = 'raw' and seqdatauri">
                    <xsl:value-of select="seqdatauri"/>
                </xsl:when>
                <xsl:when test="count($vFiles) > 1">
                    <xsl:value-of select="$basepath"/>
                    <xsl:text>/files/</xsl:text>
                    <xsl:value-of select="$vAccession"/>
                    <xsl:text>?kind=</xsl:text>
                    <xsl:value-of select="$pKind"/>
                </xsl:when>
                <xsl:when test="$vFiles">
                    <xsl:value-of select="$vBaseUrl"/>
                    <xsl:text>/files/</xsl:text>
                    <xsl:value-of select="$vAccession"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$vFiles/@name"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($vLinkUrl)>0"><a href="{$vLinkUrl}"><xsl:copy-of select="$vImg"/></a></xsl:when>
            <xsl:otherwise><img src="{$basepath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
