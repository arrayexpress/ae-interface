<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/arrays_designs">
        <array_designs>
            <xsl:apply-templates select="arrays_design">
                <xsl:sort select="accession" order="ascending"/>
            </xsl:apply-templates>
        </array_designs>
    </xsl:template>

    <xsl:template match="arrays_design">
        <array_design>
            <xsl:attribute name="source">ae2</xsl:attribute>
            <xsl:copy-of select="*[name() != 'user']"/>
            <user id="{user/text()}"/>
        </array_design>
    </xsl:template>

</xsl:stylesheet>