<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/protocols">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="*">
                <xsl:sort select="accession" order="ascending"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="protocol">
        <xsl:element name="{name()}">
            <xsl:attribute name="source">ae2</xsl:attribute>
            <xsl:copy-of select="*[name() != 'user']"/>
            <!--
            <xsl:for-each select="user[string-length(text()) != 0]">
                <user id="{text()}"/>
            </xsl:for-each>
            -->
            <user id="1"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>