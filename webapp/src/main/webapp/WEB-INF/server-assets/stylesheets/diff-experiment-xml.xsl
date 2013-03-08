<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae search html"
                exclude-result-prefixes="ae search html"
                version="2.0">

    <xsl:param name="queryid"/>
    <xsl:param name="accession"/>
    <xsl:param name="source"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    <xsl:variable name="vAccession" select="upper-case($accession)"/>


    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:include href="ae-compare-experiments.xsl"/>

    <xsl:template match="/experiments">
        <xsl:variable name="vExperiment" select="experiment[accession = $vAccession]"/>
        <xsl:variable name="vActiveExperiment" select="search:queryIndex($queryid)"/>
        <experiments>
            <xsl:choose>
                <xsl:when test="count($vExperiment) > 1">
                    <xsl:call-template name="ae:copy-and-diff-node">
                        <xsl:with-param name="pNode" select="ae:sort-elements-attributes($vActiveExperiment)"/>
                        <xsl:with-param name="pNodeDiffAgainst" select="ae:sort-elements-attributes($vExperiment[source/@id != $source])"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$vExperiment"/>
                </xsl:otherwise>
            </xsl:choose>
        </experiments>
    </xsl:template>

</xsl:stylesheet>
