<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                extension-element-prefixes="search"
                exclude-result-prefixes="search"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:param name="queryid"/>

    <xsl:template match="/experiments">
        <xsl:variable name="vFilteredExperiments" select="search:queryIndex($queryid)"/>
        <experiments total="{count($vFilteredExperiments)}"
                     total-samples="{sum($vFilteredExperiments/samples)}"
                     total-assays="{sum($vFilteredExperiments/assays)}"/>
    </xsl:template>

</xsl:stylesheet>
