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
    extension-element-prefixes="ae search"
    exclude-result-prefixes="xs fn ae search"
    version="2.0">
    
    <xsl:param name="host"/>
    <xsl:param name="context-path"/>
    <xsl:param name="accession"/>
    
    <xsl:variable name="vBaseUrl"><xsl:value-of select="$host"/><xsl:value-of select="$context-path"/></xsl:variable>
    <xsl:variable name="vAccession" select="fn:upper-case($accession)"/>
    <!--
    <xsl:variable name="vData" select="search:queryIndex('files', fn:concat('accession:', $vAccession))"/>
    <xsl:variable name="vSampleFiles" select="$vData[@kind = 'sdrf' and @extension = 'txt']"/>
    -->
    <xsl:variable name="vSampleFiles">file</xsl:variable>
    <xsl:variable name="vTable" select="/"/>
    
    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <experiment>
            <accession><xsl:value-of select="$vAccession"/></accession>
            <xsl:for-each select="$vSampleFiles">
                <!--
                <xsl:variable name="vTable" select="ae:tabularDocument($vAccession, @name, '- -header=1')/table"/>
                -->
                <xsl:variable name="vTable" select="$vTable/table"/>
                <xsl:variable name="vHeader" select="$vTable/header"/>
                <xsl:for-each select="$vTable/row">
                    <xsl:sort select="@seq" data-type="number" order="ascending"/>
                    <xsl:variable name="vRow" select="."/>
                    <sample>
                        <xsl:for-each select="$vHeader/col">
                            <xsl:call-template name="sample-element">
                                <xsl:with-param name="pName" select="text()"/>
                                <xsl:with-param name="pValue" select="$vRow/col[fn:position()]/text()"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </sample>
                </xsl:for-each>
            </xsl:for-each>
        </experiment>
    </xsl:template>

    <xsl:template name="sample-element">
        <xsl:param name="pName" as="xs:string"/>
        <xsl:param name="pValue" as="xs:string"/>
        <xsl:variable name="vElementName">
        <xsl:choose>
            <xsl:when test="$pName = 'source name'">source-name</xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
        </xsl:variable>
        <xsl:if test="fn:string-length($vElementName) > 0">
            <xsl:element name="{$vElementName}">
                <xsl:value-of select="$pValue"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>