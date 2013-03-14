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
                exclude-result-prefixes="xs ae fn"
                version="2.0">

    <xsl:function name="ae:getKindTitle" as="xs:string">
        <xsl:param name="pKind" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="$pKind = 'raw'">
                <xsl:text>Raw data</xsl:text>
            </xsl:when>
            <xsl:when test="$pKind = 'processed'">
                <xsl:text>Processed data</xsl:text>
            </xsl:when>
            <xsl:when test="$pKind = 'idf'">
                <xsl:text>Investigation description</xsl:text>
            </xsl:when>
            <xsl:when test="$pKind = 'sdrf'">
                <xsl:text>Sample and data relationship</xsl:text>
            </xsl:when>
            <xsl:when test="$pKind = 'adf'">
                <xsl:text>Array design</xsl:text>
            </xsl:when>
            <xsl:when test="$pKind != ''">
                <xsl:value-of select="fn:concat(fn:upper-case(fn:substring($pKind, 1, 1)), fn:substring($pKind, 2))"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>