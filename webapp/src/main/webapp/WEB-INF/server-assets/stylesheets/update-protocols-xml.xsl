<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-protocols.xml')"/>

    <xsl:template match="/protocols">
        <xsl:element name="{name()}">
            <xsl:for-each select="$vUpdate/protocols/protocol">
                <xsl:element name="{name()}">
                    <xsl:copy-of select="*"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
