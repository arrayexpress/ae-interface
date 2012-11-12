<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae fn saxon"
                exclude-result-prefixes="ae fn saxon html"
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

            <xsl:if test="ae:getMappedValue('experiments-in-atlas', $vAccession)">
                <xsl:attribute name="loadedinatlas">true</xsl:attribute>
            </xsl:if>

            <source id="ae2"/>

            <xsl:if test="count(seqdatauri) > 1">
                <xsl:message>[WARN] More than one sequence data URI defined for experiment [<xsl:value-of select="$vAccession"/>]</xsl:message>
            </xsl:if>

            <xsl:if test="count(name) > 1">
                <xsl:message>[WARN] More than one experiment title defined for experiment [<xsl:value-of select="$vAccession"/>]</xsl:message>
            </xsl:if>

            <xsl:for-each select="fn:distinct-values(sampleattribute[@category = 'Organism']/@value, 'http://saxon.sf.net/collation?ignore-case=yes')">
                <species><xsl:value-of select="."/></species>
            </xsl:for-each>

            <rawdatafiles>
                <xsl:attribute name="available" select="ae:getMappedValue('raw-files', $vAccession) &gt; 0"/>
            </rawdatafiles>
            <fgemdatafiles>
                <xsl:attribute name="available" select="((ae:getMappedValue('fgem-files', $vAccession) &gt; 0) or $vAccession = 'E-GEUV-1')"/>
            </fgemdatafiles>

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
            <!-- process miame scores -->
            <xsl:if test="miamescore[@name = 'AEMIAMEScore']">
                <miamescores>
                    <reportersequencescore><xsl:value-of select="miamescore[@name = 'ReporterSequenceScore']/@value"/></reportersequencescore>
                    <protocolscore><xsl:value-of select="miamescore[@name = 'ProtocolScore']/@value"/></protocolscore>
                    <factorvaluescore><xsl:value-of select="miamescore[@name = 'FactorValueScore']/@value"/></factorvaluescore>
                    <derivedbioassaydatascore><xsl:value-of select="miamescore[@name = 'DerivedBioAssayDataScore']/@value"/></derivedbioassaydatascore>
                    <measuredbioassaydatascore><xsl:value-of select="miamescore[@name = 'MeasuredBioAssayDataScore']/@value"/></measuredbioassaydatascore>
                    <overallscore><xsl:value-of select="sum(miamescore[@name = 'ReporterSequenceScore' or @name = 'ProtocolScore' or @name = 'FactorValueScore' or @name = 'DerivedBioAssayDataScore' or @name = 'MeasuredBioAssayDataScore']/@value)"/></overallscore>
                </miamescores>
            </xsl:if>
            <!-- process minseqe scores -->
            <xsl:if test="miamescore[@name = 'AEMINSEQEScore']">
                <minseqescores>
                    <experimentdesignscore>1</experimentdesignscore>
                    <protocolscore><xsl:value-of select="miamescore[@name = 'ProtocolScore']/@value"/></protocolscore>
                    <factorvaluescore><xsl:value-of select="miamescore[@name = 'FactorValueScore']/@value"/></factorvaluescore>
                    <derivedbioassaydatascore><xsl:value-of select="miamescore[@name = 'DerivedBioAssayDataScore']/@value"/></derivedbioassaydatascore>
                    <measuredbioassaydatascore><xsl:value-of select="miamescore[@name = 'MeasuredBioAssayDataScoreMINSEQE']/@value"/></measuredbioassaydatascore>
                    <overallscore><xsl:value-of select="sum(miamescore[@name = 'ProtocolScore' or @name = 'FactorValueScore' or @name = 'DerivedBioAssayDataScore' or @name = 'MeasuredBioAssayDataScoreMINSEQE']/@value) + 1"/></overallscore>
                </minseqescores>
            </xsl:if>
            <xsl:if test="seqdatauri">
                <seqdatauri>
                    <xsl:choose>
                        <xsl:when test="count(seqdatauri) > 1  and contains(seqdatauri[1], '/ena/')">
                            <xsl:for-each select="seqdatauri">
                                <xsl:choose>
                                    <xsl:when test="fn:position() = 1">
                                        <xsl:value-of select="text()"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="fn:replace(text(), '^.*/([^/]+)$', ',$1')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="seqdatauri"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </seqdatauri>
            </xsl:if>
            <xsl:apply-templates select="*" mode="copy" />
        </experiment>
    </xsl:template>

    <!-- this template prohibits default copying of these elements -->
    <xsl:template match="sampleattribute | experimentalfactor | miamescore | seqdatauri" mode="copy"/>

    <xsl:template match="arraydesign" mode="copy">
        <arraydesign>
            <xsl:for-each select="@*">
                <xsl:element name="{fn:lower-case(fn:name())}">
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:for-each>
            <xsl:copy-of select="ae:getMappedValue('array-legacy-ids', @accession)"/>
        </arraydesign>
    </xsl:template>

    <xsl:template match="species" mode="copy">
        <xsl:choose>
            <xsl:when test="fn:matches(., '^\s*$')">
                <xsl:message>[WARN] Empty species element found for experiment [<xsl:value-of select="./ancestor::node()/accession"/>]</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <species><xsl:value-of select="."/></species>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


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

    <xsl:template match="experimentdesign" mode="copy">
        <xsl:variable name="vValue" select="fn:replace(fn:replace(., '_design', ''), '_', ' ')"/>
        <xsl:if test="not(fn:index-of((../experimenttype), $vValue))">
            <experimentdesign>
                <xsl:value-of select="$vValue"/>
            </experimentdesign>
        </xsl:if>
    </xsl:template>

    <xsl:template match="bibliography" mode="copy">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:variable name="vAttrName" select="fn:lower-case(fn:name())"/>
                <xsl:variable name="vAttrValue" select="."/>
                <xsl:choose>
                    <xsl:when test="$vAttrValue = '' or $vAttrValue = '-'"/>
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
        <xsl:element name="{fn:local-name()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{fn:local-name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates mode="html"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>