<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="xs search"
                exclude-result-prefixes="xs search html"
                version="2.0">

    <xsl:template match="*" mode="highlight">
        <xsl:param name="pFieldName"/>
        <xsl:element name="{if (name() = 'text') then 'div' else name() }">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="highlight">
                <xsl:with-param name="pFieldName" select="$pFieldName"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text()" mode="highlight">
        <xsl:param name="pFieldName"/>
        <xsl:call-template name="highlight">
            <xsl:with-param name="pText" select="."/>
            <xsl:with-param name="pFieldName" select="$pFieldName"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="highlight">
        <xsl:param name="pText" as="xs:string"/>
        <xsl:param name="pFieldName"/>
        <xsl:variable name="vText" select="$pText"/>
        <xsl:choose>
            <xsl:when test="string-length($vText)!=0">
                <xsl:variable name="markedtext" select="search:highlightQuery($queryid, $pFieldName, $vText)"/>
                <xsl:call-template name="add_highlight_element">
                    <xsl:with-param name="text" select="$markedtext"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>&#160;</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="add_highlight_element">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="contains($text,'&#x00ab;') and contains($text,'&#x00bb;')">
                <xsl:call-template name="add_highlight_element">
                    <xsl:with-param name="text" select="substring-before($text,'&#x00ab;')"/>
                </xsl:call-template>
                <span class="ae_text_hit"><xsl:value-of select="substring-after(substring-before($text,'&#x00bb;'),'&#x00ab;')"/></span>
                <xsl:call-template name="add_highlight_element">
                    <xsl:with-param name="text" select="substring-after($text,'&#x00bb;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="add_syn_highlight_element">
                    <xsl:with-param name="text" select="$text"/>
                </xsl:call-template>
            </xsl:otherwise>
       </xsl:choose>
   </xsl:template>

   <xsl:template name="add_syn_highlight_element">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="contains($text,'&#x2039;') and contains($text,'&#x203a;')">
                <xsl:call-template name="add_syn_highlight_element">
                    <xsl:with-param name="text" select="substring-before($text,'&#x2039;')"/>
                </xsl:call-template>
                <span class="ae_text_syn"><xsl:value-of select="substring-after(substring-before($text,'&#x203a;'),'&#x2039;')"/></span>
                <xsl:call-template name="add_syn_highlight_element">
                    <xsl:with-param name="text" select="substring-after($text,'&#x203a;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="add_efo_highlight_element">
                    <xsl:with-param name="text" select="$text"/>
                </xsl:call-template>
            </xsl:otherwise>
       </xsl:choose>
   </xsl:template>

   <xsl:template name="add_efo_highlight_element">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="contains($text,'&#x2035;') and contains($text,'&#x2032;')">
                <xsl:call-template name="add_efo_highlight_element">
                    <xsl:with-param name="text" select="substring-before($text,'&#x2035;')"/>
                </xsl:call-template>
                <span class="ae_text_efo"><xsl:value-of select="substring-after(substring-before($text,'&#x2032;'),'&#x2035;')"/></span>
                <xsl:call-template name="add_efo_highlight_element">
                    <xsl:with-param name="text" select="substring-after($text,'&#x2032;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
       </xsl:choose>
   </xsl:template>

</xsl:stylesheet>