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
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                extension-element-prefixes="ae fn search"
                exclude-result-prefixes="ae fn search"
                version="2.0">

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'releasedate'"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'descending'"/>

    <xsl:param name="queryid"/>

    <xsl:param name="host"/>
    <xsl:param name="context-path"/>

    <xsl:variable name="vBaseUrl"><xsl:value-of select="$host"/><xsl:value-of select="$context-path"/></xsl:variable>

    <xsl:output method="text" indent="no" encoding="UTF-8"/>

    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex($queryid)"/>

        <xsl:text>Accession</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Title</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Assays</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Species</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Release Date</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Processed Data</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Raw Data</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Present in Atlas</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>ArrayExpress URL</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="ae-sort-experiments">
            <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
            <xsl:with-param name="pFrom"/>
            <xsl:with-param name="pTo"/>
            <xsl:with-param name="pSortBy" select="$vSortBy"/>
            <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:value-of select="accession"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="assays"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="fn:string-join(organism, ', ')"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="releasedate" />
        <xsl:text>&#9;</xsl:text>
        <xsl:call-template name="list-data">
            <xsl:with-param name="pKind" select="'processed'"/>
            <xsl:with-param name="pAccession" select="accession"/>
        </xsl:call-template>
        <xsl:text>&#9;</xsl:text>
        <xsl:call-template name="list-data">
            <xsl:with-param name="pKind" select="'raw'"/>
            <xsl:with-param name="pAccession" select="accession"/>
        </xsl:call-template>
        <xsl:text>&#9;</xsl:text>
            <xsl:if test="@loadedinatlas">Yes</xsl:if>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="$vBaseUrl"/>/experiments/<xsl:value-of select="accession"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="list-data">
        <xsl:param name="pKind"/>
        <xsl:param name="pAccession"/>
        <xsl:variable name="vFilesOfAKind" select="ae:getMappedValue('ftp-folder', $pAccession)/file[@kind = $pKind]"/>
        <xsl:choose>
            <xsl:when test="count($vFilesOfAKind) > 1">
                <xsl:value-of select="$vBaseUrl"/>/files/<xsl:value-of select="$pAccession"/>?kind=<xsl:value-of select="$pKind"/>
            </xsl:when>
            <xsl:when test="count($vFilesOfAKind) = 1">
                <xsl:value-of select="$vBaseUrl"/>/files/<xsl:value-of select="$pAccession"/>/<xsl:value-of
                    select="$vFilesOfAKind/@name"/>
            </xsl:when>
            <xsl:otherwise><xsl:text>Data is not available</xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
