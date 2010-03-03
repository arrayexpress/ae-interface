<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                extension-element-prefixes="ae search"
                exclude-result-prefixes="ae search"
                version="1.0">

    <xsl:param name="sortby">releasedate</xsl:param>
    <xsl:param name="sortorder">descending</xsl:param>

    <xsl:param name="queryid"/>

    <!-- dynamically set by QueryServlet: host name (as seen from client) and base context path of webapp -->
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:output method="text" indent="no" encoding="ISO-8859-1"/>

    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex('experiments', $queryid)"/>

        <xsl:text>Accession</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Title</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Assays</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Species</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Release Date</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Processed Data</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Raw Data</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>Present in Atlas</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>ArrayExpress URL</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="ae-sort-experiments">
            <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
            <xsl:with-param name="pFrom"/>
            <xsl:with-param name="pTo"/>
            <xsl:with-param name="pSortBy" select="$sortby"/>
            <xsl:with-param name="pSortOrder" select="$sortorder"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:value-of select="accession"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="assays"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:call-template name="list-species"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="releasedate" />
        <xsl:text>&#9;</xsl:text>
        <xsl:call-template name="list-data">
            <xsl:with-param name="pKind" select="'fgem'"/>
            <xsl:with-param name="pAccession" select="accession"/>
        </xsl:call-template>
        <xsl:text>&#9;</xsl:text>
        <xsl:call-template name="list-data">
            <xsl:with-param name="pKind" select="'raw'"/>
            <xsl:with-param name="pAccession" select="accession"/>
        </xsl:call-template>
        <xsl:text>&#9;</xsl:text>
            <xsl:if test="@loadedinatlas">Yes</xsl:if>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="$vBaseUrl"/>/experiments/<xsl:value-of select="accession"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="list-species">
        <xsl:for-each select="species">
            <xsl:value-of select="."/>
                <xsl:if test="position() != last()">, </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="list-data">
        <xsl:param name="pKind"/>
        <xsl:param name="pAccession"/>
        <xsl:choose>
            <xsl:when test="count(file[kind=$pKind])>1"><xsl:value-of select="$vBaseUrl"/>/<xsl:value-of select="$pAccession"/>?kind=<xsl:value-of select="$pKind"/></xsl:when>
            <xsl:when test="file[kind=$pKind]"><xsl:value-of select="$vBaseUrl"/>/<xsl:value-of select="file[kind=$pKind]/relativepath"/></xsl:when>
            <xsl:otherwise><xsl:text>Data is not available</xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
