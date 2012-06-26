<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                extension-element-prefixes="ae fn search"
                exclude-result-prefixes="ae fn search"
                version="2.0">

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:param name="queryid"/>
    <xsl:param name="accession"/>
    <xsl:param name="keywords"/>
    <xsl:param name="userid"/>
    <xsl:param name="kind"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    <xsl:variable name="vFilteredFiles" select="search:queryIndex($queryid)"/>

    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <files>
            <xsl:apply-templates select="$vFilteredFiles"/>
        </files>
    </xsl:template>

    <xsl:template match="file">
        <file accession= "{../@accession}" name="{@name}">
            <xsl:copy-of select="ae:tabularDocument(fn:concat(../@location, '/', @name))"/>
        </file>
    </xsl:template>

</xsl:stylesheet>
