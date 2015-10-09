<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2015 European Molecular Biology Laboratory
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

    <xsl:param name="host"/>
    <xsl:param name="context-path"/>


    <xsl:variable name="vBaseUrl"><xsl:value-of select="$host"/><xsl:value-of select="$context-path"/></xsl:variable>
    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:include href="ae-sort-files.xsl"/>

    <xsl:template name="root">
        <xsl:param name="pJson" as="xs:boolean"/>

        <xsl:variable name="vFilteredFiles" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredFiles)"/>

        <files api-version="3" api-revision="091015" version="1.0" revision="091015"
                   total-protocols="{$vTotal}">
            <xsl:call-template name="ae-sort-files">
                <xsl:with-param name="pFiles" select="$vFilteredFiles"/>
                <xsl:with-param name="pFrom"/>
                <xsl:with-param name="pTo"/>
                <xsl:with-param name="pSortBy" select="$vSortBy"/>
                <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
            </xsl:call-template>
        </files>
    </xsl:template>

    <xsl:template match="file">
        <file>
            <xsl:apply-templates select="*" mode="copy"/>
        </file>
    </xsl:template>

    <xsl:template match="source | user" mode="copy"/>

    <xsl:template match="*" mode="copy">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>