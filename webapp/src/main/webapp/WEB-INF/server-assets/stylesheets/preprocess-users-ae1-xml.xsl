<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/users">
        <users>

            <xsl:apply-templates select="user">
                <xsl:sort select="id" order="descending" data-type="number"/>
            </xsl:apply-templates>
        </users>
    </xsl:template>

    <xsl:template match="user">
        <user>
            <xsl:attribute name="source">ae1</xsl:attribute>
            <xsl:copy-of select="*"/>
        </user>
    </xsl:template>

</xsl:stylesheet>