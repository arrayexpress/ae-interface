<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                exclude-result-prefixes="xs ae"
                version="2.0">

    <xsl:function name="ae:formatDateTime">
        <xsl:param name="pDateTime"/>
        <xsl:variable name="vDate" as="xs:date" select="xs:date(substring-before($pDateTime, 'T'))"/>
        <xsl:variable name="vTodaysDate" as="xs:date" select="current-date()"/>
        <xsl:variable name="vYesterdaysDate" as="xs:date" select="$vTodaysDate - xs:dayTimeDuration('P1D')"/>
        <xsl:choose>
            <xsl:when test="not($pDateTime castable as xs:dateTime)"/>
            <xsl:when test="$vTodaysDate eq $vDate">
                <xsl:value-of select="format-dateTime($pDateTime, 'Today, [H01]:[m01]', 'en', (), ())"/>
            </xsl:when>
            <xsl:when test="$vYesterdaysDate eq $vDate">
                <xsl:value-of select="format-dateTime($pDateTime, 'Yesterday, [H01]:[m01]', 'en', (), ())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-dateTime($pDateTime, '[D1] [MNn] [Y0001], [H01]:[m01]', 'en', (), ())"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="ae:formatDate">
        <xsl:param name="pDate" as="xs:date"/>
        <xsl:variable name="vTodaysDate" as="xs:date" select="current-date()"/>
        <xsl:variable name="vYesterdaysDate" as="xs:date" select="$vTodaysDate - xs:dayTimeDuration('P1D')"/>
        <xsl:choose>
            <xsl:when test="$vTodaysDate eq $pDate">
                <xsl:value-of select="'Today'"/>
            </xsl:when>
            <xsl:when test="$vYesterdaysDate eq $pDate">
                <xsl:value-of select="'Yesterday'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-date($pDate, '[D1] [MNn] [Y0001]', 'en', (), ())"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>