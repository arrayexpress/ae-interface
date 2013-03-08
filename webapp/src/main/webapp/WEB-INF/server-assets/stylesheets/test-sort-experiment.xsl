<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
    extension-element-prefixes="ae xs"
    exclude-result-prefixes="ae xs"
    version="2.0">
    
    <xsl:include href="ae-date-functions.xsl"/>
    
    <xsl:template match="/">
        <xsl:value-of select="ae:formatDateTime('2012-04-21T12:00')"/>
    </xsl:template> 
</xsl:stylesheet>