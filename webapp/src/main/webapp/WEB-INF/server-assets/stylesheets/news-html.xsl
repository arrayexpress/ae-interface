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

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-date-functions.xsl"/>

    <xsl:template match="/">
        <xsl:call-template name="ae-page">
            <xsl:with-param name="pIsSearchVisible" select="fn:true()"/>
            <xsl:with-param name="pSearchInputValue"/>
            <xsl:with-param name="pTitleTrail">News</xsl:with-param>
            <xsl:with-param name="pBreadcrumbTrail"/>
            <xsl:with-param name="pExtraCSS"/>
            <xsl:with-param name="pExtraJS"/>
        </xsl:call-template>

    </xsl:template>

    <xsl:template name="ae-content-section">
        <section class="grid_24">
            <h2>ArrayExpress News</h2>
            <xsl:for-each select="doc('news.xml')/news/item">
                <h3><a id="{fn:position()}"><xsl:value-of select="title"/></a></h3>
                <p>
                    <i><xsl:value-of select="ae:formatDateGoogle(date)"/></i><br/>
                    <xsl:choose>
                        <xsl:when test="fn:string-length(text) > 0"><xsl:copy-of select="text/node()"/></xsl:when>
                        <xsl:otherwise><xsl:copy-of select="summary/node()"/></xsl:otherwise>
                    </xsl:choose>
                </p>
            </xsl:for-each>
        </section>
    </xsl:template>

</xsl:stylesheet>