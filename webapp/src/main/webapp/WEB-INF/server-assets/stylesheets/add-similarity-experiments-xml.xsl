<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae fn"
                exclude-result-prefixes="ae fn html"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/experiments">
        <experiments>
            <xsl:copy-of select="@*"/>

            <xsl:apply-templates select="experiment"/>
        </experiments>
    </xsl:template>

    <xsl:template match="experiment">
        <experiment>
            <xsl:copy-of select="@* | *[name() != 'similarto']"/>
            <xsl:for-each select="ae:getAcceleratorValue('similar-experiments', accession)">
                <similarto>
                    <accession><xsl:value-of select="accession"/></accession>
                    <distance>...</distance>
                </similarto>
            </xsl:for-each>
        </experiment>
    </xsl:template>


</xsl:stylesheet>