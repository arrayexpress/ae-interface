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
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="fn ae html xs"
                exclude-result-prefixes="fn ae html xs"
                version="2.0">

    <xsl:param name="filename"/>

    <xsl:variable name="vContent" select="ae:htmlDocument(fn:concat('/WEB-INF/server-assets/pages/', $filename))"/>
    <xsl:variable name="vSubFolder" select="if (fn:contains($filename, '/')) then fn:concat(fn:substring-before($filename, '/'), '/') else ''"/>

    <xsl:include href="ae-html-page.xsl"/>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="exists($vContent/html:html)">
                <xsl:call-template name="ae-page">
                    <xsl:with-param name="pIsSearchVisible" select="fn:true()"/>
                    <xsl:with-param name="pSearchInputValue"/>
                    <xsl:with-param name="pTitleTrail" select="fn:substring-before($vContent//html:title, '&lt; ArrayExpress')"/>
                    <xsl:with-param name="pBreadcrumbTrail"/>
                    <xsl:with-param name="pExtraCSS"/>
                    <xsl:with-param name="pExtraJS"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="ae:httpStatus(404)"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="ae-content-section">
        <xsl:apply-templates select="$vContent//html:div[@id='content']/*" mode="html"/>
    </xsl:template>

    <!-- attributes, commments, processing instructions, text: copy as is -->
    <xsl:template match="@*|processing-instruction()|text()" mode="html">
        <xsl:choose>
            <xsl:when test="fn:local-name() = 'src' and fn:local-name(parent::node()) = 'img'">
                <xsl:attribute name="src" select="fn:concat($context-path, '/assets/images/', $vSubFolder, .)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- elements: create a new element with the same name, but no namespace -->
    <xsl:template match="*" mode="html">
        <xsl:element name="{fn:local-name()}">
            <xsl:apply-templates select="@*|node()" mode="html"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
