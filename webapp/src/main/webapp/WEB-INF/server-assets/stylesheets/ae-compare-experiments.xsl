<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/xslt"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="ae saxon"
                exclude-result-prefixes="ae saxon"
                version="2.0">

    <!-- checks if experiments contain equal set of elements/attributes (with a notable exception of source element) -->
    <xsl:function name="ae:are-experiments-identical">
        <xsl:param name="pExp1"/>
        <xsl:param name="pExp2"/>
  <!--
        <xsl:variable name="vSortedFilteredExp1">
            <xsl:for-each select="$pExp1/*[not(name() = 'source')]">
                <xsl:sort select="name()" order="ascending"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="vSortedFilteredExp2">
            <xsl:for-each select="$pExp2/*[not(name() = 'source')]">
                <xsl:sort select="name()" order="ascending"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="saxon:deep-equal($vSortedFilteredExp1, $vSortedFilteredExp2, 'http://saxon.sf.net/collation?ignore-case=yes', 'Sw?')"/>
  -->
        <xsl:value-of select="false()"/>
    </xsl:function>
<!--
    <xsl:function name="ae:are-nodes-identical">
        <xsl:param name="pNode1"/>
        <xsl:param name="pNode2"/>
        <xsl:variable name="vSortedNode1Attrs">
            <xsl:for-each select="$pNode1/@*">
                <xsl:sort select="name()" order="ascending"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="vSortedNode2Attrs">
            <xsl:for-each select="$pNode2/@*">
                <xsl:sort select="name()" order="ascending"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
        <xsl:when test="not(saxon:deep-equal())">
            <xsl:value-of select="false()"/>
        </xsl:when>
        <xsl:otherwise>
            
        </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
-->
</xsl:stylesheet>