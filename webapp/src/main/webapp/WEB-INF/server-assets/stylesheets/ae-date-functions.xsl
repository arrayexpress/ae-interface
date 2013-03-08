<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                exclude-result-prefixes="xs ae fn"
                version="2.0">

    <xsl:function name="ae:isFutureDate" as="xs:boolean">
        <xsl:param name="pDate"/>
        <xsl:variable name="vTodaysDate" as="xs:date" select="fn:current-date()"/>
        <xsl:choose>
            <xsl:when test="fn:not($pDate castable as xs:date)">
                <xsl:value-of select="fn:false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="xs:date($pDate) > $vTodaysDate"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="ae:dateTimeToRfc822" as="xs:string">
        <xsl:param name="pDateTime"/>
        <xsl:value-of select="fn:format-dateTime($pDateTime, '[FNn,*-3], [D01] [MNn,*-3] [Y0001] [H01]:[m01]:[s01] +0000', 'en', (), ())"/>
    </xsl:function>


    <xsl:function name="ae:formatDateTime" as="xs:string">
        <xsl:param name="pDateTime"/>
        <xsl:variable name="vDate" as="xs:date" select="xs:date(if (fn:contains($pDateTime, 'T')) then fn:substring-before($pDateTime, 'T') else $pDateTime)"/>
        <xsl:variable name="vTodaysDate" as="xs:date" select="fn:current-date()"/>
        <xsl:variable name="vYesterdaysDate" as="xs:date" select="$vTodaysDate - xs:dayTimeDuration('P1D')"/>
        <xsl:choose>
            <xsl:when test="fn:not($pDateTime castable as xs:dateTime)">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$vTodaysDate eq $vDate">
                <xsl:value-of select="fn:format-dateTime(xs:dateTime($pDateTime), 'Today, [H01]:[m01]', 'en', (), ())"/>
            </xsl:when>
            <xsl:when test="$vYesterdaysDate eq $vDate">
                <xsl:value-of select="fn:format-dateTime(xs:dateTime($pDateTime), 'Yesterday, [H01]:[m01]', 'en', (), ())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="fn:format-dateTime(xs:dateTime($pDateTime), '[D1] [MNn] [Y0001], [H01]:[m01]', 'en', (), ())"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="ae:formatDate" as="xs:string">
        <xsl:param name="pDate"/>
        <xsl:variable name="vTodaysDate" as="xs:date" select="fn:current-date()"/>
        <xsl:variable name="vTomorrowDate" as="xs:date" select="$vTodaysDate + xs:dayTimeDuration('P1D')"/>
        <xsl:variable name="vYesterdaysDate" as="xs:date" select="$vTodaysDate - xs:dayTimeDuration('P1D')"/>
        <xsl:choose>
            <xsl:when test="fn:not($pDate castable as xs:date)">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$vTomorrowDate eq xs:date($pDate)">
                <xsl:value-of select="'Tomorrow'"/>
            </xsl:when>
            <xsl:when test="$vTodaysDate eq xs:date($pDate)">
                <xsl:value-of select="'Today'"/>
            </xsl:when>
            <xsl:when test="$vYesterdaysDate eq xs:date($pDate)">
                <xsl:value-of select="'Yesterday'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="fn:format-date(xs:date($pDate), '[D1] [MNn] [Y0001]', 'en', (), ())"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>