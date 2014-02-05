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
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:html="http://www.w3.org/1999/xhtml"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
        extension-element-prefixes="ae"
        exclude-result-prefixes="ae fn html"
        version="2.0">

    <xsl:output omit-xml-declaration="yes" method="html" encoding="UTF-8" />

    <xsl:template match="/experiments">
        <option value="">All organisms</option>
        <xsl:variable name="vTopSpecies">
            <xsl:for-each-group select="experiment[source/@visible = 'true']/organism" group-by="ae:normalize-species(.)" collation="http://saxon.sf.net/collation?ignore-case=yes">
                <xsl:sort select="fn:count(current-group()/ancestor::node())" data-type="number" order="descending"/>
                <xsl:if test="fn:count(current-group()/ancestor::node()) &gt;= 250">
                    <option>
                        <xsl:attribute name="value" select="fn:current-grouping-key()"/>
                        <xsl:value-of select="fn:current-grouping-key()"/>
                    </option>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:variable>
        <option disabled="true" value="-">&#x2500;&#x2500; Top organisms &#x2500;&#x2500;</option>
        <xsl:for-each select="$vTopSpecies/option">
            <xsl:sort select="@value"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
        <option disabled="true" value="-">&#x2500;&#x2500;  Organisms (A&#x2192;Z) &#x2500;&#x2500;</option>
        <xsl:for-each-group select="experiment[source/@visible = 'true']/organism" group-by="ae:normalize-species(.)" collation="http://saxon.sf.net/collation?ignore-case=yes">
            <xsl:sort select="fn:current-grouping-key()"/>
            <option>
                <xsl:attribute name="value" select="fn:current-grouping-key()"/>
                <xsl:value-of select="fn:current-grouping-key()"/>
            </option>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:function name="ae:normalize-species">
        <xsl:param name="pSpecies"/>
        <xsl:choose>
            <xsl:when test="fn:matches($pSpecies, '^\s*$')">
                <xsl:text>Unknown</xsl:text>
            </xsl:when>
            <xsl:when test="fn:matches($pSpecies, '^\w+$')">
                <xsl:value-of select="
                    fn:concat(
                    fn:upper-case(fn:substring($pSpecies, 1, 1))
                    , fn:lower-case(fn:substring($pSpecies, 2))
                    )"/>
            </xsl:when>
            <xsl:when test="fn:matches($pSpecies, '\s[xX]\s')">
                <xsl:value-of select="$pSpecies"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="vTransformedSpecies" select="
                    fn:concat(
                        fn:normalize-space(
                            fn:replace(
                                fn:replace($pSpecies, '\W\(\w+\)\W', ' ')
                                , '(\w|^)[\s.,=_'']+(\w|$)'
                                , '$1 $2'
                            )
                        )
                        , ' '
                    )"/>
                <xsl:value-of select="
                    fn:concat(
                        fn:upper-case(fn:substring($vTransformedSpecies, 1, 1))
                        , fn:lower-case(fn:substring(fn:substring-before($vTransformedSpecies, ' '), 2))
                        , ' '
                        , fn:lower-case(fn:substring-before(fn:substring-after($vTransformedSpecies, ' '), ' '))
                    )"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
