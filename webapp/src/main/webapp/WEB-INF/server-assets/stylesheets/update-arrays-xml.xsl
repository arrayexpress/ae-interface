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
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                extension-element-prefixes="ae fn"
                exclude-result-prefixes="ae fn"
                version="2.0">

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-arrays.xml')"/>
    <xsl:variable name="vUpdateSource" select="$vUpdate/array_designs/array_design[1]/@source"/>

    <xsl:template match="/array_designs">
        <xsl:choose>
            <xsl:when test="string($vUpdateSource)">
                <xsl:message>[INFO] Updating from [<xsl:value-of select="$vUpdateSource"/>]</xsl:message>
                <xsl:variable name="vCombinedArrays" select="array_design | $vUpdate/array_designs/array_design"/>
                <array_designs>
                    <xsl:attribute name="updated" select="fn:current-dateTime()"/>
                    <xsl:for-each-group select="$vCombinedArrays" group-by="accession">
                        <xsl:variable name="vAe2Array" select="current-group()[@source='ae2']"/>
                        <xsl:if test="exists($vAe2Array)">
                            <xsl:variable name="vAe1Array" select="current-group()[@source='ae1']"/>
                            <xsl:variable name="vUpdateArray" select="current-group()[@update]"/>
                            <array_design>
                                <xsl:attribute name="source" select="'ae2'"/>
                                <xsl:attribute name="visible" select="'true'"/>
                                <xsl:choose>
                                    <xsl:when test="$vUpdateSource='ae1'">
                                        <xsl:attribute name="migrated" select="exists($vAe1Array)"/>
                                        <xsl:copy-of select="$vAe2Array/*[name() != 'user' and name() != 'legacy_id']"/>
                                        <xsl:copy-of select="$vAe2Array/user[not(@legacy)]"/>
                                        <xsl:if test="exists($vAe1Array)">
                                            <legacy_id><xsl:value-of select="$vAe1Array/id"/></legacy_id>
                                            <xsl:for-each select="$vAe1Array/user[@id!='1']">
                                                <user legacy="true" id="{@id}"/>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="$vAe2Array/@migrated"/>
                                        <xsl:copy-of select="$vUpdateArray/*"/>
                                        <xsl:for-each select="$vUpdateArray/species">
                                            <organism><xsl:value-of select="."/></organism>
                                        </xsl:for-each>
                                        <xsl:copy-of select="$vAe2Array[not(@update)]/legacy_id"/>
                                        <xsl:copy-of select="$vAe2Array[not(@update)]/user[@legacy]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </array_design>
                        </xsl:if>
                    </xsl:for-each-group>
                </array_designs>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>[WARN] Update source not defined, ignoring update</xsl:message>
                <xsl:copy-of select="/"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
