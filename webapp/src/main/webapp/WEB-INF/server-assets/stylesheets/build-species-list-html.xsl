<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:html="http://www.w3.org/1999/xhtml"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
        extension-element-prefixes="ae"
        exclude-result-prefixes="ae fn html"
        version="2.0">

    <xsl:output omit-xml-declaration="yes" method="html" encoding="ISO-8859-1" />

    <xsl:template match="/experiments">
        <option value="">All species</option>
        <xsl:for-each-group select="experiment[source/@visible = 'true']/species" group-by="ae:normalize-species(text())" collation="http://saxon.sf.net/collation?ignore-case=yes">
            <xsl:sort select="ae:normalize-species(text())"/>
            <option>
                <xsl:attribute name="value" select="ae:normalize-species(text())"/>
                <xsl:value-of select="ae:normalize-species(text())"/>
            </option>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:function name="ae:normalize-species">
        <xsl:param name="pSpecies"/>
        <xsl:variable name="vTransformedSpecies" select="fn:normalize-space(fn:replace($pSpecies, '(\w|^)[\.,=_]+(\w|$)', '$1 $2'))"/>
        <xsl:value-of select="fn:concat(fn:upper-case(fn:substring($vTransformedSpecies, 1, 1)), fn:lower-case(fn:substring($vTransformedSpecies, 2)))"/>
    </xsl:function>
</xsl:stylesheet>
