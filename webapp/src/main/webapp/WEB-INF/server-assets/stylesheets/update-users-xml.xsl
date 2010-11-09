<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/xslt"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="ae saxon"
                exclude-result-prefixes="ae saxon"
                version="2.0">

    <xsl:include href="ae-compare-experiments.xsl"/>

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-users.xml')"/>
    <xsl:variable name="vUpdateSource" select="$vUpdate/users/user[1]/@source"/>

    <xsl:template match="/users">
        <xsl:message>[INFO] Updating from [<xsl:value-of select="$vUpdateSource"/>]</xsl:message>
        <xsl:variable name="vCombinedUsers" select="user[@source != $vUpdateSource] | $vUpdate/users/user"/>
        <users>
            <xsl:for-each select="$vCombinedUsers">
                <xsl:if test="@source = 'ae1'">
<!--
                    <xsl:message>[INFO] Copying [<xsl:value-of select="name"/>], source [<xsl:value-of select="@source"/>]</xsl:message>
-->
                    <xsl:copy-of select="."/>
                </xsl:if>
                <xsl:if test="@source = 'ae2'">
<!--
                    <xsl:message>[INFO] Skipping [<xsl:value-of select="name"/>], source [<xsl:value-of select="@source"/>]</xsl:message>
-->
                </xsl:if>
            </xsl:for-each>
<!--
            <xsl:for-each-group select="$vCombinedUsers" group-by="accession">
                <xsl:variable name="vMigrated" select="count(current-group()) = 2"/>
                <xsl:variable name="vIdentical">
                    <xsl:if test="$vMigrated"><xsl:value-of select="ae:are-experiments-identical(current-group()[1], current-group()[2])"/></xsl:if>
                </xsl:variable>
                <xsl:for-each select="current-group()">
                    <xsl:variable name="vVisible" select="source/@id = 'ae2' or not($vMigrated)"/>
                    <xsl:message>[INFO] Copying [<xsl:value-of select="accession"/>], source [<xsl:value-of select="source/@id"/>], migrated [<xsl:value-of select="$vMigrated"/>], visible [<xsl:value-of select="$vVisible"/>], identical [<xsl:value-of select="$vIdentical"/>]</xsl:message>
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
-->
        </users>
    </xsl:template>

</xsl:stylesheet>
