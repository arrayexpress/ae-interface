<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="aejava fn saxon"
                exclude-result-prefixes="aejava fn saxon html"
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/experiments">
        <experiments
            version="{@version}" total="{fn:count(experiment)}">

            <xsl:apply-templates select="experiment">
                <xsl:sort select="substring-before(releasedate, '-')" order="descending" data-type="number"/>
                <xsl:sort select="substring-before(substring-after(releasedate, '-'), '-')" order="descending" data-type="number"/>
                <xsl:sort select="substring-after(substring-after(releasedate, '-'), '-')" order="descending"  data-type="number"/>
            </xsl:apply-templates>
        </experiments>
    </xsl:template>

    <xsl:template match="experiment">
        <experiment>
            <xsl:variable name="vAccession" select="accession"/>

            <xsl:if test="aejava:getAcceleratorValue('is-in-atlas', $vAccession)">
                <xsl:attribute name="loadedinatlas">true</xsl:attribute>
            </xsl:if>
            <source id="ae2"/>

            <xsl:if test="count(seqdatauri) > 1">
                <xsl:message>[WARN] More than one sequence data URI defined for experiment [<xsl:value-of select="$vAccession"/>]</xsl:message>
            </xsl:if>
            <xsl:for-each select="fn:distinct-values(sampleattribute[@category = 'Organism']/@value, 'http://saxon.sf.net/collation?ignore-case=yes')">
                <species><xsl:value-of select="."/></species>
            </xsl:for-each>

            <xsl:for-each-group select="sampleattribute[@value != '']" group-by="@category">
                <xsl:sort select="fn:lower-case(@category)" order="ascending"/>
                <sampleattribute>
                    <category><xsl:value-of select="@category"/></category>
                    <xsl:for-each select="current-group()">
                        <xsl:sort select="fn:lower-case(@value)" order="ascending"/>
                        <value><xsl:value-of select="@value"/></value>
					</xsl:for-each>
                </sampleattribute>
            </xsl:for-each-group>
            <xsl:for-each-group select="experimentalfactor[@value != '']" group-by="@name">
                <xsl:sort select="fn:lower-case(@name)" order="ascending"/>
                <experimentalfactor>
                    <name><xsl:value-of select="@name"/></name>
                    <xsl:for-each select="current-group()">
                        <xsl:sort select="fn:lower-case(@value)" order="ascending"/>
                        <value><xsl:value-of select="@value"/></value>
					</xsl:for-each>
                </experimentalfactor>
            </xsl:for-each-group>
            <xsl:variable name="vScoreName" select="if (miamescore[@name = 'AEMINSEQEScore']) then 'minseqe' else 'miame'"/>
            <xsl:choose>
                <xsl:when test="false()"/>
                <!--
                <xsl:when test="count(miamescore[@name = 'AEMIAMEScore' or @name = 'AEMINSEQEScore']) > 1">
                    <xsl:message>[ERROR] Multiple overall scores defined for experiment [<xsl:value-of select="$vAccession"/>]</xsl:message>
                </xsl:when>
                <xsl:when test="count(miamescore[@name != 'AEMIAMEScore' and @name != 'AEMINSEQEScore']) != 5">
                    <xsl:message>[ERROR] Individual scores (count [<xsl:value-of select="count(miamescore[@name != 'AEMIAMEScore' and @name != 'AEMINSEQEScore'])"/>]) poorly defined for experiment [<xsl:value-of select="$vAccession"/>]</xsl:message>
                </xsl:when>
                <xsl:when test="miamescore[@name = fn:concat('AE', fn:upper-case($vScoreName), 'Score')]/@value != fn:sum(miamescore[@name != 'AEMIAMEScore' and @name != 'AEMINSEQEScore']/@value)">
                    <xsl:message>[ERROR] Overall score [<xsl:value-of select="miamescore[@name = fn:concat('AE', fn:upper-case($vScoreName), 'Score')]/@value"/>] is not consitent with individual ones for experiment [<xsl:value-of select="$vAccession"/>]</xsl:message>
                </xsl:when> -->
                <xsl:otherwise>
                    <!--
                    <xsl:message>[INFO] Processing score for experiment [<xsl:value-of select="$vAccession"/>]</xsl:message>
                    -->
                    <xsl:element name="{fn:concat($vScoreName, 'scores')}">
                        <xsl:for-each select="miamescore[@name != 'AEMIAMEScore' and @name != 'AEMINSEQEScore']">
                            <xsl:element name="{fn:lower-case(@name)}">
                                <xsl:value-of select="@value"/>
                            </xsl:element>
                        </xsl:for-each>
                        <overallscore>
                            <xsl:value-of select="fn:sum(miamescore[@name != 'AEMIAMEScore' and @name != 'AEMINSEQEScore']/@value)"/>
                        </overallscore>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*" mode="copy" />
        </experiment>
    </xsl:template>

    <!-- this template prohibits default copying of these elements -->
    <xsl:template match="sampleattribute | experimentalfactor | miamescore" mode="copy"/>

    <xsl:template match="submissiondate | lastupdatedate | releasedate" mode="copy">
        <xsl:choose>
            <xsl:when test="matches(text(), '^\d{4}-\d{2}-\d{2}$')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="string-length(text()) > 0">
                    <xsl:message>[ERROR] Element [<xsl:value-of select="name()"/>] contains invalid date [<xsl:value-of select="text()"/>], experiment [<xsl:value-of select="../accession"/>]</xsl:message>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="user" mode="copy">
        <user id="{text()}"/>
    </xsl:template>

    <xsl:template match="hybs" mode="copy">
        <assays><xsl:value-of select="."/></assays>
    </xsl:template>

    <xsl:template match="name" mode="copy">
        <name>
            <xsl:apply-templates mode="html" select="saxon:parse-html(fn:concat('&lt;body&gt;', ., '&lt;/body&gt;'))" />
        </name>
    </xsl:template>

    <xsl:template match="secondaryaccession" mode="copy">
        <xsl:choose>
            <xsl:when test="fn:string-length(.) = 0"/>
            <xsl:when test="fn:contains(., ';G')">
            <xsl:variable name="vValues" select="fn:tokenize(., '\s*;\s*')"/>
                <xsl:for-each select="$vValues">
                    <xsl:element name="secondaryaccession">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="experimentdesign | experimenttype" mode="copy">
        <xsl:variable name="vName" select="fn:name()"/>
        <xsl:variable name="vValues" select="fn:tokenize(., '\s*,\s*')"/>
        <xsl:for-each select="$vValues">
            <xsl:element name="{$vName}">
                <xsl:value-of select="fn:replace(fn:replace(., '_design', ''), '_', ' ')"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="bibliography" mode="copy">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:variable name="vAttrName" select="fn:lower-case(fn:name())"/>
                <xsl:variable name="vAttrValue" select="."/>
                <xsl:choose>
                    <xsl:when test="$vAttrName = 'pages' and ($vAttrValue = '' or $vAttrValue = '-')"/>
                    <xsl:otherwise>
                        <xsl:element name="{$vAttrName}">
                            <xsl:value-of select="$vAttrValue" />
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="description" mode="copy">
        <description>
            <id><xsl:value-of select="@id"/></id>
            <text>
                <xsl:apply-templates mode="html" select="saxon:parse-html(fn:concat('&lt;body&gt;', fn:replace(fn:replace(fn:replace(fn:replace(., '&lt;', '&amp;lt;', 'i'), '&amp;lt;(/?)(a|ahref|br)', '&lt;$1$2', 'i'), '(^|[^&quot;])(https?|ftp)(:[/][/][a-zA-Z0-9_~\-\$&amp;\+,\./:;=\?@]+[a-zA-Z0-9_~\-\$&amp;\+,/:;=\?@])([^&quot;]|$)', '$1&lt;a href=&quot;$2$3&quot; target=&quot;_blank&quot;&gt;$2$3&lt;/a&gt;$4', 'i'), '&lt;ahref=', '&lt;a href=', 'i'), '&lt;/body&gt;'))" />
            </text>
        </description>
    </xsl:template>

    <xsl:template match="*" mode="copy">
        <xsl:copy>
            <xsl:if test="@*">
                <xsl:for-each select="@*">
                    <xsl:element name="{fn:lower-case(fn:name())}">
                        <xsl:value-of select="." />
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
            <xsl:apply-templates mode="copy" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="html:html | html:body" mode="html">
        <xsl:apply-templates mode="html"/>
    </xsl:template>

    <xsl:template match="html:*" mode="html">
        <xsl:element name="{fn:name()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{fn:name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates mode="html"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>