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
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="search xs fn"
                exclude-result-prefixes="search xs fn html"
                version="2.0">
    
    <xsl:template match="*" mode="highlight">
        <xsl:param name="pQueryId" as="xs:string" select="''"/>
        <xsl:param name="pFieldName" as="xs:string" select="''"/>
        <xsl:element name="{if (fn:name() = 'text') then 'div' else name() }">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="highlight">
                <xsl:with-param name="pQueryId" select="$pQueryId"/>
                <xsl:with-param name="pFieldName" select="$pFieldName"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text()" mode="highlight">
        <xsl:param name="pQueryId" as="xs:string" select="''"/>
        <xsl:param name="pFieldName" as="xs:string" select="''"/>
        <xsl:call-template name="highlight">
            <xsl:with-param name="pQueryId" select="$pQueryId"/>
            <xsl:with-param name="pText" select="."/>
            <xsl:with-param name="pFieldName" select="$pFieldName"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="highlight">
        <xsl:param name="pQueryId" as="xs:string" select="''"/>
        <xsl:param name="pText" as="xs:string"/>
        <xsl:param name="pFieldName" as="xs:string" select="''"/>
        <xsl:choose>
            <xsl:when test="fn:string-length($pQueryId) = 0 and fn:string-length($pText) != 0">
                <xsl:value-of select="$pText"/>
            </xsl:when>
            <xsl:when test="fn:string-length($pText)!=0">
                <xsl:variable name="vHighlightedText" select="search:highlightQuery($pQueryId, $pFieldName, $pText)"/>
                <xsl:call-template name="format-highlighted-text">
                    <xsl:with-param name="pText" select="$vHighlightedText"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>&#160;</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="format-highlighted-text">
        <xsl:param name="pText" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="fn:contains($pText,'&#x00ab;') and fn:contains($pText,'&#x00bb;')">
                <xsl:call-template name="format-highlighted-text">
                    <xsl:with-param name="pText" select="fn:substring-before($pText,'&#x00ab;')"/>
                </xsl:call-template>
                <span class="text-hit"><xsl:value-of select="fn:substring-after(fn:substring-before($pText,'&#x00bb;'),'&#x00ab;')"/></span>
                <xsl:call-template name="format-highlighted-text">
                    <xsl:with-param name="pText" select="fn:substring-after($pText,'&#x00bb;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="format-highlighted-synonyms">
                    <xsl:with-param name="pText" select="$pText"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="format-highlighted-synonyms">
        <xsl:param name="pText" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="fn:contains($pText,'&#x2039;') and fn:contains($pText,'&#x203a;')">
                <xsl:call-template name="format-highlighted-synonyms">
                    <xsl:with-param name="pText" select="fn:substring-before($pText,'&#x2039;')"/>
                </xsl:call-template>
                <span class="text-syn"><xsl:value-of select="fn:substring-after(fn:substring-before($pText,'&#x203a;'),'&#x2039;')"/></span>
                <xsl:call-template name="format-highlighted-synonyms">
                    <xsl:with-param name="pText" select="fn:substring-after($pText,'&#x203a;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="format-highlighted-efo">
                    <xsl:with-param name="pText" select="$pText"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="format-highlighted-efo">
        <xsl:param name="pText" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="fn:contains($pText,'&#x2035;') and fn:contains($pText,'&#x2032;')">
                <xsl:call-template name="format-highlighted-efo">
                    <xsl:with-param name="pText" select="fn:substring-before($pText,'&#x2035;')"/>
                </xsl:call-template>
                <span class="text-efo"><xsl:value-of select="fn:substring-after(fn:substring-before($pText,'&#x2032;'),'&#x2035;')"/></span>
                <xsl:call-template name="format-highlighted-efo">
                    <xsl:with-param name="pText" select="fn:substring-after($pText,'&#x2032;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$pText"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>