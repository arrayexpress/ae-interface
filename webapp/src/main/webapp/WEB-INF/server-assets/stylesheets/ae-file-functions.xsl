<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                extension-element-prefixes="aejava"
                exclude-result-prefixes="ae aejava xs"
                version="2.0">

    <xsl:function name="ae:formatFileSize">
        <xsl:param name="pSize"/>
        <xsl:value-of select="aejava:formatFileSize($pSize)"/>
    </xsl:function>

</xsl:stylesheet>