<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2014 European Molecular Biology Laboratory
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:template name="ae-sort-arrays">
        <xsl:param name="pArrays"/>
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:param name="pSortBy"/>
        <xsl:param name="pSortOrder"/>
        <xsl:choose>
            <xsl:when test="$pSortBy = '' or ($pSortOrder != 'ascending' and $pSortOrder != 'descending')">
                <xsl:message>[WARN] Invalid sorting requested, ignored; $pSortBy [<xsl:value-of select="$pSortBy"/>], $pSortOrder [<xsl:value-of select="$pSortOrder"/>]</xsl:message>
                <xsl:apply-templates select="$pArrays">
                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$pSortBy='accession'">
                <xsl:apply-templates select="$pArrays">
                    <xsl:sort select="substring(accession, 3, 4)" order="{$pSortOrder}"/>
                    <!-- sort by experiment 4-letter code -->
                    <xsl:sort select="substring(accession, 8)" order="{$pSortOrder}" data-type="number"/>
                    <!-- sort by number -->
                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$pSortBy='name'">
                <xsl:apply-templates select="$pArrays">
                    <xsl:sort select="lower-case(name)" order="{$pSortOrder}"/>
                    <!-- then sort by accession -->
                    <xsl:sort select="substring(accession, 3, 4)" order="{$pSortOrder}"/>
                    <!-- sort by experiment 4-letter code -->
                    <xsl:sort select="substring(accession, 8)" order="{$pSortOrder}" data-type="number"/>
                    <!-- sort by number -->

                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$pSortBy='releasedate'">
                <xsl:apply-templates select="$pArrays">
                    <!-- year -->
                    <xsl:sort select="substring-before(releasedate, '-')" order="{$pSortOrder}" data-type="number"/>
                    <!-- month -->
                    <xsl:sort select="substring-before(substring-after(releasedate, '-'), '-')" order="{$pSortOrder}"
                              data-type="number"/>
                    <!-- day -->
                    <xsl:sort select="substring-after(substring-after(releasedate, '-'), '-')" order="{$pSortOrder}"
                              data-type="number"/>
                    <!-- then sort by accession -->
                    <xsl:sort select="substring(accession, 3, 4)" order="{$pSortOrder}"/>
                    <!-- sort by experiment 4-letter code -->
                    <xsl:sort select="substring(accession, 8)" order="{$pSortOrder}" data-type="number"/>
                    <!-- sort by number -->

                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$pSortBy='organism'">
                <xsl:apply-templates select="$pArrays">
                    <xsl:sort select="organism[1]" order="{$pSortOrder}"/>
                    <xsl:sort select="organism[2]" order="{$pSortOrder}"/>
                    <xsl:sort select="organism[3]" order="{$pSortOrder}"/>
                    <!-- then sort by accession -->
                    <xsl:sort select="substring(accession, 3, 4)" order="{$pSortOrder}"/>
                    <!-- sort by experiment 4-letter code -->
                    <xsl:sort select="substring(accession, 8)" order="{$pSortOrder}" data-type="number"/>
                    <!-- sort by number -->

                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$pArrays">
                    <xsl:sort select="*[name()=$pSortBy][1]" order="{$pSortOrder}"/>
                    <!-- then sort by accession -->
                    <xsl:sort select="substring(accession, 3, 4)" order="{$pSortOrder}"/>
                    <!-- sort by experiment 4-letter code -->
                    <xsl:sort select="substring(accession, 8)" order="{$pSortOrder}" data-type="number"/>
                    <!-- sort by number -->

                    <xsl:with-param name="pFrom" select="$pFrom"/>
                    <xsl:with-param name="pTo" select="$pTo"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>