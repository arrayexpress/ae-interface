<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2014 European Molecular Biology Laboratory
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
    xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
    xmlns:html="http://www.w3.org/1999/xhtml"
    extension-element-prefixes="xs fn ae search html"
    exclude-result-prefixes="xs fn ae search html"
    version="2.0">

    <xsl:include href="ae-highlight.xsl"/>
    <xsl:include href="ae-file-functions.xsl"/>
    <xsl:include href="ae-date-functions.xsl"/>

    <xsl:template name="exp-organism-section">
        <xsl:param name="pQueryId"/>
        <xsl:if test="organism">
            <tr>
                <td class="name"><div>Organism</div></td>
                <td class="value">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                            <xsl:with-param name="pText" select="string-join(organism, ', ')"/>
                            <xsl:with-param name="pFieldName" select="'organism'"/>
                        </xsl:call-template>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-description-section">
        <xsl:param name="pQueryId"/>
        <xsl:variable name="vDescription" select="description[string-length(text) > 0 and not(contains(text, '(Generated description)'))]"/>
        <xsl:if test="$vDescription">
            <tr>
                <td class="name"><div>Description</div></td>
                <td class="value">
                    <xsl:for-each select="$vDescription">
                        <xsl:sort select="id" data-type="number"/>
                        <xsl:apply-templates select="text" mode="highlight">
                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <!-- TODO:
    <xsl:template name="exp-similarity-section">
        <xsl:param name="vExpId"/>
        <xsl:param name="vBasePath"/>
        <xsl:param name="vSimilarExperiments"/>

        <xsl:if test="$vSimilarExperiments/similarOntologyExperiments/similarExperiment|$vSimilarExperiments/similarPubMedExperiments/similarExperiment">
            <tr>
                <td class="name"><div>Similarity</div></td>
                <td class="value"><div>
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
                                            <xsl:variable name="v2Experiment" select="ae:getMappedValue('visible-experiments', accession)"/>
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
                                        <xsl:variable name="v2Experiment" select="ae:getMappedValue('visible-experiments', accession)"/>
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
                <td class="name"><div>Similarity</div></td>
                <td class="value"><div>
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
    -->

    <xsl:template name="exp-keywords-section">
        <xsl:param name="pQueryId"/>
        <xsl:variable name="vExpTypeAndDesign" select="experimenttype | experimentdesign"/>
        <xsl:if test="$vExpTypeAndDesign">
            <tr>
                <td class="name"><div>Experiment type<xsl:if test="count($vExpTypeAndDesign) > 1">s</xsl:if></div></td>
                <td class="value">
                    <div>
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
                    <div>Contact<xsl:if test="count($vContacts) > 1">s</xsl:if></div></td>
                <td class="value">
                    <div>
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
                    <div>Citation<xsl:if test="count(bibliography) > 1">s</xsl:if></div>
                </td>
                <td class="value">
                    <xsl:apply-templates select="bibliography">
                        <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    </xsl:apply-templates>
                </td>
            </tr>
        </xsl:if>        
    </xsl:template>

    <xsl:template name="exp-minseqe-section">

        <xsl:if test="minseqescores">
            <tr>
                <td class="name"><div>MINSEQE</div></td>
                <td class="value">
                    <div>
                        <xsl:call-template name="exp-score">
                            <xsl:with-param name="pScores" select="minseqescores"/>
                            <xsl:with-param name="pKind" select="'minseqe'"/>
                        </xsl:call-template>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-miame-section">

        <xsl:if test="miamescores">
            <tr>
                <td class="name"><div>MIAME</div></td>
                <td class="value">
                    <div>
                        <xsl:call-template name="exp-score">
                            <xsl:with-param name="pScores" select="miamescores"/>
                            <xsl:with-param name="pKind" select="'miame'"/>
                        </xsl:call-template>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-arrays-section">
        <xsl:param name="pQueryId"/>
        <xsl:param name="pBasePath"/>
        <xsl:param name="pAccession"/>

        <xsl:variable name="vArrays" select="search:queryIndex('arrays', fn:concat('visible:true experiment:', $pAccession, if ($userid) then fn:concat(' userid:(', $userid, ')') else ''))"/>
        <xsl:variable name="vArrayCount" select="fn:count($vArrays)"/>

        <xsl:if test="$vArrayCount > 0">
            <tr>
                <td class="name"><div>Array<xsl:if test="$vArrayCount > 1">s</xsl:if> (<xsl:value-of select="$vArrayCount"/>)</div></td>
                <td class="value">
                    <div>
                        <xsl:choose>
                            <xsl:when test="$vArrayCount &lt;= 3">
                                <xsl:variable name="vExpAccession" select="accession"/>
                                <xsl:for-each select="$vArrays">
                                    <xsl:sort select="substring(accession, 3, 4)" order="ascending"/>
                                    <xsl:sort select="substring(accession, 8)" order="ascending" data-type="number"/>

                                    <a href="{$pBasePath}/arrays/{accession}/?ref={$vExpAccession}">
                                        <xsl:call-template name="highlight">
                                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                            <xsl:with-param name="pText" select="fn:concat(accession, ' - ', name)"/>
                                            <xsl:with-param name="pFieldName" select="'array'"/>
                                        </xsl:call-template>
                                        <xsl:if test="not(user/@id = '1')">
                                            <span class="icon icon-functional" data-icon="L"/>
                                        </xsl:if>
                                    </a>
                                    <xsl:if test="fn:position() != fn:last()"><br/></xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <a href="{$pBasePath}/experiments/{accession}/arrays/">
                                    <xsl:text>Click for detailed array information</xsl:text>
                                </a>
                            </xsl:otherwise>

                        </xsl:choose>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
 
    <xsl:template name="exp-samples-section">
        <xsl:param name="pQueryString"/>
        <xsl:param name="pQueryId"/>
        <xsl:param name="pBasePath"/>
        <xsl:param name="pFiles"/>

        <xsl:if test="$pFiles/file[@extension = 'txt' and@kind = 'sdrf']">
            <tr>
                <td class="name"><div>Samples (<xsl:value-of select="samples"/>)</div></td>
                <td class="value">
                    <div>
                        <a class="samples" href="{$pBasePath}/experiments/{accession}/samples/{$pQueryString}">
                            <span class="sample-view"><xsl:text>Click for detailed sample information and links to data</xsl:text></span>
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
                <td class="name"><div>Experimental variables</div></td>
                <td class="value"><div>
                    <table cellpadding="0" cellspacing="0" border="0">
                        <thead>
                            <tr>
                                <th class="name">Name</th>
                                <th class="value">Values</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="experimentalfactor">
                                <tr>
                                    <td class="name">
                                        <xsl:call-template name="highlight">
                                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                            <xsl:with-param name="pText" select="name"/>
                                            <xsl:with-param name="pFieldName" select="'ef'"/>
                                        </xsl:call-template>
                                    </td>
                                    <td class="value">
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
                <td class="name"><div>Sample attributes</div></td>
                <td class="value"><div>
                    <table cellpadding="0" cellspacing="0" border="0">
                        <thead>
                            <tr>
                                <th class="name">Name</th>
                                <th class="value">Values</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="sampleattribute">
                                <tr>
                                    <td class="name">
                                        <xsl:call-template name="highlight">
                                            <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                            <xsl:with-param name="pText" select="category"/>
                                            <xsl:with-param name="pFieldName"/>
                                        </xsl:call-template>
                                    </td>
                                    <td class="value">
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
                <td class="name"><div>Protocols (<xsl:value-of select="count(protocol)"/>)</div></td>
                <td class="value">
                    <div>
                        <a href="{$pBasePath}/experiments/{accession}/protocols/">
                            <xsl:text>Click for detailed protocol information</xsl:text>
                        </a>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-files-section">
        <xsl:param name="pBasePath"/>
        <xsl:param name="pFiles"/>

        <xsl:if test="fn:exists($pFiles/file)">
            <tr>
                <td class="name"><div>Files</div></td>
                <td class="value">
                    <xsl:if test="fn:exists($pFiles/file[@kind > ''])"> <!-- TODO: iterate over kinds dynamically -->
                        <div>
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tbody>
                                    <xsl:call-template name="exp-magetab-files">
                                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                        <xsl:with-param name="pFiles" select="$pFiles"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="exp-data-files">
                                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                        <xsl:with-param name="pFiles" select="$pFiles"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="exp-image-files">
                                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                        <xsl:with-param name="pFiles" select="$pFiles"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="exp-magetab-files-array">
                                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="exp-misc-files">
                                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                                        <xsl:with-param name="pFiles" select="$pFiles"/>
                                    </xsl:call-template>
                                </tbody>
                            </table>
                        </div>
                    </xsl:if>
                    <div>
                        <a class="icon icon-awesome" data-icon="&#xf07b;" href="{$pBasePath}/experiments/{accession}/files/">
                            <xsl:text>Click to browse all available files</xsl:text>
                        </a>
                    </div>

                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="exp-links-section">
        <xsl:param name="pQueryId"/>
        <xsl:param name="pBasePath"/>

        <tr>
            <td class="name"><div>Links</div></td>
            <td class="value">
                <xsl:if test="@loadedinatlas">
                    <div>
                        <a href="${interface.application.link.atlas.exp_query.url}{accession}?ref=aebrowse">Expression Atlas - <xsl:value-of select="accession"/></a>
                    </div>
                </xsl:if>
                <xsl:if test="secondaryaccession">
                    <xsl:call-template name="exp-secondaryaccession">
                        <xsl:with-param name="pQueryId" select="$pQueryId"/>
                        <xsl:with-param name="pBasePath" select="$pBasePath"/>
                    </xsl:call-template>
                </xsl:if>
                <div>
                    <a href="{$pBasePath}/experiments/{accession}/genomespace.html"><span>Send <xsl:value-of select="accession"/> data to <u>GenomeSpace</u></span><img src="{$pBasePath}/assets/images/gs-logo-title-16.gif" width="120" height="16" title="GenomeSpace" alt="GenomeSpace"/></a>
                </div>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="exp-status-section">
        <xsl:param name="pIsGoogleBot" as="xs:boolean"/>
        <xsl:param name="pIsPrivate" as="xs:boolean"/>

        <xsl:variable name="vDates" select="submissiondate | lastupdatedate | releasedate"/>
        <xsl:variable name="vAccession" select="accession"/>
        <xsl:if test="$vDates">
            <tr>
                <xsl:choose>
                <xsl:when test="$pIsGoogleBot">
                    <td class="name">
                        <div>Released on</div>
                    </td>
                    <td class="value">
                        <div><xsl:value-of select="ae:formatDateGoogle(releasedate)"/></div>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                        <td class="name">
                            <div>Status</div>
                        </td>
                        <td class="value">
                            <div>
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
                                    <xsl:value-of select="ae:formatDate(text())"/>
                                    <xsl:if test="(fn:name() = 'releasedate') and $pIsPrivate"> (<a href="/fg/acext?acc={$vAccession}">change release date</a>&#160;<span class="new">new!</span>)</xsl:if>
                                </xsl:for-each>
                            </div>
                        </td>
                    </xsl:otherwise>
                </xsl:choose>
            </tr>
        </xsl:if>
    </xsl:template>
 
    <xsl:template name="exp-secondaryaccession">
        <xsl:param name="pQueryId"/>
        <xsl:param name="pBasePath"/>

        <div>
            <xsl:for-each select="secondaryaccession">
                <xsl:choose>
                    <xsl:when test="fn:string-length(.) = 0"/>
                    <xsl:when test="fn:matches(., '^(GSE|GDS)\d+$')">
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
                    <xsl:when test="fn:matches(., '^(DRP|ERP|SRP)\d+$')">
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
        </div>
    </xsl:template>
    
    <xsl:template name="exp-provider">
        <xsl:param name="pQueryId"/>
        <xsl:param name="pContacts"/>
        
        <xsl:for-each select="$pContacts[not(contact=following-sibling::node()/contact)]">
            <xsl:sort select="if (role = 'submitter') then 0 else 1" order="ascending"/>
            <xsl:sort select="fn:lower-case(contact)"/>
            <xsl:choose>
                <xsl:when test="fn:string-length(email) > 0">
                    <a href="mailto:{email}" class="icon icon-generic" data-icon="E">
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
            <xsl:if test="fn:string-length(title) > 0">
                <xsl:call-template name="highlight">
                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    <xsl:with-param name="pText" select="ae:trimTrailingDot(title)"/>
                    <xsl:with-param name="pFieldName"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="vPubInfo">
            <xsl:if test="fn:string-length(authors) > 0">
                <xsl:call-template name="highlight">
                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    <xsl:with-param name="pText" select="ae:trimTrailingDot(authors)"/>
                    <xsl:with-param name="pFieldName"/>
                </xsl:call-template>
                <xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:if test="fn:string-length(publication) > 0">
                <em>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pQueryId" select="$pQueryId"/>
                        <xsl:with-param name="pText" select="publication"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                </em><xsl:text>&#160;</xsl:text></xsl:if>
            <xsl:if test="fn:string-length(volume) > 0">
                <xsl:call-template name="highlight">
                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    <xsl:with-param name="pText" select="volume"/>
                    <xsl:with-param name="pFieldName"/>
                </xsl:call-template>
                <xsl:if test="fn:string-length(issue) > 0">
                    <xsl:text>(</xsl:text>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pQueryId" select="$pQueryId"/>
                        <xsl:with-param name="pText" select="issue"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:if test="fn:string-length(pages) > 0">
                <xsl:text>:</xsl:text>
                <xsl:call-template name="highlight">
                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    <xsl:with-param name="pText" select="pages"/>
                    <xsl:with-param name="pFieldName"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="fn:string-length(year) > 0">
                <xsl:text>&#160;(</xsl:text>
                <xsl:call-template name="highlight">
                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                    <xsl:with-param name="pText" select="year"/>
                    <xsl:with-param name="pFieldName"/>
                </xsl:call-template>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </xsl:variable>

        <xsl:if test="(fn:string-length(title) > 0) or ((doi or uri or fn:string-length(title) = 0) and accession)">
            <div>
                <xsl:if test="fn:string-length(title) > 0">
                    <xsl:choose>
                        <xsl:when test="doi">
                            <a href="http://dx.doi.org/{doi}"><xsl:copy-of select="$vTitle"/></a>
                            <xsl:text>. </xsl:text>
                            <xsl:copy-of select="$vPubInfo"/>
                        </xsl:when>
                        <xsl:when test="fn:starts-with(uri, 'http://')">
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
                            <a href="http://europepmc.org/abstract/MED/{accession}">
                                <xsl:copy-of select="$vTitle"/>
                            </a>
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
                <xsl:if test="(doi or uri or fn:string-length(title) = 0) and accession">
                    <xsl:if test="fn:number(accession) > 0">
                        <xsl:if test="fn:string-length(title)">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        <a href="http://europepmc.org/abstract/MED/{accession}">
                            <xsl:text>Europe PMC </xsl:text>
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                <xsl:with-param name="pText" select="accession"/>
                                <xsl:with-param name="pFieldName" select="'pmid'"/>
                            </xsl:call-template>
                        </a>
                    </xsl:if>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="exp-score">
        <xsl:param name="pScores"/>
        <xsl:param name="pKind"/>
        
        <table class="min-score-tbl" border="0" cellpadding="0" cellspacing="0">
            <tbody>
                <tr>
                    <td>
                        <xsl:if test="$pKind = 'miame'">
                            <xsl:call-template name="exp-score-item">
                                <xsl:with-param name="pValue" select="$pScores/reportersequencescore"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$pKind = 'minseqe'">
                            <xsl:call-template name="exp-score-item">
                                <xsl:with-param name="pValue" select="$pScores/experimentdesignscore"/>
                            </xsl:call-template>
                        </xsl:if>
                    </td>
                    <td>
                        <xsl:call-template name="exp-score-item">
                            <xsl:with-param name="pValue" select="$pScores/protocolscore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="exp-score-item">
                            <xsl:with-param name="pValue" select="$pScores/factorvaluescore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="exp-score-item">
                            <xsl:with-param name="pValue" select="$pScores/derivedbioassaydatascore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="exp-score-item">
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
                    <td>Variables</td>
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
        <xsl:param name="pValue"/>
        
        <xsl:choose>
            <xsl:when test="$pValue='1'">
                <i class="aw-icon-asterisk"/>
            </xsl:when>
            <xsl:otherwise>
                <i class="aw-icon-minus"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="exp-data-files">
        <xsl:param name="pFiles"/>
        <xsl:param name="pBasePath"/>
        
        <xsl:variable name="vAccession" select="accession" as="xs:string"/>
        <xsl:variable name="vFiles" select="$pFiles/file[(@kind = 'raw' or @kind = 'processed') and @hidden != 'true']"/>

        <xsl:if test="$vFiles">
            <xsl:for-each-group select="$vFiles" group-by="@kind">
                <xsl:sort select="@kind" order="descending"/>
                <xsl:variable name="vKindTitle" select="ae:getKindTitle(fn:current-grouping-key())"/>

                <tr>
                    <td class="name"><xsl:value-of select="fn:concat($vKindTitle, ' (', fn:count(fn:current-group()), ')')"/></td>
                    <td class="value">
                        <xsl:choose>
                            <xsl:when test="fn:count(fn:current-group()) > 10">
                                <a class="icon icon-awesome" data-icon="&#xf07b;" href="{$pBasePath}/experiments/{$vAccession}/files/{fn:current-grouping-key()}/">
                                    <xsl:text>Click to browse </xsl:text><xsl:value-of select="fn:lower-case($vKindTitle)"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="fn:current-group()">
                                    <xsl:sort select="@kind"/>
                                    <xsl:sort select="lower-case(@name)"/>
                                    <a href="{$pBasePath}/files/{$vAccession}/{@name}" title="Click to download {@name}" class="icon icon-functional" data-icon="=">
                                        <xsl:value-of select="@name"/>
                                    </a>
                                    <xsl:if test="position() != last()">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
            </xsl:for-each-group>
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
                <xsl:variable name="vKindTitle" select="ae:getKindTitle(fn:current-grouping-key())"/>

                <tr>
                    <td class="name">
                        <xsl:value-of select="$vKindTitle"/>
                    </td>
                    <td class="value">
                        <xsl:for-each select="current-group()">
                            <xsl:sort select="lower-case(@name)"/>
                            <a href="{$pBasePath}/files/{$vAccession}/{@name}" title="Click to download {@name}" class="icon icon-functional" data-icon="=">
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
        <xsl:param name="pBasePath"/>
        
        <xsl:variable name="vArrayAccession" select="fn:distinct-values(arraydesign/accession)"/>
        <xsl:variable name="vFiles">
            <xsl:for-each select="$vArrayAccession">
                <xsl:for-each select="ae:getMappedValue('ftp-folder', current())/file[@extension = 'txt' and @kind = 'adf']">
                    <file accession="{../@accession}" name="{@name}"/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="$vFiles/file">
            <tr>
                <td class="name">Array design<xsl:if test="count($vFiles/file) > 1">s</xsl:if></td>
                <td class="value">
                    <xsl:for-each select="$vFiles/file">
                        <xsl:sort select="@name"/>
                        <a href="{$pBasePath}/files/{@accession}/{@name}" title="Click to download {@name}" class="icon icon-functional" data-icon="="><xsl:value-of select="@name"/></a>
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
                <td class="name">Experiment design</td>
                <td class="value">
                    <xsl:for-each select="$vFiles">
                        <xsl:sort select="lower-case(@extension)"/>
                        <a href="{$pBasePath}/files/{$vAccession}/{@name}" title="Click to download {@name}" class="icon icon-functional" data-icon="="><xsl:value-of select="@name"/></a>
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
                <td class="name"><span class="tt" tt-data="R object containing annotated experiment data">R ExpressionSet</span></td>
                <td class="value">
                    <xsl:for-each select="$vFiles">
                        <xsl:sort select="lower-case(@extension)"/>
                        <a href="{$pBasePath}/files/{$vAccession}/{@name}" title="Click to download {@name}" class="icon icon-functional" data-icon="="><xsl:value-of select="@name"/></a>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="exp-stats-section">
        <xsl:if test="@views or @downloads">
            <tr>
                <td class="name"><div>Stats</div></td>
                <td class="value">
                    <div>
                        <xsl:if test="@views"><xsl:value-of select="@views"/> views<xsl:if test="@downloads">, </xsl:if></xsl:if>
                        <xsl:if test="@completedownloads"><xsl:value-of select="@completedownloads"/> downloads</xsl:if>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="detail-row">
        <xsl:param name="pName" as="xs:string" select="''"/>
        <xsl:param name="pQueryId" as="xs:string" select="''"/>
        <xsl:param name="pFieldName" as="xs:string" select="''"/>
        <xsl:param name="pString" as="xs:string" select="''"/>
        <xsl:param name="pNode"/>
        <xsl:choose>
            <xsl:when test="fn:string-length($pString) > 0">
                <xsl:call-template name="detail-section">
                    <xsl:with-param name="pName" select="$pName"/>
                    <xsl:with-param name="pContent">
                        <div>
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                <xsl:with-param name="pText" select="$pString"/>
                                <xsl:with-param name="pFieldName" select="$pFieldName"/>
                            </xsl:call-template>
                        </div>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pNode">
                <xsl:call-template name="detail-section">
                    <xsl:with-param name="pName" select="$pName"/>
                    <xsl:with-param name="pContent">
                        <xsl:for-each select="$pNode/node()">
                            <div>
                                <xsl:apply-templates select="." mode="highlight">
                                    <xsl:with-param name="pQueryId" select="$pQueryId"/>
                                    <xsl:with-param name="pFieldName" select="$pFieldName"/>
                                </xsl:apply-templates>
                            </div>
                        </xsl:for-each>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="detail-section">
        <xsl:param name="pName" as="xs:string"/>
        <xsl:param name="pContent"/>
        <xsl:if test="fn:not(fn:matches(fn:string-join($pContent//text(), ''), '^\s*$'))">
            <tr>
                <td class="name">
                    <div><xsl:value-of select="$pName"/></div>
                </td>
                <td class="value">
                    <xsl:copy-of select="$pContent"/>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>