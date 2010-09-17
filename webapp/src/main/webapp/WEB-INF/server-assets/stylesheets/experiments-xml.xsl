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
    <xsl:variable name="vFilesDoc" select="doc('files.xml')"/>

    <xsl:output omit-xml-declaration="yes" method="xml" indent="no"/>
    
    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex('experiments', $queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredExperiments)"/>

        <experiments version="1.2" revision="100915"
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
                <xsl:variable name="vAccession" select="accession"/>
                <xsl:variable name="vFiles" select="$vFilesDoc/files/folder[@accession = $vAccession]"/>
                <xsl:if test="$vFiles/file[@kind = 'raw']">
                    <raw name="{$vFiles/file[@kind = 'raw']/@name}"
                         count="{rawdatafiles}"
                         celcount="{sum(bioassaydatagroup[isderived = '0'][contains(dataformat, 'CEL')]/bioassays)}"/>
                </xsl:if>
                <xsl:if test="$vFiles/file[@kind = 'fgem']">
                    <fgem name="{$vFiles/file[@kind = 'fgem']/@name}"
                          count="{fgemdatafiles}"/>
                </xsl:if>
                <xsl:if test="$vFiles/file[@kind = 'idf' and @extension = 'txt']">
                    <idf name="{$vFiles/file[@kind = 'idf' and @extension = 'txt']/@name}"/>
                </xsl:if>
                <xsl:if test="$vFiles/file[@kind = 'sdrf' and @extension = 'txt']">
                    <sdrf name="{$vFiles/file[@kind = 'sdrf' and @extension = 'txt']/@name}"/>
                </xsl:if>
                <xsl:if test="$vFiles/file[@kind = 'biosamples']">
                    <biosamples>
                        <xsl:if test="$vFiles/file[@kind = 'biosamples' and @extension = 'png']">
                            <png name="{$vFiles/file[@kind = 'biosamples' and @extension = 'png']/@name}"/>
                        </xsl:if>
                        <xsl:if test="$vFiles/file[@kind = 'biosamples' and @extension = 'svg']">
                            <svg name="{$vFiles/file[@kind = 'biosamples' and @extension = 'svg']/@name}"/>
                        </xsl:if>
                    </biosamples>
                </xsl:if>
            </files>
        </experiment>
    </xsl:template>

</xsl:stylesheet>