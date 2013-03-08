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
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                extension-element-prefixes="ae"
                exclude-result-prefixes="ae"
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
            <!--
            <xsl:for-each select="user[string-length(text()) != 0]">
                <user id="{text()}"/>
            </xsl:for-each>
            -->
            <xsl:variable name="vExperimentsForProtocol" select="ae:getMappedValue('experiments-for-protocol', id)"/>
            <xsl:for-each select="$vExperimentsForProtocol">
                <experiment><xsl:value-of select="."/></experiment>
            </xsl:for-each>
            <xsl:for-each-group select="parameter" group-by="name">
                <xsl:sort select="name" order="ascending"/>
                <parameter>
                    <xsl:value-of select="current-grouping-key()"/>
                </parameter>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:template>

    <xsl:template match="user | parameter"/>
    <xsl:template match="*">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>