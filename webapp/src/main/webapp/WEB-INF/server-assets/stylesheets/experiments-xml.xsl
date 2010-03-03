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

    <xsl:output omit-xml-declaration="yes" method="xml" indent="no"/>
    
    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex('experiments', $queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredExperiments)"/>

        <experiments version="1.1" revision="080925"
                     total="{$vTotal}"
                     total-samples="{sum($vFilteredExperiments/samples)}"
                     total-assays="{sum($vFilteredExperiments/assays)}">
            <xsl:call-template name="ae-sort-experiments">
                <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                <xsl:with-param name="pFrom"/>
                <xsl:with-param name="pTo"/>
                <xsl:with-param name="pSortBy" select="$sortby"/>
                <xsl:with-param name="pSortOrder" select="$sortorder"/>
            </xsl:call-template>
        </experiments>
    </xsl:template>

    <xsl:template match="experiment">
        <experiment>
            <xsl:copy-of select="*[not(name() = 'user')]"/>
            <files>
                <xsl:comment>
This section is deprecated and unsupported.
Please use webservice located at:
    <xsl:value-of select="$vBaseUrl"/>/xml/files
to obtain detailed information on files available for the experiment.
For more information, please go to:
    http://www.ebi.ac.uk/microarray/doc/help/programmatic_access.html
                </xsl:comment>
                <raw name="{accession}.raw.zip"
                     count="{sum(bioassaydatagroup[isderived = '0']/bioassays)}"
                     celcount="{sum(bioassaydatagroup[isderived = '0'][contains(dataformat, 'CEL')]/bioassays)}"/>
                <fgem name="{accession}.processed.zip"
                      count="{sum(bioassaydatagroup[isderived = '1']/bioassays)}"/>
                <idf name="{accession}.idf.txt"/>
                <sdrf name="{accession}.sdrf.txt"/>
                <biosamples>
                        <png name="{accession}.biosamples.png"/>
                        <svg name="{accession}.biosamples.svg"/>
                </biosamples>
            </files>
        </experiment>
    </xsl:template>

</xsl:stylesheet>