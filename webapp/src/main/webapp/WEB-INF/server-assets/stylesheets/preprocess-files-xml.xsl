<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                extension-element-prefixes="ae aejava"
                exclude-result-prefixes="ae aejava"                
                version="2.0">
    <xsl:output method="xml" version="1.0" encoding="UTF8" indent="yes"/>

    <xsl:include href="ae-file-functions.xsl"/>

    <xsl:variable name="vRoot" select="/files/@root"/>

    <xsl:template match="/files">
        <files root="{$vRoot}">
            <xsl:apply-templates/>
        </files>
    </xsl:template>

    <xsl:template match="folder">
        <xsl:variable name="vFolder">
            <xsl:analyze-string select="@location" regex="[/\\](array|experiment|protocol)[/\\].*([AEP]-\w{{4}}-\d+)$" flags="i">
                <xsl:matching-substring>
                    <kind><xsl:value-of select="regex-group(1)"/></kind>
                    <accession><xsl:value-of select="upper-case(regex-group(2))"/></accession>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$vFolder/accession">
                <folder accession="{$vFolder/accession}" kind="{$vFolder/kind}" location="{replace(@location, $vRoot, '')}">
                    <xsl:variable name="vMetaData" select="aejava:getAcceleratorValueAsSequence(concat('visible-', $vFolder/kind, 's'), $vFolder/accession)"/>
                    <xsl:copy-of select="$vMetaData/user"/>
                    <xsl:apply-templates>
                        <xsl:with-param name="pMetaData" select="$vMetaData"/>
                    </xsl:apply-templates>
                </folder>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="file">
        <xsl:param name="pMetaData"/>

        <file>
            <xsl:if test="exists($pMetaData) and (@kind = 'raw' or @kind = 'fgem')">
                <xsl:attribute name="dataformat" select="ae:dataformats($pMetaData/bioassaydatagroup, string(@kind))"/>
            </xsl:if>
            <xsl:copy-of select="@*"/>
        </file>
    </xsl:template>

</xsl:stylesheet>
