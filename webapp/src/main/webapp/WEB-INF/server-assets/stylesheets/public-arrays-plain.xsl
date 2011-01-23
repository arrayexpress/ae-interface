<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                extension-element-prefixes="search"
                exclude-result-prefixes="search"
                version="2.0">

    <xsl:output method="text" indent="no" encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:variable name="vPublicArrays" select="search:queryIndex('arrays', 'source:ae2 userid:1')"/>

        <xsl:for-each select="$vPublicArrays">
            <xsl:sort select="substring(accession, 3, 4)" order="ascending"/>
            <xsl:sort select="substring(accession, 8)" order="ascending" data-type="number"/>

            <xsl:value-of select="position()"/>
            <xsl:text>&#9;</xsl:text>
            <xsl:value-of select="accession"/>
            <xsl:text>&#9;</xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
