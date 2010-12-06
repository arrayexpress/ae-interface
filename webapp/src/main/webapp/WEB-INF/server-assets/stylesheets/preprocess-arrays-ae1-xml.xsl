<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/array_designs">
        <array_designs>

            <xsl:apply-templates select="array_design">
                <xsl:sort select="accession" order="ascending"/>
            </xsl:apply-templates>
        </array_designs>
    </xsl:template>

    <xsl:template match="array_design">
        <array_design>
            <xsl:attribute name="source">ae1</xsl:attribute>
            <xsl:copy-of select="*[name() != 'id' or name() != 'user']"/>
            <user id="{user/text()}"/>
        </array_design>
    </xsl:template>

</xsl:stylesheet>