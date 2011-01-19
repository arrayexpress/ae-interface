<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:template name="ae-sort-files">
        <xsl:param name="pFiles"/>
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:param name="pSortBy"/>
        <xsl:param name="pSortOrder"/>
        <xsl:choose>
            <xsl:when test="$pSortBy = '' or ($pSortOrder != 'ascending' and $pSortOrder != 'descending')">
                <xsl:message>[WARN] Invalid sorting requested, ignored; $pSortBy [<xsl:value-of select="$pSortBy"/>], $pSortOrder [<xsl:value-of select="$pSortOrder"/>]</xsl:message>
                <xsl:apply-templates select="$pFiles">
                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$pSortBy='accession'">
                <xsl:apply-templates select="$pFiles">
                    <!-- sort by accession kind -->
                    <xsl:sort select="substring(../@accession, 1, 1)" order="{$pSortOrder}"/>
                    <!-- sort by accession 4-letter code -->
                    <xsl:sort select="substring(../@accession, 3, 4)" order="{$pSortOrder}"/>
                    <!-- sort by number -->
                    <xsl:sort select="substring(../@accession, 8)" order="{$pSortOrder}" data-type="number"/>

                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$pSortBy='name'">
                <xsl:apply-templates select="$pFiles">
                    <xsl:sort select="lower-case(@name)" order="{$pSortOrder}"/>

                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$pSortBy='size'">
                <xsl:apply-templates select="$pFiles">
                    <xsl:sort select="@size" order="{$pSortOrder}" data-type="number"/>

                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$pFiles">
                    <xsl:sort select="@*[name()=$pSortBy]" order="{$pSortOrder}"/>

                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>