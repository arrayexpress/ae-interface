<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:html="http://www.w3.org/1999/xhtml"
        extension-element-prefixes="html"
        exclude-result-prefixes="html"
        version="2.0">

    <xsl:output omit-xml-declaration="yes" method="html"/>
    <xsl:template match="/experiments">
        <option value="">All experiment types</option>
        <xsl:for-each-group select="experiment/experimenttype" group-by="text()" collation="http://saxon.sf.net/collation?ignore-case=yes">
            <xsl:sort select="lower-case(.)"/>
            <option value="{.}">
                <xsl:value-of select="."/>
            </option>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
