<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
    exclude-result-prefixes="xs ae fn"
    version="2.0">
    
    <xsl:function name="ae:getMappedValue">
        <xsl:param name="pMapName" as="xs:string"/>
        <xsl:param name="pKey" as="xs:string"/>
        <xsl:value-of select="'1'"/>
    </xsl:function>
</xsl:stylesheet>