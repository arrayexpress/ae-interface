<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2015 European Molecular Biology Laboratory
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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                extension-element-prefixes="xs fn ae search"
                exclude-result-prefixes="xs fn ae search"
                version="2.0">

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'releasedate'"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'descending'"/>

    <xsl:param name="queryid"/>

    <xsl:param name="host"/>
    <xsl:param name="context-path"/>


    <xsl:variable name="vBaseUrl"><xsl:value-of select="$host"/><xsl:value-of select="$context-path"/></xsl:variable>
    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>

    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template name="root">
        <xsl:param name="pJson" as="xs:boolean"/>

        <xsl:variable name="vFilteredExperiments" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="fn:count($vFilteredExperiments)"/>

        <files api-version="2" api-revision="091015" version="1.2" revision="130311"
                     total-experiments="{$vTotal}">
            <xsl:call-template name="ae-sort-experiments">
                <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                <xsl:with-param name="pFrom"/>
                <xsl:with-param name="pTo"/>
                <xsl:with-param name="pSortBy" select="$vSortBy"/>
                <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
            </xsl:call-template>
        </files>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:variable name="vAccession" select="accession"/>
        <experiment>
            <accession><xsl:value-of select="$vAccession"/></accession>
            <xsl:variable name="vExpFolder" select="ae:getMappedValue('ftp-folder', $vAccession)"/>
            <xsl:for-each select="$vExpFolder/file">
                <xsl:call-template name="file-for-accession">
                    <xsl:with-param name="pAccession" select="$vAccession"/>
                    <xsl:with-param name="pFile" select="."/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="arraydesign">
                <xsl:sort select="accession" order="ascending"/>
                <xsl:variable name="vArrAccession" select="fn:string(accession)"/>
                <xsl:variable name="vArrFolder" select="ae:getMappedValue('ftp-folder', $vArrAccession)"/>

                <xsl:for-each select="$vArrFolder/file[@kind = 'adf']">
                    <xsl:call-template name="file-for-accession">
                        <xsl:with-param name="pAccession" select="$vArrAccession"/>
                        <xsl:with-param name="pFile" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
        </experiment>
    </xsl:template>

    <xsl:template name="file-for-accession">
        <xsl:param name="pAccession"/>
        <xsl:param name="pFile"/>
        
        <xsl:element name="file">
            <xsl:if test="$pFile/@*">
                <xsl:for-each select="$pFile/@*[fn:name() != 'owner' and fn:name() != 'group' and fn:name() != 'access' and fn:name() != 'hidden']">
                    <xsl:element name="{fn:lower-case(fn:name())}">
                        <xsl:value-of select="." />
                    </xsl:element>
                    <xsl:if test="'kind' = fn:name() and 'processed' = .">
                        <kind>fgem</kind>
                    </xsl:if>
                </xsl:for-each>

                <xsl:if test="$pFile/@name">
                    <xsl:element name="url">
                        <xsl:value-of select="$vBaseUrl"/>/files/<xsl:value-of select="$pAccession"/>/<xsl:value-of select="$pFile/@name"/>
                    </xsl:element>
                </xsl:if>
            </xsl:if>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>