<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/protocols">
        <array_designs>
            <xsl:apply-templates select="protocol">
                <xsl:sort select="accession" order="ascending"/>
            </xsl:apply-templates>
        </array_designs>
    </xsl:template>

    <xsl:template match="protocol">
        <array_design>
            <xsl:attribute name="source">ae2</xsl:attribute>
            <xsl:copy-of select="*[name() != 'user']"/>
            <xsl:for-each select="user[string-length(text()) != 0]">
                <user id="{text()}"/>
            </xsl:for-each>
        </array_design>
    </xsl:template>

</xsl:stylesheet>