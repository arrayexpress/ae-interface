<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/xslt"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="ae saxon"
                exclude-result-prefixes="ae saxon"
                version="2.0">

    <xsl:include href="ae-compare-experiments.xsl"/>

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-arrays.xml')"/>
    <xsl:variable name="vUpdateSource" select="$vUpdate/array_designs/array_design[1]/@source"/>

    <xsl:template match="/array_designs">
        <xsl:message>[INFO] Updating from [<xsl:value-of select="$vUpdateSource"/>]</xsl:message>
        <xsl:variable name="vCombinedArrays" select="array_design[@source != $vUpdateSource] | $vUpdate/array_designs/array_design"/>
        <array_designs>
            <xsl:for-each select="$vCombinedArrays">
                <xsl:if test="@source = 'ae1'">
                    <xsl:message>[INFO] Copying [<xsl:value-of select="accession"/>], source [<xsl:value-of select="@source"/>]</xsl:message>
                    <xsl:copy-of select="."/>
                </xsl:if>
                <xsl:if test="@source = 'ae2'">
                    <xsl:message>[INFO] Skipping [<xsl:value-of select="accession"/>], source [<xsl:value-of select="@source"/>]</xsl:message>
                </xsl:if>
            </xsl:for-each>

        </array_designs>
    </xsl:template>

</xsl:stylesheet>
