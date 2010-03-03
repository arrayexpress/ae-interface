<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                extension-element-prefixes="ae"
                exclude-result-prefixes="ae"
                version="2.0">
    <xsl:output method="xml" encoding="ISO-8859-1" indent="no"/>

    <xsl:key name="experiment-sampleattribute-by-category" match="sampleattribute" use="concat(ancestor::experiment/@id, @category)"/>
    <xsl:key name="experiment-experimentalfactor-by-name" match="experimentalfactor" use="concat(ancestor::experiment/@id, @name)"/>
    
    <xsl:template match="/experiments">
        <experiments
            version="{@version}" total="{count(experiment)}">

            <xsl:apply-templates select="experiment">
                <xsl:sort order="descending" select="year-from-date(@releasedate)" data-type="number"/>
                <xsl:sort order="descending" select="month-from-date(@releasedate)" data-type="number"/>
                <xsl:sort order="descending" select="day-from-date(@releasedate)" data-type="number"/>
            </xsl:apply-templates>
        </experiments>
    </xsl:template>

    <xsl:template match="experiment">
        <experiment>
            <xsl:variable name="vAccession" select="@accession"/>
            <xsl:variable name="vGenDescription">
                <xsl:variable name="vGenDescriptionRaw" select="description[starts-with(text(), '(Generated description)')]"/>
                <xsl:choose>
                    <xsl:when test="count($vGenDescriptionRaw) > 1">
                        <xsl:message>[WARN] Multiple generated descriptions found for [<xsl:value-of select="$vAccession"/>]</xsl:message>
                    </xsl:when>
                    <xsl:when test="count($vGenDescriptionRaw) = 0">
                        <xsl:message>[ERROR] No generated descriptions found for [<xsl:value-of select="$vAccession"/>]</xsl:message>
                        <hybs>0</hybs>
                        <samples>0</samples>
                        <rawdatafiles>0</rawdatafiles>
                        <fgemdatafiles>0</fgemdatafiles>
                    </xsl:when>
                </xsl:choose>
                <xsl:analyze-string select="string($vGenDescriptionRaw[1])" regex="with\s(\d+)\shybridizations.+using\s(\d*)\s*samples.+producing\s(\d+)\sraw.+and\s(\d+)\stransformed" flags="i">
                    <xsl:matching-substring>
                        <hybs><xsl:value-of select="regex-group(1)"/></hybs>
                        <samples><xsl:value-of select="regex-group(2)"/></samples>
                        <rawdatafiles><xsl:value-of select="regex-group(3)"/></rawdatafiles>
                        <fgemdatafiles><xsl:value-of select="regex-group(4)"/></fgemdatafiles>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:if test="ae:isExperimentInAtlas(@accession)">
                <xsl:attribute name="loadedinatlas">true</xsl:attribute>
            </xsl:if>
            <xsl:for-each select="@*">
                <xsl:element name="{lower-case(name())}">
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:for-each>

            <xsl:for-each select="distinct-values(sampleattribute[@category = 'Organism']/@value, 'http://saxon.sf.net/collation?ignore-case=yes')">
                <species><xsl:value-of select="."/></species>
            </xsl:for-each>

            <miamescores>
                <xsl:for-each select="miamescore">
                    <xsl:element name="{lower-case(@name)}">
                        <xsl:value-of select="@value"/>
                    </xsl:element>
                </xsl:for-each>
                <overallscore>
                    <xsl:value-of select="sum(miamescore/@value)"/>
                </overallscore>
            </miamescores>
            <assays>
                <xsl:choose>
                    <xsl:when test="$vGenDescription/hybs > 0">
                        <xsl:value-of select="$vGenDescription/hybs"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="bioassaydatagroup[@isderived = '1']">
                                <xsl:value-of select="sum(bioassaydatagroup[@isderived = '1']/@bioassays)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="bioassaydatagroup[@isderived = '0']">
                                        <xsl:value-of select="sum(bioassaydatagroup[@isderived = '0']/@bioassays)"/>
                                    </xsl:when>
                                    <xsl:otherwise>0</xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </assays>
            <samples>
                <xsl:choose>
                    <xsl:when test="number($vGenDescription/samples) > 0">
                        <xsl:value-of select="$vGenDescription/samples"/>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>    
                </xsl:choose>
            </samples>
            <rawdatafiles>
                <xsl:value-of select="$vGenDescription/rawdatafiles"/>
            </rawdatafiles>
            <fgemdatafiles>
                <xsl:value-of select="$vGenDescription/fgemdatafiles"/>    
            </fgemdatafiles>
            <xsl:for-each select="sampleattribute[@category][generate-id() = generate-id(key('experiment-sampleattribute-by-category', concat(ancestor::experiment/@id, @category))[1])]">
                <xsl:sort select="lower-case(@category)" order="ascending"/>
                <sampleattribute>
                    <category><xsl:value-of select="@category"/></category>
                    <xsl:for-each select="key('experiment-sampleattribute-by-category', concat(ancestor::experiment/@id, @category))">
                        <xsl:sort select="lower-case(@value)" order="ascending"/>
                        <value><xsl:value-of select="@value"/></value>
					</xsl:for-each>
                </sampleattribute>
            </xsl:for-each>
            <xsl:for-each select="experimentalfactor[@name][generate-id() = generate-id(key('experiment-experimentalfactor-by-name', concat(ancestor::experiment/@id, @name))[1])]">
                <xsl:sort select="lower-case(@name)" order="ascending"/>
                <experimentalfactor>
                    <name><xsl:value-of select="@name"/></name>
                    <xsl:for-each select="key('experiment-experimentalfactor-by-name', concat(ancestor::experiment/@id, @name))">
                        <xsl:sort select="lower-case(@value)" order="ascending"/>
                        <value><xsl:value-of select="@value"/></value>
					</xsl:for-each>
                </experimentalfactor>
            </xsl:for-each>
            <xsl:apply-templates select="*" mode="copy" />
        </experiment>
    </xsl:template>

    <!-- this template prohibits default copying of these elements -->
    <xsl:template match="sampleattribute | experimentalfactor | miamescore" mode="copy"/>

    <xsl:template match="secondaryaccession" mode="copy">
        <xsl:choose>
            <xsl:when test="string-length(.) = 0"/>
            <xsl:when test="contains(., ';GDS')">
                <xsl:call-template name="split-string-to-elements">
                    <xsl:with-param name="str" select="."/>
                    <xsl:with-param name="separator" select="';'"/>
                    <xsl:with-param name="element" select="'secondaryaccession'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="experimentdesign" mode="copy">
        <xsl:call-template name="split-string-to-elements">
            <xsl:with-param name="str" select="."/>
            <xsl:with-param name="separator" select="','"/>
            <xsl:with-param name="element" select="'experimentdesign'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="experimenttype" mode="copy">
        <xsl:call-template name="split-string-to-elements">
            <xsl:with-param name="str" select="."/>
            <xsl:with-param name="separator" select="','"/>
            <xsl:with-param name="element" select="'experimenttype'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="bibliography" mode="copy">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:variable name="vAttrName" select="lower-case(name())"/>
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
            <text><xsl:value-of select="."/></text>
        </description>
    </xsl:template>

    <xsl:template match="*" mode="copy">
        <xsl:copy>
            <xsl:if test="@*">
                <xsl:for-each select="@*">
                    <xsl:element name="{lower-case(name())}">
                        <xsl:value-of select="." />
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
            <xsl:apply-templates mode="copy" />
        </xsl:copy>
    </xsl:template>

    <xsl:template name="split-string-to-elements">
        <xsl:param name="str"/>
        <xsl:param name="separator"/>
        <xsl:param name="element"/>
        <xsl:choose>
            <xsl:when test="string-length($str) = 0"/>
            <xsl:when test="contains($str, $separator)">
                <xsl:element name="{$element}"><xsl:value-of select="substring-before($str, $separator)"/></xsl:element>
                <xsl:call-template name="split-string-to-elements">
                    <xsl:with-param name="str" select="substring-after($str, $separator)"/>
                    <xsl:with-param name="separator" select="$separator"/>
                    <xsl:with-param name="element" select="$element"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$element}"><xsl:value-of select="$str"/></xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>