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
    <xsl:variable name="vData" select="search:queryIndex('files', fn:concat('accession:', $vAccession))"/>
    <xsl:variable name="vSampleFiles" select="$vData[@kind = 'sdrf' and @extension = 'txt']"/>

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <experiment>
            <accession><xsl:value-of select="$vAccession"/></accession>
            <xsl:for-each select="$vSampleFiles">
                <xsl:variable name="vTable" select="ae:tabularDocument($vAccession, @name, '- -header=1')/table"/>
                <xsl:variable name="vHeader" select="$vTable/header"/>
                <xsl:for-each select="$vTable/row">
                    <xsl:sort select="@seq" data-type="number" order="ascending"/>
                    <xsl:variable name="vRow" select="."/>
                    <sample>
                        <xsl:for-each select="$vHeader/col">
                            <xsl:variable name="vPos" select="fn:position()"/>
                            <xsl:variable name="vValue" select="$vRow/col[$vPos]"/>
                            <xsl:call-template name="sample-element">
                                <xsl:with-param name="pName" select="."/>
                                <xsl:with-param name="pValue" select="$vValue"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </sample>
                </xsl:for-each>
            </xsl:for-each>
        </experiment>
    </xsl:template>

    <xsl:template name="sample-element">
        <xsl:param name="pName"/>
        <xsl:param name="pValue"/>
        <xsl:choose>
            <xsl:when test="fn:lower-case($pName) = 'source name'">
                <source><xsl:value-of select="$pValue"/></source>
            </xsl:when>
            <xsl:when test="fn:lower-case($pName) = 'sample name'">
                <name><xsl:value-of select="$pValue"/></name>
            </xsl:when>
            <xsl:when test="fn:starts-with(fn:lower-case($pName), 'characteristics')">
                <characteristic>
                    <category><xsl:value-of select="fn:replace($pName, '^.+\[\s*(.+)\s*\]$', '$1')"/></category>
                    <value><xsl:value-of select="$pValue"/></value>
                    <xsl:if test="fn:starts-with(fn:lower-case($pName/following-sibling::col[1]), 'unit')">
                        <unit><xsl:value-of select="$pValue/following-sibling::col[1]"/></unit>
                    </xsl:if>
                </characteristic>
            </xsl:when>
            <xsl:when test="fn:matches(fn:lower-case($pName), '^factor\s{0,1}value')">
                <factor>
                    <name><xsl:value-of select="fn:replace($pName, '^.+\[\s*(.+)\s*\]$', '$1')"/></name>
                    <value><xsl:value-of select="$pValue"/></value>
                    <xsl:if test="fn:starts-with(fn:lower-case($pName/following-sibling::col[1]), 'unit')">
                        <unit><xsl:value-of select="$pValue/following-sibling::col[1]"/></unit>
                    </xsl:if>
                </factor>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>