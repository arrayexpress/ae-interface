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
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae search html"
                exclude-result-prefixes="ae search html"
                version="2.0">

    <xsl:param name="queryid"/>
    <xsl:param name="accession"/>
    <xsl:param name="source"/>

    <xsl:variable name="vAccession" select="upper-case($accession)"/>


    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:include href="ae-compare-experiments.xsl"/>

    <xsl:template match="/experiments">
        <xsl:variable name="vExperiment" select="experiment[accession = $vAccession]"/>
        <xsl:variable name="vActiveExperiment" select="search:queryIndex($queryid)"/>
        <experiments>
            <xsl:choose>
                <xsl:when test="count($vExperiment) > 1">
                    <xsl:call-template name="ae:copy-and-diff-node">
                        <xsl:with-param name="pNode" select="ae:sort-elements-attributes($vActiveExperiment)"/>
                        <xsl:with-param name="pNodeDiffAgainst" select="ae:sort-elements-attributes($vExperiment[source/@id != $source])"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$vExperiment"/>
                </xsl:otherwise>
            </xsl:choose>
        </experiments>
    </xsl:template>

</xsl:stylesheet>
