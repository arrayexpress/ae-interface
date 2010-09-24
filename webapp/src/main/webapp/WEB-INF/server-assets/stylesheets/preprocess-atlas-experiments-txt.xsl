<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                extension-element-prefixes="ae fn search"
                exclude-result-prefixes="ae fn search"
                version="1.0">

    <xsl:output method="text" indent="no" encoding="ISO-8859-1"/>

    <xsl:template match="//experimentInfo">
        <xsl:value-of select="accession"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
