<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                extension-element-prefixes="search"
                exclude-result-prefixes="search"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:param name="queryid"/>

    <xsl:template match="/experiments">
        <xsl:variable name="vFilteredExperiments" select="search:queryIndex('experiments', $queryid)"/>
        <experiments total="{count($vFilteredExperiments)}"
                     total-samples="{sum($vFilteredExperiments/samples)}"
                     total-assays="{sum($vFilteredExperiments/assays)}"/>
    </xsl:template>

</xsl:stylesheet>
