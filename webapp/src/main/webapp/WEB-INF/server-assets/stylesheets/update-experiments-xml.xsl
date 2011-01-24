<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                extension-element-prefixes="ae"
                exclude-result-prefixes="ae"
                version="2.0">

    <xsl:include href="ae-compare-experiments.xsl"/>

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-experiments.xml')"/>
    <xsl:variable name="vUpdateSource" select="$vUpdate/experiments/experiment[1]/source/@id"/>

    <xsl:template match="/experiments">
        <xsl:choose>
            <xsl:when test="string($vUpdateSource)">
                <xsl:message>[INFO] Updating from [<xsl:value-of select="$vUpdateSource"/>]</xsl:message>
                <xsl:variable name="vCombinedExperiments" select="experiment[source/@id != $vUpdateSource] | $vUpdate/experiments/experiment"/>
                <experiments total="{count($vCombinedExperiments)}">
                    <xsl:for-each-group select="$vCombinedExperiments" group-by="accession">
                        <xsl:variable name="vMigrated" select="count(current-group()) = 2"/>
                        <xsl:variable name="vIdentical">
                            <xsl:if test="$vMigrated">
                                <xsl:value-of select="ae:are-experiments-identical(current-group()[1], current-group()[2])"/>
                            </xsl:if>
                        </xsl:variable>
                        <xsl:for-each select="current-group()">
                            <!-- will copy all from ae2 and those from ae1 that are not migrated -->
                            <xsl:variable name="vVisible" select="source/@id = 'ae2' or not($vMigrated)"/>

                            <experiment>
                                <xsl:copy-of select="*[name() != 'source']|@*"/>
                                <source id="{source/@id}" migrated="{$vMigrated}" visible="{$vVisible}">
                                <xsl:if test="$vMigrated">
                                    <xsl:attribute name="identical" select="$vIdentical"/>
                                </xsl:if>
                                </source>
                            </experiment>
                        </xsl:for-each>

                    </xsl:for-each-group>
                </experiments>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>[WARN] Update source not defined, ignoring update</xsl:message>
                <xsl:copy-of select="/"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
