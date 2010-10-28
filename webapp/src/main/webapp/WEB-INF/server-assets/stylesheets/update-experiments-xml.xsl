<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('experiments-update.xml')"/>
    <xsl:variable name="vUpdateSource" select="$vUpdate/experiments/experiment[1]/source/@id"/>

    <xsl:template match="/experiments">
        <xsl:message>[INFO] Updating from [<xsl:value-of select="$vUpdateSource"/>]</xsl:message>
        <xsl:variable name="vCombinedExperiments" select="experiment[source/@id != $vUpdateSource] | $vUpdate/experiments/experiment"/>
        <experiments total="{count($vCombinedExperiments)}">
            <xsl:for-each-group select="$vCombinedExperiments" group-by="accession">
                <xsl:variable name="vMulti" select="count(current-group()) > 1"/>
                <xsl:for-each select="current-group()">
                    <xsl:message>[INFO] Copying [<xsl:value-of select="accession"/>], source [<xsl:value-of select="source/@id"/>], multi [<xsl:value-of select="$vMulti"/>]</xsl:message>
                    <experiment>
                        <xsl:copy-of select="*[name() != 'source']|@*"/>
                        <source id="{source/@id}" multi="{$vMulti}"/>
                    </experiment>
                </xsl:for-each>

            </xsl:for-each-group>
        </experiments>
    </xsl:template>

</xsl:stylesheet>
