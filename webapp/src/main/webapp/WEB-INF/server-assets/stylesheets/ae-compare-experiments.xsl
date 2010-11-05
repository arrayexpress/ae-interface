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

        <xsl:variable name="vSortedFilteredExp1">
            <xsl:for-each select="$pExp1/*[not(name() = 'source')]">
                <xsl:sort select="name()" order="ascending"/>
                <xsl:copy-of select="ae:sort-elements-attributes(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="vSortedFilteredExp2">
            <xsl:for-each select="$pExp2/*[not(name() = 'source')]">
                <xsl:sort select="name()" order="ascending"/>
                <xsl:copy-of select="ae:sort-elements-attributes(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="saxon:deep-equal($vSortedFilteredExp1, $vSortedFilteredExp2, 'http://saxon.sf.net/collation?ignore-case=yes', 'Sw?')"/>
    </xsl:function>

    <xsl:function name="ae:sort-elements-attributes">
        <xsl:param name="pNode"/>
        <xsl:element name="{$pNode/name()}">
            <xsl:for-each select="$pNode/@*">
                <xsl:sort select="name()" order="ascending"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="$pNode/*">
                <xsl:sort select="name()" order="ascending"/>
                <xsl:copy-of select="ae:sort-elements-attributes(.)"/>
            </xsl:for-each>
            <xsl:value-of select="normalize-space(string-join($pNode/text(), ' '))"/>
        </xsl:element>
    </xsl:function>

</xsl:stylesheet>