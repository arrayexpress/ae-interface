<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                extension-element-prefixes="ae"
                exclude-result-prefixes="ae"
                version="2.0">

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-protocols.xml')"/>
    <xsl:variable name="vUpdateSource" select="$vUpdate/protocols/protocol[1]/@source"/>

    <xsl:template match="/protocols">
        <xsl:choose>
            <xsl:when test="string($vUpdateSource)">
                <xsl:message>[INFO] Updating from [<xsl:value-of select="$vUpdateSource"/>]</xsl:message>
                <xsl:variable name="vCombinedProtocols" select="protocol[@source != $vUpdateSource] | $vUpdate/protocols/protocol"/>
                <protocols>
                    <xsl:for-each-group select="$vCombinedProtocols" group-by="accession">
                        <xsl:variable name="vMigrated" select="exists(current-group()[@source='ae1']) and exists(current-group()[@source='ae2'])"/>
                        <xsl:if test="count(current-group()) > 2">
                            <xsl:message>[ERROR] Multiple entries within one source for protocol [<xsl:value-of select="current-grouping-key()"/>]</xsl:message>
                        </xsl:if>
                        <xsl:for-each select="current-group()">
                            <xsl:sort select="@source" order="ascending"/>
                            <protocol>
                                <xsl:attribute name="source" select="@source"/>
                                <xsl:attribute name="migrated" select="$vMigrated"/>
                                <xsl:attribute name="visible" select="@source = 'ae2' or not($vMigrated)"/>
                                <xsl:copy-of select="*"/>
                            </protocol>
                        </xsl:for-each>
                    </xsl:for-each-group>
                </protocols>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>[WARN] Update source not defined, ignoring update</xsl:message>
                <xsl:copy-of select="/"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
