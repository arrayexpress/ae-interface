<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/xslt"
                extension-element-prefixes="ae"
                exclude-result-prefixes="ae"                
                version="2.0">
    <xsl:output method="xml" version="1.0" encoding="UTF8" indent="yes"/>

    <xsl:include href="ae-file-functions.xsl"/>

    <xsl:variable name="vRoot" select="/files/@root"/>
    <xsl:variable name="vExperiments" select="doc('experiments.xml')"/>

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
                    <xsl:apply-templates>
                        <xsl:with-param name="pAccession" select="$vFolder/accession"/>
                    </xsl:apply-templates>
                </folder>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="file">
        <xsl:param name="pAccession"/>
        <xsl:if test="$pAccession">
            <file>
                <xsl:copy-of select="*|@*"/>
                <xsl:if test="@kind = 'raw' or @kind = 'fgem'">
                    <xsl:call-template name="add-dataformat-attribute">
                        <xsl:with-param name="pAccession" select="$pAccession"/>
                        <xsl:with-param name="pName" select="@name"/>
                        <xsl:with-param name="pKind" select="@kind"/>
                    </xsl:call-template>
                </xsl:if>
            </file>
        </xsl:if>
    </xsl:template>

    <xsl:template name="add-dataformat-attribute">
        <xsl:param name="pAccession"/>
        <xsl:param name="pName"/>
        <xsl:param name="pKind"/>
    
        <xsl:attribute name="dataformat" select="ae:dataformats($vExperiments/experiments/experiment[accession = $pAccession]/bioassaydatagroup, $pKind)"/>
    </xsl:template>

</xsl:stylesheet>
