<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('experiments-update.xml')"/>

    <xsl:template match="/experiments">
        <experiments total="{count(experiment)}">
            <xsl:apply-templates/>
        </experiments>
    </xsl:template>

    <xsl:template match="experiment">
        <experiment>
            <xsl:copy-of select="*|@*"/>
        </experiment>
    </xsl:template>
</xsl:stylesheet>
