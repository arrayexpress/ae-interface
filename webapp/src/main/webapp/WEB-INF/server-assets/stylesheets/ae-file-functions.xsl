<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                extension-element-prefixes="ae aeext"
                exclude-result-prefixes="ae aeext"
                version="2.0">

    <xsl:function name="ae:dataformats">
        <xsl:param name="pBDG"/>
        <xsl:param name="pKind"/>
        <xsl:variable name="vIsDerived">
            <xsl:choose>
                <xsl:when test="$pKind = 'fgem'">
                    <xsl:text>1</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join(distinct-values($pBDG[isderived = $vIsDerived]/dataformat), ', ')"/>
    </xsl:function>

    <xsl:function name="ae:formatfilesize">
        <xsl:param name="pSize"/>
        <xsl:value-of select="aejava:formatFileSize($pSize)"/>
    </xsl:function>
</xsl:stylesheet>