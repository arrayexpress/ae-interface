<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/xslt"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="ae saxon"
                exclude-result-prefixes="ae saxon"
                version="2.0">

    <!-- saxon:deep-equal(
            saxon:sort(
                    current-group()[1]/*[name() != 'source'], saxon:expression('name()')
                )
            , saxon:sort(
                    current-group()[2]/*[name() != 'source'], saxon:expression('name()')
                )
            , 'http://saxon.sf.net/collation?ignore-case=yes'
            , 'Sw?'
        )
    -->
    <xsl:function name="ae:are-experiments-identical">
        <xsl:param name="pExp1"/>
        <xsl:param name="pExp2"/>
        <xsl:variable name="vResult">
            <!-- ok, that works in principle
            <xsl:for-each select="saxon:sort($pExp1/*, saxon:expression('name()'))">
                <xsl:message>Exp 1 elt [<xsl:value-of select="name()"/>]</xsl:message>
            </xsl:for-each>
            <xsl:for-each select="saxon:sort($pExp2/*, saxon:expression('name()'))">
                <xsl:message>Exp 2 elt [<xsl:value-of select="name()"/>]</xsl:message>
            </xsl:for-each>
            -->
           <xsl:value-of select="true()"/>
        </xsl:variable>
        <xsl:value-of select="$vResult"/>
    </xsl:function>

</xsl:stylesheet>