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
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="ae saxon"
                exclude-result-prefixes="ae saxon"
                version="2.0">

    <!-- checks if experiments contain equal set of elements/attributes (with a notable exception of source element) -->
    <xsl:function name="ae:are-experiments-identical">
        <xsl:param name="pExp1"/>
        <xsl:param name="pExp2"/>

        <xsl:variable name="vSortedFilteredExp1">
            <xsl:for-each select="$pExp1/*[name() = 'accession' or name() = 'secondaryaccession' or name() = 'seqdatauri' or name() = 'experimenttype']">
                <xsl:sort select="name()" order="ascending"/>
                <xsl:sort select="text()" order="ascending"/>
                <xsl:sort select="accession" order="ascending"/>
                <xsl:sort select="id" order="ascending"/>
                <xsl:copy-of select="ae:sort-elements-attributes(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="vSortedFilteredExp2">
            <xsl:for-each select="$pExp2/*[name() = 'accession' or name() = 'secondaryaccession' or name() = 'seqdatauri' or name() = 'experimenttype']">
                <xsl:sort select="name()" order="ascending"/>
                <xsl:sort select="text()" order="ascending"/>
                <xsl:sort select="accession" order="ascending"/>
                <xsl:sort select="id" order="ascending"/>
                <xsl:copy-of select="ae:sort-elements-attributes(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of
                select="saxon:deep-equal($vSortedFilteredExp1, $vSortedFilteredExp2, 'http://saxon.sf.net/collation?ignore-case=yes', 'Sw')"/>
    </xsl:function>

    <xsl:function name="ae:sort-elements-attributes">
        <xsl:param name="pNode"/>
        <xsl:if test="$pNode/self::*">
            <xsl:element name="{$pNode/name()}">
                <xsl:for-each select="$pNode/@*">
                    <xsl:sort select="name()" order="ascending"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="$pNode/*">
                    <xsl:sort select="name()" order="ascending"/>
                    <xsl:sort select="text()[1]" order="ascending"/>
                    <xsl:sort select="accession" order="ascending"/>
                    <xsl:sort select="id" order="ascending"/>
                    <xsl:copy-of select="ae:sort-elements-attributes(.)"/>
                </xsl:for-each>
                <xsl:value-of select="normalize-space(string-join($pNode/text(), ' '))"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>

    <xsl:template name="ae:copy-and-diff-node">
        <xsl:param name="pNode"/>
        <xsl:param name="pNodeDiffAgainst"/>

        <xsl:for-each-group select="$pNode | $pNodeDiffAgainst" group-by="name()">
            <xsl:sort order="ascending"/>
            <xsl:variable name="vCurrentNodeName" select="current-grouping-key()"/>
            <xsl:variable name="vCurrentNodeList" select="$pNode[name() = current-grouping-key()]"/>
            <xsl:variable name="vCurrentNodeDiffAgainstList"
                          select="$pNodeDiffAgainst[name() = current-grouping-key()]"/>
            <xsl:for-each select="$vCurrentNodeList">
                <xsl:variable name="vPos" select="position()"/>
                <xsl:variable name="vOtherElement" select="$vCurrentNodeDiffAgainstList[$vPos]"/>
                <xsl:element name="{$vCurrentNodeName}">
                    <xsl:choose>
                        <xsl:when test="$vOtherElement">
                            <xsl:if test="ae:are-attrs-differ(., $vOtherElement) != ''">
                                <xsl:attribute name="diff-attributes" select="true()"/>
                            </xsl:if>
                            <xsl:variable name="vDiffText" select="ae:is-normalized-text-different(., $vOtherElement)"/>
                            <xsl:if test=" $vDiffText != ''">
                                <xsl:attribute name="diff-text" select="true()"/>
                            </xsl:if>
                            <xsl:copy-of select="@*"/>
                            <xsl:call-template name="ae:copy-and-diff-node">
                                <xsl:with-param name="pNode" select="./*"/>
                                <xsl:with-param name="pNodeDiffAgainst" select="$vOtherElement/*"/>
                            </xsl:call-template>
                            <xsl:if test=" $vDiffText != ''">
                                <xsl:element name="diff-text">
                                    <xsl:value-of select="normalize-space(string-join($vOtherElement/text(), ' '))"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:value-of select="normalize-space(string-join(text(), ' '))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="diff-added" select="true()"/>
                            <xsl:copy-of select="@*|*"/>
                            <xsl:value-of select="normalize-space(string-join(text(), ' '))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="$vCurrentNodeDiffAgainstList">
                <xsl:if test="position() > count($vCurrentNodeList)">
                    <xsl:element name="{$vCurrentNodeName}">
                        <xsl:attribute name="diff-deleted" select="true()"/>
                        <xsl:copy-of select="@*|*"/>
                        <xsl:value-of select="normalize-space(string-join(text(), ' '))"/>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>

        </xsl:for-each-group>
    </xsl:template>

    <xsl:function name="ae:are-attrs-differ">
        <xsl:param name="pNode1"/>
        <xsl:param name="pNode2"/>
        <xsl:variable name="vDiffAtt">
            <!-- same number ... -->
            <xsl:if test="count($pNode1/@*)!=count($pNode2/@*)">
                <xsl:text>.</xsl:text>
            </xsl:if>
            <!-- ... and same name/content -->
            <xsl:for-each select="$pNode1/@*">
                <xsl:if test="not($pNode2/@*[local-name()=local-name(current()) and namespace-uri()=namespace-uri(current()) and .=current()])">
                    <xsl:text>.</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:value-of select="normalize-space($vDiffAtt)"/>
    </xsl:function>

    <xsl:function name="ae:is-normalized-text-different">
        <xsl:param name="pNode1"/>
        <xsl:param name="pNode2"/>
        <xsl:variable name="vDiffText">
            <xsl:if test="normalize-space(string-join($pNode1/text(), ' '))!=normalize-space(string-join($pNode2/text(), ' '))">
                <xsl:text>.</xsl:text>
            </xsl:if>
        </xsl:variable>

        <xsl:value-of select="normalize-space($vDiffText)"/>
    </xsl:function>


</xsl:stylesheet>