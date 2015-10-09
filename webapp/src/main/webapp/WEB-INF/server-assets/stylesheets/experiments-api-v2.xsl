<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2014 European Molecular Biology Laboratory
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
    <xsl:param name="accession"/>
    <xsl:param name="userid"/>
    <xsl:param name="isreviewer"/>

    <xsl:param name="host"/>
    <xsl:param name="context-path"/>

    <xsl:variable name="vBaseUrl"><xsl:value-of select="$host"/><xsl:value-of select="$context-path"/></xsl:variable>

    <xsl:output omit-xml-declaration="no" method="xml" indent="no" encoding="UTF-8"/>
    
    <xsl:include href="ae-sort-experiments.xsl"/>

    <xsl:template name="root">
        <xsl:param name="pJson" as="xs:boolean"/>

        <xsl:variable name="vFilteredExperiments" select="if ($accession) then search:queryIndex('experiments', fn:concat('accession:', $accession, if ($userid) then fn:concat(' userid:(', $userid, ')') else ''))[accession = $accession] else search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" as="xs:integer" select="count($vFilteredExperiments)"/>

        <experiments api-version="2" api-revision="091015" version="1.2" revision="091015"
                     total="{$vTotal}"
                     total-samples="{sum($vFilteredExperiments/samples) cast as xs:integer}"
                     total-assays="{sum($vFilteredExperiments/assays) cast as xs:integer}">
            <xsl:call-template name="ae-sort-experiments">
                <xsl:with-param name="pExperiments" select="$vFilteredExperiments"/>
                <xsl:with-param name="pFrom"/>
                <xsl:with-param name="pTo"/>
                <xsl:with-param name="pSortBy" select="$vSortBy"/>
                <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
            </xsl:call-template>
        </experiments>
    </xsl:template>

    <xsl:template match="experiment">
        <xsl:variable name="vIsAnonymousReview" select="fn:not(user/@id = '1') and ($isreviewer = 'true') and source/@anonymousreview"/>
        <experiment>
            <xsl:copy-of select="*[fn:not(fn:name() = 'user' or fn:name() = 'source' or ($vIsAnonymousReview and (fn:name() = 'provider' or fn:name() = 'bibliography')))]"/>
            <files>
                <xsl:comment>
This section is deprecated and unsupported.
Please use webservice located at:
    <xsl:value-of select="$vBaseUrl"/>/xml/files
to obtain detailed information on files available for the experiment.
For more information, please go to:
    http://www.ebi.ac.uk/arrayexpress/help/programmatic_access.html
                </xsl:comment>
                <xsl:variable name="vAccession" select="accession"/>
                <xsl:variable name="vExpFolder" select="ae:getMappedValue('ftp-folder', $vAccession)"/>
                <xsl:if test="$vExpFolder/file[@kind = 'raw']">
                    <raw name="{$vExpFolder/file[@kind = 'raw']/@name}"
                         count="{rawdatafiles/@available}"
                         celcount="{sum(bioassaydatagroup[isderived = '0'][contains(dataformat, 'CEL')]/bioassays)}"/>
                </xsl:if>
                <xsl:if test="$vExpFolder/file[@kind = 'processed']">
                    <fgem name="{$vExpFolder/file[@kind = 'processed']/@name}"
                          available="{processeddatafiles/@available}"/>
                </xsl:if>
                <xsl:if test="$vExpFolder/file[@kind = 'idf' and @extension = 'txt']">
                    <idf name="{$vExpFolder/file[@kind = 'idf' and @extension = 'txt']/@name}"/>
                </xsl:if>
                <xsl:if test="$vExpFolder/file[@kind = 'sdrf' and @extension = 'txt']">
                    <sdrf name="{$vExpFolder/file[@kind = 'sdrf' and @extension = 'txt']/@name}"/>
                </xsl:if>
                <xsl:if test="$vExpFolder/file[@kind = 'biosamples']">
                    <biosamples>
                        <xsl:if test="$vExpFolder/file[@kind = 'biosamples' and @extension = 'png']">
                            <png name="{$vExpFolder/file[@kind = 'biosamples' and @extension = 'png']/@name}"/>
                        </xsl:if>
                        <xsl:if test="$vExpFolder/file[@kind = 'biosamples' and @extension = 'svg']">
                            <svg name="{$vExpFolder/file[@kind = 'biosamples' and @extension = 'svg']/@name}"/>
                        </xsl:if>
                    </biosamples>
                </xsl:if>
            </files>
        </experiment>
    </xsl:template>

</xsl:stylesheet>