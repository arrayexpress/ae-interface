<?xml version="1.0" encoding="UTF-8"?>
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
