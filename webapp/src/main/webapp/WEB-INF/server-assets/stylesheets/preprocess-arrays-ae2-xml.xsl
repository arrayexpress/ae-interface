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
                extension-element-prefixes="fn ae"
                exclude-result-prefixes="fn ae"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:include href="ae-parse-html-function.xsl"/>

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
                    <xsl:copy-of select="ae:parseHtml(.)"/>
                </description>
            </xsl:for-each>
            <xsl:for-each select="user[string-length(text()) > 0]">
                <user id="{text()}"/>
            </xsl:for-each>
        </array_design>
    </xsl:template>

</xsl:stylesheet>