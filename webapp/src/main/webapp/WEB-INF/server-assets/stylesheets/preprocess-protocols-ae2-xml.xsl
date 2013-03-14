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

    <xsl:template match="/protocols">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="*">
                <xsl:sort select="accession" order="ascending"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="protocol">
        <xsl:element name="{name()}">
            <user id="1"/>
            <xsl:apply-templates select="*"/>
            <!-- TODO: uncomment if we ever add protocol security
            <xsl:for-each select="user[string-length(text()) != 0]">
                <user id="{text()}"/>
            </xsl:for-each>
            -->
            <xsl:for-each-group select="parameter" group-by="name">
                <xsl:sort select="name" order="ascending"/>
                <parameter>
                    <xsl:value-of select="current-grouping-key()"/>
                </parameter>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:template>

    <xsl:template match="user | parameter"/>

    <xsl:template match="text">
        <xsl:if test="fn:string-length(text()) > 0">
            <text>
                <xsl:apply-templates mode="html" select="saxon:parse-html(fn:concat('&lt;body&gt;', fn:replace(fn:replace(fn:replace(fn:replace(text(), '&lt;', '&amp;lt;', 'i'), '&amp;lt;(/?)(a|ahref|b|br|i)([^a-z])', '&lt;$1$2$3', 'i'), '(^|[^&quot;])(https?|ftp)(:[/][/][a-zA-Z0-9_~\-\$&amp;\+,\./:;=\?@]+[a-zA-Z0-9_~\-\$&amp;\+,/:;=\?@])([^&quot;]|$)', '$1&lt;a href=&quot;$2$3&quot; target=&quot;_blank&quot;&gt;$2$3&lt;/a&gt;$4', 'i'), '&lt;ahref=', '&lt;a href=', 'i'), '&lt;/body&gt;'))" />
            </text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*">
        <xsl:copy-of select="."/>
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