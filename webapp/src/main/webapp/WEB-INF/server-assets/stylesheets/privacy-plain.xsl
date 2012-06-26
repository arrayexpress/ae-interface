<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">

    <xsl:output method="text" encoding="UTF-8" indent="no"/>

    <xsl:param name="accession"/>

    <xsl:variable name="vAccession" select="upper-case($accession)"/>
    <xsl:variable name="vBatchMode" select="not($accession)"/>

    <xsl:template match="/experiments">
        <xsl:variable name="vExperiments" select="experiment[accession = $vAccession or $vBatchMode]"/>
        <xsl:for-each select="$vExperiments">
            <xsl:text>accession:</xsl:text>
            <xsl:value-of select="accession"/>
            <xsl:text> privacy:</xsl:text>
            <xsl:value-of select="if (user/@id = '1') then 'public' else 'private'"/>
            <xsl:text> releasedate:</xsl:text>
            <xsl:value-of select="releasedate"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template></xsl:stylesheet>