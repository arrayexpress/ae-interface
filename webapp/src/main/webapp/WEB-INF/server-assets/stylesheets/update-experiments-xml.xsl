<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('experiments-update.xml')"/>
    <xsl:variable name="vUpdateSource" select="$vUpdate/experiments/experiment[1]/source"/>

    <xsl:template match="/experiments">
        <xsl:message>[INFO] Updating from [<xsl:value-of select="$vUpdateSource"/>]</xsl:message>
        <experiments total="{count(experiment)}">
            <xsl:apply-templates select="experiment[source != $vUpdateSource]"/>
            <xsl:apply-templates select="$vUpdate/experiments/experiment"/>
        </experiments>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:message>[INFO] Copying [<xsl:value-of select="accession"/>], source [<xsl:value-of select="source"/>]</xsl:message>
        <experiment>
            <xsl:copy-of select="*|@*"/>
        </experiment>
    </xsl:template>
</xsl:stylesheet>
