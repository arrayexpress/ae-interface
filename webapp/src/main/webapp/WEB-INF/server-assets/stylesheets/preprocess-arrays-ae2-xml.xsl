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
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="fn ae html saxon"
                exclude-result-prefixes="fn ae html saxon"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/array_designs">
        <array_designs>
            <xsl:apply-templates select="array_design">
                <xsl:sort select="accession" order="ascending"/>
            </xsl:apply-templates>
        </array_designs>
    </xsl:template>

    <xsl:template match="array_design">
        <array_design>
            <xsl:attribute name="source" select="'ae2'"/>
            <xsl:attribute name="update" select="'true'"/>
            <xsl:copy-of select="*[name() != 'user' and name() != 'description']"/>
            <xsl:for-each select="description[string-length(text()) > 0]">
                <description>
                    <xsl:apply-templates mode="html" select="saxon:parse-html(fn:concat('&lt;body&gt;', fn:replace(fn:replace(fn:replace(fn:replace(text(), '&lt;', '&amp;lt;', 'i'), '&amp;lt;(/?)(a|ahref|b|br|i)([^a-z])', '&lt;$1$2$3', 'i'), '(^|[^&quot;])(https?|ftp)(:[/][/][a-zA-Z0-9_~\-\$&amp;\+,\./:;=\?@]+[a-zA-Z0-9_~\-\$&amp;\+,/:;=\?@])([^&quot;]|$)', '$1&lt;a href=&quot;$2$3&quot; target=&quot;_blank&quot;&gt;$2$3&lt;/a&gt;$4', 'i'), '&lt;ahref=', '&lt;a href=', 'i'), '&lt;/body&gt;'))" />
                </description>
            </xsl:for-each>
            <xsl:variable name="vExperimentsForArray" select="ae:getMappedValue('experiments-for-array', accession)"/>
            <xsl:for-each select="$vExperimentsForArray">
                <experiment><xsl:value-of select="."/></experiment>
            </xsl:for-each>
            <xsl:for-each select="user[string-length(text()) > 0]">
                <user id="{text()}"/>
            </xsl:for-each>
        </array_design>
    </xsl:template>

    <xsl:template match="html:html | html:body" mode="html">
        <xsl:apply-templates mode="html"/>
    </xsl:template>

    <xsl:template match="html:*" mode="html">
        <xsl:element name="{fn:local-name()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{fn:local-name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates mode="html"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>