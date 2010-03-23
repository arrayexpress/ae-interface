<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                extension-element-prefixes="fn search"
                exclude-result-prefixes="fn search"
                version="2.0">

    <xsl:param name="sortby">releasedate</xsl:param>
    <xsl:param name="sortorder">descending</xsl:param>

    <xsl:param name="queryid"/>

    <!-- dynamically set by QueryServlet: host name (as seen from client) and base context path of webapp -->
    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="ISO-8859-1"/>

    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template match="/experiments">

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex('experiments', $queryid)"/>
        <xsl:variable name="vTotal" select="fn:count($vFilteredExperiments)"/>

        <database>
            <name>ArrayExpress Archive</name>
            <description>The ArrayExpress Archive is a database of functional genomics experiments</description>
            <release>1.2.1</release>
            <release_date><xsl:value-of select="fn:format-date(fn:current-date(), '[D01]-[MN,*-3]-[Y0001]')"/></release_date>
            <entry_count><xsl:value-of select="$vTotal"/></entry_count>
            <entries>
                <xsl:call-template name="ae-sort-experiments">
                    <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                    <xsl:with-param name="pFrom"/>
                    <xsl:with-param name="pTo"/>
                    <xsl:with-param name="pSortBy" select="$sortby"/>
                    <xsl:with-param name="pSortOrder" select="$sortorder"/>
                </xsl:call-template>
            </entries>
        </database>
    </xsl:template>

    <xsl:template match="experiment">
        <entry acc="{accession}" id="{id}">
            <name><xsl:value-of select="name"/></name>
            <description><xsl:value-of select="fn:string-join(description[fn:string-length(text) > 0 and not(fn:starts-with(text, '(Generated description)'))]/text, '\n')"/></description>
            <authors><xsl:value-of select="fn:string-join(provider[role = 'submitter']/contact, ', ')"/></authors>
            <keywords><xsl:value-of select="fn:string-join(experimentdesign, ', ')"/></keywords>
            <dates><date type="release" value="{releasedate}"/></dates>
            <cross_references>
                <xsl:if test="@loadedinatlas">
                    <ref dbkey="{accession}" dbname="ArrayExpress Warehouse"/>
                </xsl:if>
                <xsl:for-each select="fn:distinct-values(secondaryaccession[fn:starts-with(., 'GSE') or fn:starts-with(., 'GDS')])">
                    <ref dbkey="{.}" dbname="GEO"/>
                </xsl:for-each>
                <xsl:for-each select="fn:distinct-values(bibliography/accession)">
                    <ref dbkey="{.}" dbname="MEDLINE"/>
                </xsl:for-each>
            </cross_references>
            <additional_fields>
                <xsl:for-each select="sampleattribute">
                    <xsl:for-each select="value">
                        <field name="bioMaterial-characteristics">
                            <xsl:value-of select="../category"/>
                            <xsl:text> - </xsl:text>
                            <xsl:value-of select="."/>
                        </field>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:for-each select="experimentalfactor">
                    <xsl:for-each select="value">
                        <field name="experimentalFactors-factorValues">
                            <xsl:value-of select="../name"/>
                            <xsl:text> - </xsl:text>
                            <xsl:value-of select="."/>
                        </field>
                    </xsl:for-each>
                </xsl:for-each>
            </additional_fields>
        </entry>
    </xsl:template>

</xsl:stylesheet>