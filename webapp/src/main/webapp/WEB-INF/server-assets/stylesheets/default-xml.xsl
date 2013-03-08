<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                version="2.0">
    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:strip-space elements="*"/>
    
    <xsl:template match="*">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="* | text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="fn:normalize-space(.)"/>
    </xsl:template>
</xsl:stylesheet>
