<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2013 European Molecular Biology Laboratory
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
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae fn"
                exclude-result-prefixes="ae fn html"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/experiments">
        <experiments>
            <xsl:copy-of select="@*"/>

            <xsl:apply-templates select="experiment"/>
        </experiments>
    </xsl:template>

    <xsl:template match="experiment">
        <experiment>
            <xsl:copy-of select="@* | *[name() != 'similarto']"/>

            <xsl:variable name="vAccession" select="accession"/>
            <xsl:for-each select="ae:getMappedValue('similar-experiments-reversed', $vAccession)">
                <xsl:variable name="vInnerAccession" select="accession"/>
                <xsl:choose>
                    <!-- check if same experiment has ontology and pubmed score -->
                    <xsl:when test="similarOntologyExperiments/similarExperiment/accession[text() = $vAccession]
                            and similarPubMedExperiments/similarExperiment/accession[text() = $vAccession]">
                        <!-- use biggest score -->
                        <similarto accession="{$vInnerAccession}" distance="{
                            max((
                                similarOntologyExperiments/similarExperiment/accession[text() = $vAccession]/../calculatedDistance
                                , similarPubMedExperiments/similarExperiment/accession[text() = $vAccession]/../distance

                            ))
                        }"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <similarto accession="{$vInnerAccession}" distance="{
                                similarOntologyExperiments/similarExperiment/accession[text() = $vAccession]/../calculatedDistance
                                | similarPubMedExperiments/similarExperiment/accession[text() = $vAccession]/../distance
                        }"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </experiment>
    </xsl:template>

</xsl:stylesheet>