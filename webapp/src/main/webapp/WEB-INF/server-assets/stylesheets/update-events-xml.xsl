<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2014 European Molecular Biology Laboratory
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

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-events.xml')"/>

    <xsl:template match="/events">
        <events>
            <xsl:for-each select="event">
                <xsl:sort select="datetime" data-type="text" order="ascending"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <event>
                <id><xsl:value-of select="count(event)"/></id>
                <datetime><xsl:value-of select="current-dateTime()"/></datetime>
                <xsl:copy-of select="$vUpdate/event/*"/>
            </event>
        </events>
    </xsl:template>

</xsl:stylesheet>
