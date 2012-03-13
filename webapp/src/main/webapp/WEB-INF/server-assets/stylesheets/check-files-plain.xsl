<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                extension-element-prefixes="xs ae aejava search"
                exclude-result-prefixes="xs ae aejava search"
                version="2.0">
    
    <xsl:param name="rescanMessage" as="xs:string"/>

    <xsl:output method="text" indent="no" encoding="US-ASCII"/>
    <!--
    <xsl:variable name="vExperiments" select="search:queryIndex('experiments', 'visible:true')"/>
    <xsl:variable name="vArrays" select="search:queryIndex('arrays', 'visible:true')"/>
    -->
    <xsl:variable name="experiments">
        <experiment><accession>E-AFMX-1</accession></experiment>
        <experiment><accession>E-AFMX-2</accession></experiment>
        <experiment><accession>E-AFMX-10</accession></experiment>
    </xsl:variable>
    <xsl:variable name="vExperiments" select="$experiments/experiment"/>
    <xsl:variable name="arrays">
        <array_design><accession>A-AFFY-1</accession></array_design>
        <array_design><accession>A-AFFY-2</accession></array_design>
        <array_design><accession>A-AFFY-10</accession></array_design>
    </xsl:variable>
    <xsl:variable name="vArrays" select="$arrays/array_design"/>
    
    <xsl:template match="/files">
        <xsl:if test="string-length($rescanMessage)">
            <xsl:text>================================================================================&#10;</xsl:text>
            <xsl:text> IMPORTANT: please inspect the following message from file system scanner&#10;</xsl:text>
            <xsl:text>            before analysing checker report results&#10;</xsl:text>
            <xsl:text>---&#10;</xsl:text>
            <xsl:value-of select="$rescanMessage"/><xsl:text>&#10;</xsl:text>
            <xsl:text>================================================================================&#10;&#10;</xsl:text>
        </xsl:if>

        <!-- verify that every experiment has a folder -->
        <xsl:variable name="vExperimentFolders" select="folder[@kind='experiment']"/>
        <xsl:variable name="vExpFolderAccessions" as="xs:string" select="concat('|', string-join($vExperimentFolders/@accession, '|'), '|')"/>

        <xsl:variable name="vExperimentsWithoutFolders" select="$vExperiments[not(contains($vExpFolderAccessions, concat('|', accession, '|')))]"/>

        <xsl:if test="count($vExperimentsWithoutFolders) > 0">
            <xsl:text>Found </xsl:text>
            <xsl:value-of select="count($vExperimentsWithoutFolders)"/>
            <xsl:text> experiments without FTP folders&#10;</xsl:text>
            <xsl:value-of select="string-join($vExperimentsWithoutFolders/accession, '&#10;')"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>

        <!-- verify that every array has a folder -->
        <xsl:variable name="vArrayFolders" select="folder[@kind='array']"/>
        <xsl:variable name="vArrayFolderAccessions" as="xs:string" select="concat('|', string-join($vArrayFolders/@accession, '|'), '|')"/>

        <xsl:variable name="vArraysWithoutFolders" select="$vArrays[not(contains($vArrayFolderAccessions, concat('|', accession, '|')))]"/>

        <xsl:if test="count($vArraysWithoutFolders) > 0">
            <xsl:text>Found </xsl:text>
            <xsl:value-of select="count($vArraysWithoutFolders)"/>
            <xsl:text> arrays without FTP folders&#10;</xsl:text>
            <xsl:value-of select="string-join($vArraysWithoutFolders/accession, '&#10;')"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>

        <!-- verify public experiments have correct permissions -->
        <xsl:text>Checking public experiments...&#10;</xsl:text>
        <xsl:variable name="vPublicExperiments" select="$vExperiments[user = '1']"/>
        <xsl:for-each select="$vPublicExperiments/accession">
            <xsl:variable name="vExpFolder" select="$vExperimentFolders[@accession = current()]"/>
            <xsl:if test="not($vExpFolder)">
                <xsl:value-of select="current()"/><xsl:text> does not have FTP directory or it is inaccessible for file system scanner process&#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
