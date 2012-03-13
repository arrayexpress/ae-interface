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

    <xsl:variable name="vExperiments" select="search:queryIndex('experiments', 'visible:true')"/>
    <xsl:template match="/">
        <xsl:if test="string-length($rescanMessage)">
            <xsl:text>================================================================================&#10;</xsl:text>
            <xsl:text> IMPORTANT: please inspect the following message from file system scanner&#10;</xsl:text>
            <xsl:text>            before analysing checker report results&#10;</xsl:text>
            <xsl:text>---&#10;</xsl:text>
            <xsl:value-of select="$rescanMessage"/><xsl:text>&#10;</xsl:text>
            <xsl:text>================================================================================&#10;</xsl:text>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
