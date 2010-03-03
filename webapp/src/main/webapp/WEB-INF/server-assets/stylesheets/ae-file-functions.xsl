<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/xslt"
                extension-element-prefixes="ae"
                exclude-result-prefixes="ae"
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
</xsl:stylesheet>