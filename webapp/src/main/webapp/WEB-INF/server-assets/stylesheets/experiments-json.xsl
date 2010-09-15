<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:json="http://json.org/"
                extension-element-prefixes="ae search json"
                exclude-result-prefixes="ae search json"
                version="2.0">

    <xsl:import href="xml-to-json.xsl"/>
    <xsl:param name="skip-root" as="xs:boolean" select="true()"/>

    <xsl:param name="sortby">releasedate</xsl:param>
    <xsl:param name="sortorder">descending</xsl:param>

    <xsl:param name="limit"/>
    <xsl:param name="queryid"/>

    <!-- dynamically set by QueryServlet: host name (as seen from client) and base context path of webapp -->
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="utf-8"/>
    
    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex('experiments', $queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredExperiments)"/>

        <xsl:variable name="vOutput">
            <experiments version="1.2" revision="100915"
                         total="{$vTotal}"
                         total-samples="{sum($vFilteredExperiments/samples)}"
                         total-assays="{sum($vFilteredExperiments/assays)}">
                <xsl:if test="$limit">
                    <xsl:attribute name="limit" select="$limit"/>
                </xsl:if>
                <xsl:call-template name="ae-sort-experiments">
                    <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                    <xsl:with-param name="pFrom" select="1"/>
                    <xsl:with-param name="pTo" select="if ($limit) then $limit else $vTotal"/>
                    <xsl:with-param name="pSortBy" select="$sortby"/>
                    <xsl:with-param name="pSortOrder" select="$sortorder"/>
                </xsl:call-template>
            </experiments>
        </xsl:variable>
        <xsl:value-of select="json:generate($vOutput)"/>
    </xsl:template>

    <xsl:template match="experiment">
        <experiment>
            <xsl:copy-of select="*[not(name() = 'user')]"/>
        </experiment>
    </xsl:template>

</xsl:stylesheet>