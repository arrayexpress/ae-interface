<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="search"
                exclude-result-prefixes="search html"
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
        <xsl:param name="pText"/>
        <xsl:param name="pFieldName"/>
        <xsl:variable name="vText" select="$pText"/>
        <xsl:choose>
            <xsl:when test="string-length($vText)!=0">
                <xsl:variable name="vHighlightedText" select="search:highlightQuery($queryid, $pFieldName, $vText)"/>
                <xsl:call-template name="format-highlighted-text">
                    <xsl:with-param name="pText" select="$vHighlightedText"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>&#160;</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="format-highlighted-text">
        <xsl:param name="pText"/>
        <xsl:choose>
            <xsl:when test="contains($pText,'&#x00ab;') and contains($pText,'&#x00bb;')">
                <xsl:call-template name="format-highlighted-text">
                    <xsl:with-param name="pText" select="substring-before($pText,'&#x00ab;')"/>
                </xsl:call-template>
                <span class="ae_text_hit"><xsl:value-of select="substring-after(substring-before($pText,'&#x00bb;'),'&#x00ab;')"/></span>
                <xsl:call-template name="format-highlighted-text">
                    <xsl:with-param name="pText" select="substring-after($pText,'&#x00bb;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="format-highlighted-synonyms">
                    <xsl:with-param name="pText" select="$pText"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="format-highlighted-synonyms">
        <xsl:param name="pText"/>
        <xsl:choose>
            <xsl:when test="contains($pText,'&#x2039;') and contains($pText,'&#x203a;')">
                <xsl:call-template name="format-highlighted-synonyms">
                    <xsl:with-param name="pText" select="substring-before($pText,'&#x2039;')"/>
                </xsl:call-template>
                <span class="ae_text_syn"><xsl:value-of select="substring-after(substring-before($pText,'&#x203a;'),'&#x2039;')"/></span>
                <xsl:call-template name="format-highlighted-synonyms">
                    <xsl:with-param name="pText" select="substring-after($pText,'&#x203a;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="format-highlighted-efo">
                    <xsl:with-param name="pText" select="$pText"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="format-highlighted-efo">
        <xsl:param name="pText"/>
        <xsl:choose>
            <xsl:when test="contains($pText,'&#x2035;') and contains($pText,'&#x2032;')">
                <xsl:call-template name="format-highlighted-efo">
                    <xsl:with-param name="pText" select="substring-before($pText,'&#x2035;')"/>
                </xsl:call-template>
                <span class="ae_text_efo"><xsl:value-of select="substring-after(substring-before($pText,'&#x2032;'),'&#x2035;')"/></span>
                <xsl:call-template name="format-highlighted-efo">
                    <xsl:with-param name="pText" select="substring-after($pText,'&#x2032;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$pText"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>