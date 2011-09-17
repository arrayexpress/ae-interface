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

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    <xsl:variable name="vAccession" select="upper-case($accession)"/>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>

    <xsl:template match="/experiments">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">
                    <xsl:value-of select="$vAccession"/><xsl:text> | ArrayExpress Archive | EBI</xsl:text>
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

        <xsl:variable name="vExperiment" select="aejava:getAcceleratorValueAsSequence('visible-experiments', $vAccession)"/>

        <xsl:choose>
            <xsl:when test="exists($vExperiment)">
                <xsl:choose>
                    <xsl:when test="$vExperiment/user/@id = '1'">
                        <xsl:call-template name="block-experiment">
                            <xsl:with-param name="pExperiment" select="$vExperiment"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="block-access-restricted"/>
                    </xsl:otherwise>
                </xsl:choose>
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
                            <img src="{$basepath}/assets/images/silk_lock.gif" alt="Access to the data is restricted" width="8" height="9"/>
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
                        <xsl:if test="releasedate">
                            <tr>
                                <td class="name"><div>Released on</div></td>
                                <td class="value"><div><xsl:value-of select="releasedate"/></div></td>
                            </tr>
                        </xsl:if>
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

                        <xsl:if test="minseqescores">
                            <tr>
                                <td class="name"><div>MINSEQE score</div></td>
                                <td class="value">
                                    <div>
                                        <xsl:call-template name="min-score">
                                            <xsl:with-param name="pScores" select="minseqescores"/>
                                        </xsl:call-template>
                                    </div>
                                </td>
                            </tr>
                        </xsl:if>

                        <xsl:if test="miamescores">
                            <tr>
                                <td class="name"><div>MIAME score</div></td>
                                <td class="value">
                                    <div>
                                        <xsl:call-template name="min-score">
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
                                    <div><a href="${interface.application.link.atlas.exp_query.url}{$vAccession}?ref=aebrowse">Query Gene Expression Atlas</a></div>
                                </xsl:if>
                                <div>
                                    <xsl:if test="secondaryaccession">
                                        <xsl:call-template name="secondaryaccession"/>
                                    </xsl:if>
                                </div>
                                <xsl:if test="arraydesign">
                                    <xsl:for-each select="arraydesign">
                                        <div>
                                            <a href="{$basepath}/arrays/{accession}">
                                                <xsl:text>Array design </xsl:text>
                                                <xsl:call-template name="highlight">
                                                    <xsl:with-param name="pText" select="concat(accession, ' - ', name)"/>
                                                    <xsl:with-param name="pFieldName" select="'array'"/>
                                                </xsl:call-template>
                                            </a>
                                        </div>
                                    </xsl:for-each>
                                </xsl:if>
                                <div>
                                    <a href="{$basepath}/protocols/browse.html?keywords=experiment%3A{$vAccession}">
                                        <xsl:text>Experimental protocols</xsl:text>
                                    </a>
                                </div>
                            </td>
                        </tr>

                        <tr>
                            <td class="name"><div>Files</div></td>
                            <xsl:choose>
                                <xsl:when test="$vFiles/file[@kind='raw' or @kind='fgem' or @kind='adf' or @kind='idf' or @kind='sdrf' or @kind='biosamples']">

                                    <td class="attrs">
                                        <div>
                                            <table cellpadding="0" cellspacing="0" border="0">
                                                <tbody>
                                                    <xsl:call-template name="data-files">
                                                        <xsl:with-param name="pFiles" select="$vFiles"/>
                                                    </xsl:call-template>
                                                    <xsl:call-template name="magetab-files">
                                                        <xsl:with-param name="pFiles" select="$vFiles"/>
                                                    </xsl:call-template>
                                                    <xsl:call-template name="image-files">
                                                        <xsl:with-param name="pFiles" select="$vFiles"/>
                                                    </xsl:call-template>
                                                    <xsl:call-template name="magetab-files-array">
                                                        <xsl:with-param name="pFiles" select="$vFiles"/>
                                                    </xsl:call-template>
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
            </div>
        </div>
    </xsl:template>
    <xsl:template match="bibliography">
        <div>
            <xsl:variable name="vTitle">
                <xsl:if test="string-length(title) > 0">
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="aejava:trimTrailingDot(title)"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="vPubInfo">
                <xsl:if test="string-length(authors) > 0">
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="aejava:trimTrailingDot(authors)"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                    <xsl:text>. </xsl:text>
                </xsl:if>
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
                        <xsl:with-param name="pText" select="year"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="doi">
                    <a href="http://dx.doi.org/{doi}"><xsl:copy-of select="$vTitle"/></a>
                    <xsl:text>. </xsl:text>
                    <xsl:copy-of select="$vPubInfo"/>
                </xsl:when>
                <xsl:when test="uri[starts-with(., 'http')]">
                    <a href="{uri}"><xsl:copy-of select="$vTitle"/></a>
                    <xsl:text>. </xsl:text>
                    <xsl:copy-of select="$vPubInfo"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$vTitle"/>
                    <xsl:text>. </xsl:text>
                    <xsl:copy-of select="$vPubInfo"/>
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
            <xsl:sort select="if (role='submitter') then '1' else '0'" order="descending"/>
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

    <xsl:template name="min-score">
        <xsl:param name="pScores"/>

        <table class="min-score-tbl" border="0" cellpadding="0" cellspacing="0">
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
                        <xsl:call-template name="min-score-tick">
                            <xsl:with-param name="pValue" select="$pScores/reportersequencescore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="min-score-tick">
                            <xsl:with-param name="pValue" select="$pScores/protocolscore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="min-score-tick">
                            <xsl:with-param name="pValue" select="$pScores/factorvaluescore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="min-score-tick">
                            <xsl:with-param name="pValue" select="$pScores/derivedbioassaydatascore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="min-score-tick">
                            <xsl:with-param name="pValue" select="$pScores/measuredbioassaydatascore"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template name="min-score-tick">
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
        <xsl:param name="pFiles"/>
        <xsl:variable name="vFiles" select="$pFiles/file[@kind = 'raw' or @kind = 'fgem']"/>
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
        <xsl:param name="pFiles"/>

        <xsl:variable name="vAccession" select="string(accession)"/>
        <xsl:variable name="vFiles" select="$pFiles/file[@extension = 'txt' and (@kind = 'idf' or @kind = 'sdrf')]"/>
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
                            <xsl:text> | </xsl:text>
                            <a href="{$vBaseUrl}/experiments/{$vAccession}/{replace(@name, '[^\.]+\.(.*)(idf|sdrf).+', '$1')}{current-grouping-key()}.html">
                                <xsl:text>view</xsl:text>
                            </a><img class="new" src="{$vBaseUrl}/assets/images/silk_new.gif" width="16" height="13" alt="new!"/>
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
        <xsl:param name="pFiles"/>
        <xsl:variable name="vArrayAccession" select="distinct-values(arraydesign/accession)"/>
        <xsl:variable name="vFiles" select="$pFiles/file[@extension = 'txt' and @kind = 'adf']"/>
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
        <xsl:param name="pFiles"/>
        <xsl:variable name="vFiles" select="$pFiles/file[@kind = 'biosamples' and (@extension = 'png' or @extension = 'svg')]"/>
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

    <xsl:template match="*" mode="highlight">
        <xsl:element name="{if (name() = 'text') then 'div' else name() }">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="highlight"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text()" mode="highlight">
        <xsl:call-template name="highlight">
            <xsl:with-param name="pText" select="."/>
            <xsl:with-param name="pFieldName"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="highlight">
        <xsl:param name="pText"/>
        <xsl:param name="pFieldName"/>
        <xsl:variable name="vText" select="$pText"/>
        <xsl:choose>
            <xsl:when test="string-length($vText)!=0">
                <xsl:value-of select="$vText"/>
            </xsl:when>
            <xsl:otherwise>&#160;</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
