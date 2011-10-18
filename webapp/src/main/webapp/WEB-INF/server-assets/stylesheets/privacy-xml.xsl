<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:param name="accession"/>

    <xsl:variable name="vAccession" select="upper-case($accession)"/>
    <xsl:variable name="vBatchMode" select="not($accession)"/>

    <xsl:template match="/experiments">
        <xsl:variable name="vExperiments" select="experiment[accession = $vAccession or $vBatchMode]"/>
        <experiments total="{count($vExperiments)}">
            <xsl:for-each select="$vExperiments">
                <experiment>
                    <accession><xsl:value-of select="accession"/></accession>
                    <privacy><xsl:value-of select="if (user/@id = '1') then 'public' else 'private'"></xsl:value-of></privacy>
                    <releasedate><xsl:value-of select="releasedate"/></releasedate>
                </experiment>
            </xsl:for-each>
        </experiments>
    </xsl:template>
</xsl:stylesheet>