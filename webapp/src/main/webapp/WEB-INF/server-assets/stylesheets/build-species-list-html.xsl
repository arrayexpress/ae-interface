<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:html="http://www.w3.org/1999/xhtml"
        xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
        extension-element-prefixes="ae html"
        exclude-result-prefixes="ae html"
        version="2.0">

    <xsl:output omit-xml-declaration="yes" method="html" encoding="ISO-8859-1" />

    <xsl:template match="/experiments">
        <option value="">All species</option>
        <xsl:for-each-group select="experiment/species" group-by="ae:normalize-species(text())" collation="http://saxon.sf.net/collation?ignore-case=yes">
            <xsl:sort select="ae:normalize-species(text())"/>
            <option>
                <xsl:attribute name="value" select="ae:normalize-species(text())"/>
                <xsl:value-of select="ae:normalize-species(text())"/>
            </option>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:function name="ae:normalize-species">
        <xsl:param name="species"/>
        <xsl:variable name="spacedSpecies" select="concat(normalize-space($species), ' ')"/>
        <xsl:value-of select="concat(upper-case(substring($spacedSpecies, 1, 1)), lower-case(substring(substring-before($spacedSpecies, ' '), 2)), ' ', lower-case(substring-before(substring-after($spacedSpecies, ' '), ' ')))"/>
    </xsl:function>
</xsl:stylesheet>
