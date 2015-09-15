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
                extension-element-prefixes="xs fn ae search"
                exclude-result-prefixes="xs fn ae search"
                version="2.0">

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>

    <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'releasedate'"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'descending'"/>

    <xsl:param name="queryid"/>
    <xsl:param name="accession"/>
    <xsl:param name="userid"/>
    <xsl:param name="isreviewer"/>

    <xsl:param name="host"/>
    <xsl:param name="context-path"/>

    <xsl:variable name="vBaseUrl"><xsl:value-of select="$host"/><xsl:value-of select="$context-path"/></xsl:variable>

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">

        <xsl:variable name="vFilteredExperiments" select="if ($accession) then search:queryIndex('experiments', fn:concat('accession:', $accession, if ($userid) then fn:concat(' userid:(', $userid, ')') else ''))[accession = $accession] else search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" as="xs:integer" select="count($vFilteredExperiments)"/>

        <experiments version="3.0" revision="140109"
                     total="{$vTotal}"
                     total-samples="{sum($vFilteredExperiments/samples) cast as xs:integer}"
                     total-assays="{sum($vFilteredExperiments/assays) cast as xs:integer}">
            <xsl:call-template name="ae-sort-experiments">
                <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                <xsl:with-param name="pFrom"/>
                <xsl:with-param name="pTo"/>
                <xsl:with-param name="pSortBy" select="$vSortBy"/>
                <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
            </xsl:call-template>
        </experiments>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:variable name="vIsAnonymousReview" select="fn:not(user/@id = '1') and ($isreviewer = 'true') and source/@anonymousreview"/>
        <experiment>
            <xsl:apply-templates select="id" mode="copy"/>
            <xsl:apply-templates select="accession" mode="copy"/>
            <xsl:apply-templates select="secondaryaccession" mode="copy"/>
            <xsl:apply-templates select="name" mode="copy"/>
            <xsl:apply-templates select="releasedate | lastupdatedate | submissiondate" mode="copy"/>
            <xsl:apply-templates select="organism" mode="copy"/>
            <xsl:apply-templates select="experimenttype" mode="copy"/>
            <xsl:apply-templates select="experimentdesign" mode="copy"/>
            <xsl:apply-templates select="description" mode="copy"/>
            <xsl:if test="fn:not($vIsAnonymousReview)">
                <xsl:apply-templates select="provider" mode="copy"/>
                <xsl:apply-templates select="bibliography" mode="copy"/>
            </xsl:if>
            <xsl:apply-templates select="sampleattribute" mode="copy"/>
            <xsl:apply-templates select="experimentalfactor" mode="copy"/>
            <xsl:apply-templates select="arraydesign" mode="copy"/>
            <xsl:apply-templates select="protocol" mode="copy"/>
            <xsl:apply-templates select="bioassaydatagroup" mode="copy"/>
        </experiment>
    </xsl:template>

    <xsl:template match="source | user" mode="copy"/>

    <xsl:template match="sampleattribute" mode="copy">
        <samplecharacteristic>
            <xsl:apply-templates select="node()" mode="copy"/>
        </samplecharacteristic>
    </xsl:template>

    <xsl:template match="*" mode="copy">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>