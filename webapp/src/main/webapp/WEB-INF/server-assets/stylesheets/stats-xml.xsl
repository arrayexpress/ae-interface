<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                extension-element-prefixes="xs search"
                exclude-result-prefixes="xs search"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:param name="queryid"/>

    <xsl:template match="/experiments">
        <xsl:variable name="vFilteredExperiments" select="search:queryIndex($queryid)"/>
        <experiments total="{count($vFilteredExperiments) cast as xs:integer}"
                     total-samples="{sum($vFilteredExperiments/samples) cast as xs:integer}"
                     total-assays="{sum($vFilteredExperiments/assays) cast as xs:integer}"/>
    </xsl:template>

</xsl:stylesheet>
