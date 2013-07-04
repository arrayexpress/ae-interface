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
                extension-element-prefixes="fn"
                exclude-result-prefixes="fn"
                version="2.0">

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-news.xml')"/>

    <xsl:template match="/news">
        <xsl:element name="{name()}">
            <xsl:attribute name="updated" select="fn:current-dateTime()"/>
            <xsl:for-each select="$vUpdate/news/item">
                <!-- year -->
                <xsl:sort select="fn:substring-before(date, '-')" order="descending" data-type="number"/>
                <!-- month -->
                <xsl:sort select="fn:substring-before(substring-after(date, '-'), '-')" order="descending"
                          data-type="number"/>
                <!-- day -->
                <xsl:sort select="fn:substring-after(substring-after(date, '-'), '-')" order="descending"
                          data-type="number"/>
                <xsl:element name="{name()}">
                    <xsl:copy-of select="*"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
