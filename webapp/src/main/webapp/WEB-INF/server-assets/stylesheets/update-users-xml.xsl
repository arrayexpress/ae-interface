<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                extension-element-prefixes="ae"
                exclude-result-prefixes="ae"
                version="2.0">

    <xsl:include href="ae-compare-experiments.xsl"/>

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:variable name="vUpdate" select="doc('update-users.xml')"/>
    <xsl:variable name="vUpdateSource" select="$vUpdate/users/user[1]/@source"/>

    <xsl:template match="/users">
        <xsl:message>[INFO] Updating from [<xsl:value-of select="$vUpdateSource"/>]</xsl:message>
        <xsl:variable name="vCombinedUsers" select="user[@source != $vUpdateSource] | $vUpdate/users/user"/>
        <xsl:for-each-group select="$vCombinedUsers" group-by="id">
            <xsl:if test="count(current-group()) > 1">
                <xsl:message>[ERROR] More than one user with ID [<xsl:value-of select="current-grouping-key()"/>] found</xsl:message>
            </xsl:if>
        </xsl:for-each-group>
        <users>
            <xsl:for-each-group select="$vCombinedUsers" group-by="name">
                <xsl:if test="count(current-group()) > 2">
                    <xsl:message>[ERROR] Multiple entries within one source for user [<xsl:value-of select="current-grouping-key()"/>]</xsl:message>
                </xsl:if>
                <xsl:variable name="vMigrated" select="exists(current-group()[@source='ae1']) and exists(current-group()[@source='ae2'])"/>
                <xsl:if test="$vMigrated">
                    <xsl:if test="current-group()[1]/email != current-group()[2]/email">
                        <xsl:message>[WARN] Emails are different for user [<xsl:value-of select="current-grouping-key()"/>]</xsl:message>
                    </xsl:if>
                    <xsl:if test="current-group()[1]/password != current-group()[2]/password">
                        <xsl:message>[ERROR] Passwords are different for user [<xsl:value-of select="current-grouping-key()"/>]</xsl:message>
                    </xsl:if>
                </xsl:if>
                <xsl:for-each select="current-group()">
                    <xsl:sort select="@source" order="ascending"/>
                    <user>
                        <xsl:attribute name="source" select="@source"/>
                        <xsl:attribute name="migrated" select="$vMigrated"/>
                        <xsl:copy-of select="*"/>
                    </user>
                </xsl:for-each>
            </xsl:for-each-group>
        </users>
    </xsl:template>

</xsl:stylesheet>
