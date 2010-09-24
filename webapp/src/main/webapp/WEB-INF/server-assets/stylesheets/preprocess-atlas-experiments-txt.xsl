<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:output method="text" indent="no" encoding="ISO-8859-1"/>

    <xsl:template match="atlasResponse">
        <xsl:apply-templates select="results/result/experimentInfo/accession"/>
    </xsl:template>

    <xsl:template match="accession">
        <xsl:value-of select="."/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
