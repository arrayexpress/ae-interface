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
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                extension-element-prefixes="ae fn"
                exclude-result-prefixes="ae fn"
                version="2.0">

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-experiments.xml')"/>
    <xsl:variable name="vUpdateSource" select="$vUpdate/experiments/experiment[1]/source/@id"/>

    <xsl:template match="/experiments">
        <xsl:choose>
            <xsl:when test="string($vUpdateSource)">
                <xsl:message>[INFO] Updating from [<xsl:value-of select="$vUpdateSource"/>]</xsl:message>
                <xsl:variable name="vCombinedExperiments" select="experiment[source/@id != $vUpdateSource] | $vUpdate/experiments/experiment"/>
                <experiments total="{count($vCombinedExperiments)}" retrieved="{$vUpdate/experiments/@retrieved}">
                    <xsl:attribute name="updated" select="fn:current-dateTime()"/>
                    <xsl:for-each-group select="$vCombinedExperiments" group-by="accession">
                        <xsl:variable name="vMigrated" select="count(current-group()) = 2"/>

                        <xsl:for-each select="current-group()">
                            <xsl:variable name="vHasData" select="rawdatafiles/@available = 'true' or processeddatafiles/@available = 'true' or fn:exists(seqdatauri)"/>
                            <xsl:variable name="vVisible" select="source/@id = 'ae2' "/>
                            <xsl:variable name="vAnonymousReview" select="fn:exists(anonymousreview)"/>

                            <experiment>
                                <xsl:copy-of select="*[name() != 'source']|@*"/>
                                <xsl:for-each select="species">
                                    <organism><xsl:value-of select="."/></organism>
                                </xsl:for-each>
                                <source id="{source/@id}" migrated="{$vMigrated}" visible="{$vVisible}" anonymousreview="{$vAnonymousReview}"/>
                            </experiment>
                        </xsl:for-each>

                    </xsl:for-each-group>
                </experiments>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>[WARN] Update source not defined, ignoring update</xsl:message>
                <xsl:copy-of select="/"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
