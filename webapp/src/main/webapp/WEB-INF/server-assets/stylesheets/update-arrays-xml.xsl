<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                extension-element-prefixes="ae"
                exclude-result-prefixes="ae"
                version="2.0">

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-arrays.xml')"/>
    <xsl:variable name="vUpdateSource" select="$vUpdate/array_designs/array_design[1]/@source"/>

    <xsl:template match="/array_designs">
        <xsl:choose>
            <xsl:when test="string($vUpdateSource)">
                <xsl:message>[INFO] Updating from [<xsl:value-of select="$vUpdateSource"/>]</xsl:message>
                <xsl:variable name="vCombinedArrays" select="array_design[@source != $vUpdateSource] | $vUpdate/array_designs/array_design"/>
                <array_designs>
                    <xsl:for-each-group select="$vCombinedArrays" group-by="accession">
                        <xsl:variable name="vMigrated" select="exists(current-group()[@source='ae1']) and exists(current-group()[@source='ae2'])"/>
                        <xsl:if test="count(current-group()) > 2">
                            <xsl:message>[ERROR] Multiple entries within one source for array [<xsl:value-of select="current-grouping-key()"/>]</xsl:message>
                        </xsl:if>
                        <xsl:for-each select="current-group()">
                            <xsl:sort select="@source" order="ascending"/>
                            <array_design>
                                <xsl:attribute name="source" select="@source"/>
                                <xsl:attribute name="migrated" select="$vMigrated"/>
                                <xsl:attribute name="visible" select="@source = 'ae2' or not($vMigrated)"/>
                                <xsl:copy-of select="*"/>
                            </array_design>
                        </xsl:for-each>
                    </xsl:for-each-group>
                </array_designs>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>[WARN] Update source not defined, ignoring update</xsl:message>
                <xsl:copy-of select="/"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
