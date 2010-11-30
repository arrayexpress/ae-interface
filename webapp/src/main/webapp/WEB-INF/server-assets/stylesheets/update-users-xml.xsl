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
                <user>
                    <xsl:attribute name="source" select="if (@source) then @source else $vUpdateSource"/>
                    <xsl:copy-of select="*"/>
                </user>
            </xsl:for-each>
        </users>
    </xsl:template>

</xsl:stylesheet>
