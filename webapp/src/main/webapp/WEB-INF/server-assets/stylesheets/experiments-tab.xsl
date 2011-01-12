<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                extension-element-prefixes="aejava fn search"
                exclude-result-prefixes="aejava fn search"
                version="1.0">

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'releasedate'"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'descending'"/>

    <xsl:param name="queryid"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    <xsl:variable name="vFilesDoc" select="doc('files.xml')"/>

    <xsl:output method="text" indent="no" encoding="UTF-8"/>

    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex($queryid)"/>

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
            <xsl:with-param name="pSortBy" select="$vSortBy"/>
            <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
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
        <xsl:variable name="vFiles" select="aejava:getAcceleratorValue(fn:concat($pKind, '-files'), $pAccession)"/>
        <xsl:choose>
            <xsl:when test="$vFiles > 1">
                <xsl:value-of select="$vBaseUrl"/>/files/<xsl:value-of select="$pAccession"/>?kind=<xsl:value-of select="$pKind"/>
            </xsl:when>
            <xsl:when test="$vFiles = 1">
                <xsl:value-of select="$vBaseUrl"/>/files/<xsl:value-of select="$pAccession"/>/<xsl:value-of
                    select="$vFilesDoc/files/folder[@accession = $pAccession]/file[@kind = $pKind]/@name"/>
            </xsl:when>
            <xsl:otherwise><xsl:text>Data is not available</xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
