<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                extension-element-prefixes="aejava search"
                exclude-result-prefixes="aejava search"
                version="2.0">

    <xsl:param name="sortby">releasedate</xsl:param>
    <xsl:param name="sortorder">descending</xsl:param>

    <xsl:param name="queryid"/>

    <!-- dynamically set by QueryServlet: host name (as seen from client) and base context path of webapp -->
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>


    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredExperiments)"/>

        <files version="1.1" revision="100915"
                     total-experiments="{$vTotal}">
            <xsl:call-template name="ae-sort-experiments">
                <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                <xsl:with-param name="pFrom"/>
                <xsl:with-param name="pTo"/>
                <xsl:with-param name="pSortBy" select="$sortby"/>
                <xsl:with-param name="pSortOrder" select="$sortorder"/>
            </xsl:call-template>
        </files>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:variable name="vAccession" select="accession"/>
        <experiment>
            <accession><xsl:value-of select="$vAccession"/></accession>
            <xsl:variable name="vExpFolder" select="aejava:getAcceleratorValueAsSequence('exp-files', $vAccession)"/>
            <xsl:for-each select="$vExpFolder/file">
                <xsl:call-template name="file-for-accession">
                    <xsl:with-param name="pAccession" select="$vAccession"/>
                    <xsl:with-param name="pFile" select="."/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="arraydesign">
                <xsl:sort select="accession" order="ascending"/>
                <xsl:variable name="vArrAccession" select="string(accession)"/>
                <xsl:variable name="vArrFolder" select="aejava:getAcceleratorValueAsSequence('exp-files', $vArrAccession)"/>

                <xsl:for-each select="$vArrFolder/file[@kind = 'adf']">
                    <xsl:call-template name="file-for-accession">
                        <xsl:with-param name="pAccession" select="$vArrAccession"/>
                        <xsl:with-param name="pFile" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
        </experiment>
    </xsl:template>

    <xsl:template name="file-for-accession">
        <xsl:param name="pAccession"/>
        <xsl:param name="pFile"/>
        
        <xsl:element name="file">
            <xsl:if test="$pFile/@*">
                <xsl:for-each select="$pFile/@*">
                    <xsl:element name="{lower-case(name())}">
                        <xsl:value-of select="." />
                    </xsl:element>
                </xsl:for-each>
                <xsl:if test="$pFile/@name">
                    <xsl:element name="url">
                        <xsl:value-of select="$vBaseUrl"/>/files/<xsl:value-of select="$pAccession"/>/<xsl:value-of select="$pFile/@name"/>
                    </xsl:element>
                </xsl:if>
            </xsl:if>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>