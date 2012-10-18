<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
    xmlns:html="http://www.w3.org/1999/xhtml"
    extension-element-prefixes="xs fn ae html"
    exclude-result-prefixes="xs fn ae html"
    version="2.0">
    
    <xsl:include href="ae-highlight.xsl"/>
    <xsl:include href="ae-date-functions.xsl"/>

    <xsl:template name="exp-description-section">
        <xsl:param name="pQueryId"/>
        <xsl:variable name="vDescription" select="description[string-length(text) > 0 and not(contains(text, '(Generated description)'))]"/>
        <xsl:if test="$vDescription">
            <tr>
                <td class="name"><div class="name">Description</div></td>
                <td class="value">
                    <div class="value">
                        <xsl:for-each select="$vDescription">
                            <xsl:sort select="id" data-type="number"/>
                            <xsl:apply-templates select="text" mode="highlight">
                                <xsl:with-param name="pQueryId" select="$pQueryId"/>
                            </xsl:apply-templates>
                        </xsl:for-each>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-similarity-section">
        <xsl:param name="vExpId"/>
        <xsl:param name="vBasePath"/>
        <xsl:param name="vSimilarExperiments"/>

        <xsl:if test="$vSimilarExperiments/similarOntologyExperiments/similarExperiment|$vSimilarExperiments/similarPubMedExperiments/similarExperiment">
            <tr>
                <td class="name"><div class="name">Similarity</div></td>
                <td class="attrs"><div class="attrs">
                    <table cellpadding="0" cellspacing="0" border="0">
                        <thead>
                            <tr>
                                <th class="owl">Ontology based:</th>
                                <th class="pubmed">PubMed based:</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="owl" id="{$vExpId}_owl">
                                    <xsl:for-each select="$vSimilarExperiments/similarOntologyExperiments/similarExperiment">
                                        <span class="simExp">
                                            <a href="{$vBasePath}/experiments/{accession}">
                                                <xsl:value-of select="accession"/>
                                            </a>
                                            <xsl:text> </xsl:text>
                                            <xsl:variable name="v2Experiment" select="ae:getAcceleratorValue('visible-experiments', accession)"/>
                                            <xsl:value-of select="$v2Experiment/name"/>
                                            <br/><br/>
                                        </span>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                    <a href="javascript:toggleMoreSimExp('{$vExpId}_owl')" class="more" id="{$vExpId}_owl_text"></a>
                                </td>
                                <td class="pubmed" id="{$vExpId}_pubmed">
                                    <xsl:for-each select="$vSimilarExperiments/similarPubMedExperiments/similarExperiment">
                                        <a href="{$vBasePath}/experiments/{accession}" class="simExp">
                                            <xsl:value-of select="accession"/>
                                        </a>
                                        <xsl:text> </xsl:text>
                                        <xsl:variable name="v2Experiment" select="ae:getAcceleratorValue('visible-experiments', accession)"/>
                                        <xsl:value-of select="$v2Experiment/name"/>
                                        <br/> <br/>
                                    </xsl:for-each>
                                    <a href="javascript:toggleMoreSimExp('{$vExpId}_pubmed')" class="more" id="{$vExpId}_pubmed_text"></a>
                                </td>
                            </tr>
                        </tbody>
                    </table></div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-similarity-debug-section">
        <xsl:param name="vExpId"/>
        <xsl:param name="vBasePath"/>
        <xsl:param name="vSimilarExperiments"/>
        <xsl:if test="$vSimilarExperiments/similarOntologyExperiments/similarExperiment|$vSimilarExperiments/similarPubMedExperiments/similarExperiment">
            <tr>
                <td class="name"><div class="name">Similarity</div></td>
                <td class="attrs"><div class="attrs">
                    <table cellpadding="0" cellspacing="0" border="0">
                        <thead>
                            <tr class="owl">
                                <td><b>Ontolgy terms used from this experiment: </b>
                                    <xsl:for-each select="$vSimilarExperiments/ontologyURIs/URI">
                                        <a href="{text()}" target="_blank">
                                            <xsl:value-of select="@term" />
                                        </a>
                                        <xsl:if test="position()!=last()">
                                            <xsl:text>, </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                </td>
                            </tr>
                            <tr>
                                <th class="owl">Ontology based:</th>
                                <th class="pubmed">PubMed based:</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="owl" id="{$vExpId}_owl">
                                    <xsl:for-each select="$vSimilarExperiments/similarOntologyExperiments/similarExperiment">
                                        <span class="simExp">
                                            <a href="{$vBasePath}/experiments/{accession}">
                                                <xsl:value-of select="accession"/>
                                            </a>
                                            <xsl:text>( term(s): </xsl:text>
                                            <xsl:for-each select="ontologyURIs/URI">
                                                <a href="{text()}" target="_blank">
                                                    <xsl:value-of select="@term" />
                                                </a>
                                                <xsl:if test="position()!=last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>) </xsl:text>
                                            <xsl:value-of select="numberOfMatchedURIs"/>
                                            <xsl:text>; </xsl:text>
                                            <xsl:value-of select="calculatedDistance"/>
                                            <br/>
                                        </span>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                    <a href="javascript:toggleMoreSimExp('{$vExpId}_owl')" class="more" id="{$vExpId}_owl_text"></a>
                                </td>
                                <td class="pubmed" id="{$vExpId}_pubmed">
                                    <xsl:for-each select="$vSimilarExperiments/similarPubMedExperiments/similarExperiment">
                                        <a href="{$vBasePath}/experiments/{accession}" class="simExp">
                                            <xsl:value-of select="accession"/>
                                            <xsl:text> (</xsl:text>
                                            <xsl:value-of select="distance"/>
                                            <xsl:text>)</xsl:text>
                                        </a>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                    <a href="javascript:toggleMoreSimExp('{$vExpId}_pubmed')" class="more" id="{$vExpId}_pubmed_text"></a>
                                </td>
                            </tr>
                        </tbody>
                    </table></div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-keywords-section">
        <xsl:param name="pQueryId"/>
        <xsl:variable name="vExpTypeAndDesign" select="experimenttype | experimentdesign"/>
        <xsl:if test="$vExpTypeAndDesign">
            <tr>
                
                <td class="name"><div class="name">Experiment type<xsl:if test="count($vExpTypeAndDesign) > 1">s</xsl:if></div></td>
                <td class="value">
                    <div class="value">
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                            <xsl:with-param name="pText" select="fn:string-join(experimenttype, ', ')"/>
                            <xsl:with-param name="pFieldName" select="'exptype'"/>
                        </xsl:call-template>
                        <xsl:if test="count(experimenttype) > 0 and count(experimentdesign) > 0">, </xsl:if>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                            <xsl:with-param name="pText" select="string-join(experimentdesign, ', ')"/>
                            <xsl:with-param name="pFieldName" select="'expdesign'"/>
                        </xsl:call-template>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="exp-contact-section">
        <xsl:param name="pQueryId"/>

        <xsl:variable name="vContacts" select="provider[ role != 'data_coder' ]"/>
        <xsl:if test="$vContacts">
            <tr>
                <td class="name">
                    <div class="name">Contact<xsl:if test="count($vContacts) > 1">s</xsl:if></div></td>
                <td class="value">
                    <div class="value">
                        <xsl:call-template name="exp-provider">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                            <xsl:with-param name="pContacts" select="$vContacts"/>
                        </xsl:call-template>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-citation-section">
        <xsl:param name="pQueryId"/>

        <xsl:if test="bibliography/accession | bibliography/title">
            <tr>
                <td class="name">
                    <div class="name">Citation<xsl:if test="count(bibliography) > 1">s</xsl:if></div>
                </td>
                <td class="value">
                    <div class="value">
                        <xsl:apply-templates select="bibliography">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>    
                        </xsl:apply-templates>
                    </div>
                </td>
            </tr>
        </xsl:if>        
    </xsl:template>

    <xsl:template name="exp-minseqe-section">
        <xsl:param name="pBasePath"/>

        <xsl:if test="minseqescores">
            <tr>
                <td class="name"><div class="name">MINSEQE</div></td>
                <td class="value">
                    <div class="value">
                        <xsl:call-template name="exp-score">
                            <xsl:with-param name="pBasePath" select="$pBasePath"/>
                            <xsl:with-param name="pScores" select="minseqescores"/>
                            <xsl:with-param name="pKind" select="'minseqe'"/>
                        </xsl:call-template>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-miame-section">
        <xsl:param name="pBasePath"/>
        
        <xsl:if test="miamescores">
            <tr>
                <td class="name"><div class="name">MIAME</div></td>
                <td class="value">
                    <div class="value">
                        <xsl:call-template name="exp-score">
                            <xsl:with-param name="pBasePath" select="$pBasePath"/>
                            <xsl:with-param name="pScores" select="miamescores"/>
                            <xsl:with-param name="pKind" select="'miame'"/>
                        </xsl:call-template>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-platforms-section">
        <xsl:param name="pQueryId"/>
        <xsl:param name="pBasePath"/>
        <xsl:if test="arraydesign">
            <tr>
                <td class="name"><div class="name">Platform<xsl:if test="fn:count(arraydesign) > 1">s</xsl:if> (<xsl:value-of select="fn:count(arraydesign)"/>)</div></td>
                <td class="value">
                    <div class="value">
                        <xsl:for-each select="arraydesign">
                            <a href="{$pBasePath}/arrays/{accession}">
                                <xsl:call-template name="highlight">
                                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                    <xsl:with-param name="pText" select="fn:concat(accession, ' - ', name)"/>
                                    <xsl:with-param name="pFieldName" select="'array'"/>
                                </xsl:call-template>
                            </a>
                            <xsl:if test="fn:position() != fn:last()"><br/></xsl:if>
                        </xsl:for-each>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
 
    <xsl:template name="exp-samples-section">
        <xsl:param name="pQueryString"/>
        <xsl:param name="pQueryId"/>
        <xsl:param name="pBasePath"/>

        <xsl:variable name="vQueryString" select="if ($pQueryString != '') then concat('?', $pQueryString) else ''"/>

        <xsl:if test="samples">
            <tr>
                <td class="name"><div class="name">Samples (<xsl:value-of select="samples"/>)</div></td>
                <td class="value">
                    <div class="value">
                        <a class="samples" href="{$pBasePath}/experiments/{accession}/samples.html{$vQueryString}">
                            <b><xsl:text>Click for detailed sample information and links to data</xsl:text></b>
                            <br/>
                            <xsl:variable name="vPossibleMatches">
                                <xsl:for-each select="experimentalfactor/name">
                                    <match text="{fn:lower-case(.)}">
                                        <xsl:call-template name="highlight">
                                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                            <xsl:with-param name="pText" select="."/>
                                            <xsl:with-param name="pFieldName" select="'ef'"/>
                                        </xsl:call-template>
                                    </match>
                                </xsl:for-each>
                                <xsl:for-each select="experimentalfactor/value">
                                    <match text="{fn:lower-case(.)}">
                                        <xsl:call-template name="highlight">
                                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                            <xsl:with-param name="pText" select="."/>
                                            <xsl:with-param name="pFieldName" select="'efv'"/>
                                        </xsl:call-template>
                                    </match>
                                </xsl:for-each>
                                <xsl:for-each select="sampleattribute/category | sampleattribute/value">
                                    <match text="{fn:lower-case(.)}">
                                        <xsl:call-template name="highlight">
                                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                            <xsl:with-param name="pText" select="."/>
                                            <xsl:with-param name="pFieldName" select="'sa'"/>
                                        </xsl:call-template>
                                    </match>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:variable name="vMatches" select="$vPossibleMatches/match[span]"/>
                            <xsl:if test="$vMatches">
                                <em><xsl:text>&#160;&#x2514;&#x2500;&#160;found inside: </xsl:text></em>
                                <xsl:for-each-group select="$vMatches[fn:position() &lt;= 20]" group-by="@text">
                                    <xsl:sort select="@text" order="ascending"/>
                                    
                                    <xsl:copy-of select="fn:current-group()[1]/node()"/>
                                    <xsl:if test="fn:position() != fn:last()">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                </xsl:for-each-group>
                                <xsl:if test="fn:count($vMatches) > 20">
                                    <xsl:text>, ...</xsl:text>
                                </xsl:if>
                            </xsl:if>
                        </a>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-experimental-factors-section">
        <xsl:param name="pQueryId"/>

        <xsl:if test="experimentalfactor/name">
            <tr>
                <td class="name"><div class="name">Experimental factors</div></td>
                <td class="attrs"><div class="attrs">
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
                                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                            <xsl:with-param name="pText" select="name"/>
                                            <xsl:with-param name="pFieldName" select="'ef'"/>
                                        </xsl:call-template>
                                    </td>
                                    <td class="attr_value">
                                        <xsl:call-template name="highlight">
                                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
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
    </xsl:template>

    <xsl:template name="exp-sample-attributes-section">
        <xsl:param name="pQueryId"/>

        <xsl:if test="sampleattribute/category">
            <tr>
                <td class="name"><div class="name">Sample attributes</div></td>
                <td class="attrs"><div class="attrs">
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
                                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                            <xsl:with-param name="pText" select="category"/>
                                            <xsl:with-param name="pFieldName"/>
                                        </xsl:call-template>
                                    </td>
                                    <td class="attr_value">
                                        <xsl:call-template name="highlight">
                                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
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
    </xsl:template>

    <xsl:template name="exp-protocols-section">
        <xsl:param name="pBasePath"/>
        
        <xsl:if test="protocol">
            <tr>
                <td class="name"><div class="name">Protocols (<xsl:value-of select="count(protocol)"/>)</div></td>
                <td class="value">
                    <div class="value">
                        <a href="{$pBasePath}/protocols/browse.html?keywords=experiment%3A{accession}">
                            <xsl:text>Click for all experimental protocols</xsl:text>
                        </a>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-files-section">
        <xsl:param name="pBasePath"/>
        <xsl:param name="pFiles"/>
        <tr>
            <td class="name"><div class="name">Files</div></td>
            <xsl:choose>
                <xsl:when test="$pFiles/file[@kind='raw' or @kind='fgem' or @kind='adf' or @kind='idf' or @kind='sdrf' or @kind='biosamples' or @kind='r-object']">
                    
                    <td class="attrs">
                        <div class="attrs">
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tbody>
                                    <xsl:call-template name="exp-data-files">
                                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                        <xsl:with-param name="pFiles" select="$pFiles"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="exp-magetab-files">
                                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                        <xsl:with-param name="pFiles" select="$pFiles"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="exp-image-files">
                                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                        <xsl:with-param name="pFiles" select="$pFiles"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="exp-magetab-files-array">
                                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                        <xsl:with-param name="pFiles" select="$pFiles"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="exp-misc-files">
                                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                        <xsl:with-param name="pFiles" select="$pFiles"/>
                                    </xsl:call-template>
                                </tbody>
                            </table>
                        </div>
                        <div class="attrs">
                            <a href="{$pBasePath}/files/{accession}">
                                <img src="{$pBasePath}/assets/images/silk_ftp.gif" width="16" height="16" alt=""/>
                                <xsl:text>Browse all available files</xsl:text>
                            </a>
                        </div>
                        
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <td class="value">
                        <div class="value">
                            <a href="{$pBasePath}/files/{accession}">
                                <img src="{$pBasePath}/assets/images/silk_ftp.gif" width="16" height="16" alt=""/>
                                <xsl:text>Browse all available files</xsl:text>
                            </a>
                        </div>
                    </td>
                </xsl:otherwise>
            </xsl:choose>
        </tr>
    </xsl:template>
    
    <xsl:template name="exp-links-section">
        <xsl:param name="pQueryId"/>
        <xsl:param name="pBasePath"/>

        <xsl:if test="true()">
            <tr>
                <td class="name"><div class="name">Links</div></td>
                <td class="value">
                    <div class="value">
                        <xsl:if test="@loadedinatlas">
                            <a href="${interface.application.link.atlas.exp_query.url}{accession}?ref=aebrowse">Gene Expression Atlas - <xsl:value-of select="accession"/></a>
                        </xsl:if>
                        <xsl:if test="secondaryaccession">
                            <xsl:if test="@loadedinatlas"><br/></xsl:if>
                            <xsl:call-template name="exp-secondaryaccession">
                                <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                <xsl:with-param name="pBasePath" select="$pBasePath"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="@loadedinatlas | secondaryaccession"><br/></xsl:if>
                        <a href="{$pBasePath}/experiments/{accession}/genomespace.html"><span>Send <xsl:value-of select="accession"/> data to</span> <img src="{$pBasePath}/assets/images/gs_logo_title_16.gif" width="120" height="16" alt="GenomeSpace"/></a>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-status-section">
        <xsl:variable name="vDates" select="submissiondate | lastupdatedate | releasedate"/>
        <xsl:if test="$vDates">
            <tr>
                <td class="name">
                    <div class="name">Status</div>
                </td>
                <td class="value">
                    <div class="value">
                        <xsl:for-each select="$vDates">
                            <xsl:sort select="fn:translate(text(),'-','')" data-type="number"/>
                            <xsl:sort select="fn:translate(fn:substring(fn:name(), 1, 1), 'slr', 'abc')"/>

                            <xsl:variable name="vLabel">
                                <xsl:if test="ae:isFutureDate(text())">will be </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="fn:name() = 'submissiondate'">submitted</xsl:when>
                                    <xsl:when test="fn:name() = 'lastupdatedate'">
                                        <xsl:if test="not(ae:isFutureDate(text()))">last </xsl:if>
                                        <xsl:text>updated</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>released</xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="fn:position() = 1">
                                    <xsl:value-of select="fn:upper-case(fn:substring($vLabel, 1, 1))"/>
                                    <xsl:value-of select="fn:substring($vLabel, 2)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>, </xsl:text>
                                    <xsl:value-of select="$vLabel"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> </xsl:text>
                            <xsl:variable name="vDate" select="ae:formatDate(text())"/>
                            <xsl:choose>
                                <xsl:when test="fn:matches($vDate, '\d')">on <xsl:value-of select="$vDate"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="fn:lower-case($vDate)"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
 
    <xsl:template name="exp-secondaryaccession">
        <xsl:param name="pQueryId"/>
        <xsl:param name="pBasePath"/>

        <xsl:for-each select="secondaryaccession">
            <xsl:choose>
                <xsl:when test="fn:string-length(.) = 0"/>
                <xsl:when test="fn:substring(., 1, 3)='GSE' or fn:substring(., 1, 3)='GDS'">
                    <a href="http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?acc={.}">
                        <xsl:text>GEO - </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                            <xsl:with-param name="pText" select="."/>
                            <xsl:with-param name="pFieldName" select="'accession'"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:when test="fn:substring(., 1, 2)='E-' and fn:substring(., 7, 1)='-'">
                    <a href="{$pBasePath}/experiments/{.}">
                        <xsl:text>ArrayExpress - </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                            <xsl:with-param name="pText" select="."/>
                            <xsl:with-param name="pFieldName" select="'accession'"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:when test="fn:substring(., 1, 3)='SRP' or fn:substring(., 1, 3)='ERP'">
                    <a href="http://www.ebi.ac.uk/ena/data/view/{.}">
                        <xsl:text>ENA - </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                            <xsl:with-param name="pText" select="."/>
                            <xsl:with-param name="pFieldName" select="'accession'"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:when test="fn:substring(., 1, 4)='EGAS'">
                    <a href="https://www.ebi.ac.uk/ega/studies/{.}">
                        <xsl:text>EGA - </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                            <xsl:with-param name="pText" select="."/>
                            <xsl:with-param name="pFieldName" select="'accession'"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pQueryId" select="$pQueryId"/>
                        <xsl:with-param name="pText" select="."/>
                        <xsl:with-param name="pFieldName" select="'accession'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="fn:position() != fn:last() and fn:string-length(.) > 0">, </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="exp-provider">
        <xsl:param name="pQueryId"/>
        <xsl:param name="pContacts"/>
        
        <xsl:for-each select="$pContacts[not(contact=following-sibling::node()/contact)]">
            <xsl:sort select="if (role = 'submitter') then 0 else 1" order="ascending"/>
            <xsl:sort select="fn:lower-case(contact)"/>
            <xsl:choose>
                <xsl:when test="fn:string-length(email) > 0">
                    <a href="mailto:{email}">
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                            <xsl:with-param name="pText" select="fn:concat(contact, ' &lt;', email, '&gt;')"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pQueryId" select="$pQueryId"/>
                        <xsl:with-param name="pText" select="contact"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="fn:position() != fn:last()">, </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="bibliography">
        <xsl:param name="pQueryId"/>
        
        <xsl:variable name="vTitle">
            <xsl:if test="string-length(title) > 0">
                <xsl:call-template name="highlight">
                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    <xsl:with-param name="pText" select="ae:trimTrailingDot(title)"/>
                    <xsl:with-param name="pFieldName"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="vPubInfo">
            <xsl:if test="string-length(authors) > 0">
                <xsl:call-template name="highlight">
                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    <xsl:with-param name="pText" select="ae:trimTrailingDot(authors)"/>
                    <xsl:with-param name="pFieldName"/>
                </xsl:call-template>
                <xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:if test="string-length(publication) > 0">
                <em>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pQueryId" select="$pQueryId"/>
                        <xsl:with-param name="pText" select="publication"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                </em><xsl:text>&#160;</xsl:text></xsl:if>
            <xsl:if test="string-length(volume) > 0">
                <xsl:call-template name="highlight">
                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    <xsl:with-param name="pText" select="volume"/>
                    <xsl:with-param name="pFieldName"/>
                </xsl:call-template>
                <xsl:if test="string-length(issue) > 0">
                    <xsl:text>(</xsl:text>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pQueryId" select="$pQueryId"/>
                        <xsl:with-param name="pText" select="issue"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:if test="string-length(pages) > 0">
                <xsl:text>:</xsl:text>
                <xsl:call-template name="highlight">
                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    <xsl:with-param name="pText" select="pages"/>
                    <xsl:with-param name="pFieldName"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="string-length(year) > 0">
                <xsl:text>&#160;(</xsl:text>
                <xsl:call-template name="highlight">
                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    <xsl:with-param name="pText" select="year"/>
                    <xsl:with-param name="pFieldName"/>
                </xsl:call-template>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </xsl:variable>

        <xsl:if test="string-length(title)">
            <xsl:choose>
                <xsl:when test="doi">
                    <a href="http://dx.doi.org/{doi}"><xsl:copy-of select="$vTitle"/></a>
                    <xsl:text>. </xsl:text>
                    <xsl:copy-of select="$vPubInfo"/>
                </xsl:when>
                <xsl:when test="starts-with(uri, 'http')">
                    <a href="{uri}"><xsl:copy-of select="$vTitle"/></a>
                    <xsl:text>. </xsl:text>
                    <xsl:copy-of select="$vPubInfo"/>
                </xsl:when>
                <xsl:when test="uri">
                    <xsl:copy-of select="$vTitle"/>
                    <xsl:text>. </xsl:text>
                    <xsl:copy-of select="$vPubInfo"/>
                    <xsl:text> (</xsl:text>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pQueryId" select="$pQueryId"/>
                        <xsl:with-param name="pText" select="uri"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:when test="accession">
                    <a href="http://ukpmc.ac.uk/abstract/MED/{accession}"><xsl:copy-of select="$vTitle"/></a>
                    <xsl:text>. </xsl:text>
                    <xsl:copy-of select="$vPubInfo"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$vTitle"/>
                    <xsl:text>. </xsl:text>
                    <xsl:copy-of select="$vPubInfo"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="(doi or uri or string-length(title) = 0) and accession">
            <xsl:if test="number(accession) > 0">
                <xsl:if test="string-length(title)">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <a href="http://ukpmc.ac.uk/abstract/MED/{accession}">
                    <xsl:text>UKPMC </xsl:text>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pQueryId" select="$pQueryId"/>
                        <xsl:with-param name="pText" select="accession"/>
                        <xsl:with-param name="pFieldName" select="'pmid'"/>
                    </xsl:call-template>
                </a>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="exp-score">
        <xsl:param name="pBasePath"/>
        <xsl:param name="pScores"/>
        <xsl:param name="pKind"/>
        
        <table class="min-score-tbl" border="0" cellpadding="0" cellspacing="0">
            <tbody>
                <tr>
                    <td>
                        <xsl:if test="$pKind = 'miame'">
                            <xsl:call-template name="exp-score-item">
                                <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                <xsl:with-param name="pValue" select="$pScores/reportersequencescore"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$pKind = 'minseqe'">
                            <xsl:call-template name="exp-score-item">
                                <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                <xsl:with-param name="pValue" select="$pScores/experimentdesignscore"/>
                            </xsl:call-template>
                        </xsl:if>
                    </td>
                    <td>
                        <xsl:call-template name="exp-score-item">
                            <xsl:with-param name="pBasePath" select="$pBasePath"/>
                            <xsl:with-param name="pValue" select="$pScores/protocolscore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="exp-score-item">
                            <xsl:with-param name="pBasePath" select="$pBasePath"/>
                            <xsl:with-param name="pValue" select="$pScores/factorvaluescore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="exp-score-item">
                            <xsl:with-param name="pBasePath" select="$pBasePath"/>
                            <xsl:with-param name="pValue" select="$pScores/derivedbioassaydatascore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="exp-score-item">
                            <xsl:with-param name="pBasePath" select="$pBasePath"/>
                            <xsl:with-param name="pValue" select="$pScores/measuredbioassaydatascore"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <xsl:if test="$pKind = 'miame'">
                        <td>Platforms</td>
                    </xsl:if>
                    <xsl:if test="$pKind = 'minseqe'">
                        <td>Exp.&#160;design</td>
                    </xsl:if>
                    <td>Protocols</td>
                    <td>Factors</td>
                    <td>Processed</td>
                    <xsl:if test="$pKind = 'miame'">
                        <td>Raw</td>
                    </xsl:if>
                    <xsl:if test="$pKind = 'minseqe'">
                        <td>Seq.&#160;reads</td>
                    </xsl:if>
                </tr>
            </tbody>
        </table>
    </xsl:template>
    
    <xsl:template name="exp-score-item">
        <xsl:param name="pBasePath"/>
        <xsl:param name="pValue"/>
        
        <xsl:choose>
            <xsl:when test="$pValue='1'">
                <img src="{$pBasePath}/assets/images/silk_asterisk.gif" width="16" height="16" alt="*"/>
            </xsl:when>
            <xsl:otherwise>
                <img src="{$pBasePath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="exp-data-files">
        <xsl:param name="pFiles"/>
        <xsl:param name="pBasePath"/>
        
        <xsl:variable name="vAccession" select="accession" as="xs:string"/>
        <xsl:variable name="vFiles" select="$pFiles/file[@kind = 'raw' or @kind = 'fgem']"/>
        
        <xsl:if test="$vFiles">
            <tr>
                <td class="attr_name">Data Archives</td>
                <td class="attr_value">
                    <xsl:for-each select="$vFiles">
                        <xsl:sort select="@kind"/>
                        <xsl:sort select="lower-case(@name)"/>
                        <a href="{$pBasePath}/files/{$vAccession}/{@name}">
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
    
    <xsl:template name="exp-magetab-files">
        <xsl:param name="pFiles"/>
        <xsl:param name="pBasePath"/>
        
        <xsl:variable name="vAccession" select="accession" as="xs:string"/>
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
                            <a href="{$pBasePath}/files/{$vAccession}/{@name}">
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
    
    <xsl:template name="exp-magetab-files-array">
        <xsl:param name="pFiles"/>
        <xsl:param name="pBasePath"/>
        
        <xsl:variable name="vArrayAccession" select="distinct-values(arraydesign/accession)"/>
        <xsl:variable name="vFiles" select="$pFiles/file[@extension = 'txt' and @kind = 'adf']"/>
        <xsl:if test="$vFiles">
            <tr>
                <td class="attr_name">Array Design</td>
                <td class="attr_value">
                    <xsl:for-each select="$vFiles">
                        <xsl:sort select="@name"/>
                        <a href="{$pBasePath}/files/{../@accession}/{@name}"><xsl:value-of select="@name"/></a>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="exp-image-files">
        <xsl:param name="pFiles"/>
        <xsl:param name="pBasePath"/>
        
        <xsl:variable name="vAccession" select="accession" as="xs:string"/>
        <xsl:variable name="vFiles" select="$pFiles/file[@kind = 'biosamples' and (@extension = 'png' or @extension = 'svg')]"/>
        <xsl:if test="$vFiles">
            <tr>
                <td class="attr_name">Experiment Design Images</td>
                <td class="attr_value">
                    <xsl:for-each select="$vFiles">
                        <xsl:sort select="lower-case(@extension)"/>
                        <a href="{$pBasePath}/files/{$vAccession}/{@name}"><xsl:value-of select="@name"/></a>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-misc-files">
        <xsl:param name="pFiles"/>
        <xsl:param name="pBasePath"/>

        <xsl:variable name="vAccession" select="accession" as="xs:string"/>
        <xsl:variable name="vFiles" select="$pFiles/file[@kind = 'r-object']"/>
        <xsl:if test="$vFiles">
            <tr>
                <td class="attr_name"><span class="tt" tt-data="R object containing annotated experiment data">R ExpressionSet</span></td>
                <td class="attr_value">
                    <xsl:for-each select="$vFiles">
                        <xsl:sort select="lower-case(@extension)"/>
                        <a href="{$pBasePath}/files/{$vAccession}/{@name}"><xsl:value-of select="@name"/></a>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-data-files-main">
        <xsl:param name="pFiles"/>
        <xsl:param name="pBasePath"/>
        
        <xsl:param name="pKind"/>
        <xsl:variable name="vAccession" select="accession" as="xs:string"/>
        <xsl:variable name="vFiles" select="$pFiles/file[@kind = $pKind]"/>
        <xsl:variable name="vImg">
            <xsl:choose>
                <xsl:when test="$pKind = 'raw' and seqdatauri">
                    <img src="{$pBasePath}/assets/images/data_link_ena.gif" width="23" height="16" alt="Link to sequence data"/>
                </xsl:when>
                <xsl:when test="$pKind = 'raw' and contains($vFiles[1]/@dataformat, 'CEL')">
                    <img src="{$pBasePath}/assets/images/silk_data_save_affy.gif" width="16" height="16" alt="Click to download Affymetrix data"/>
                </xsl:when>
                <xsl:when test="$pKind = 'raw'">
                    <img src="{$pBasePath}/assets/images/silk_data_save.gif" width="16" height="16" alt="Click to download raw data"/>
                </xsl:when>
                <xsl:otherwise>
                    <img src="{$pBasePath}/assets/images/silk_data_save.gif" width="16" height="16" alt="Click to download processed data"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="vLinkUrl">
            <xsl:choose>
                <xsl:when test="$pKind = 'raw' and seqdatauri">
                    <xsl:value-of select="seqdatauri"/>
                </xsl:when>
                <xsl:when test="count($vFiles) > 1">
                    <xsl:value-of select="$pBasePath"/>
                    <xsl:text>/files/</xsl:text>
                    <xsl:value-of select="$vAccession"/>
                    <xsl:text>?kind=</xsl:text>
                    <xsl:value-of select="$pKind"/>
                </xsl:when>
                <xsl:when test="$vFiles">
                    <xsl:value-of select="$pBasePath"/>
                    <xsl:text>/files/</xsl:text>
                    <xsl:value-of select="$vAccession"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$vFiles/@name"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($vLinkUrl)>0"><a href="{$vLinkUrl}"><xsl:copy-of select="$vImg"/></a></xsl:when>
            <xsl:otherwise><img src="{$pBasePath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>