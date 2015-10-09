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
                xmlns:json="http://json.org/"
                extension-element-prefixes="ae search json"
                exclude-result-prefixes="xs fn ae search json"
                version="2.0">

    <xsl:param name="host"/>
    <xsl:param name="context-path"/>
    <xsl:param name="accession"/>

    <xsl:variable name="vBaseUrl"><xsl:value-of select="$host"/><xsl:value-of select="$context-path"/></xsl:variable>
    <xsl:variable name="vFileUrl" select="fn:concat($vBaseUrl, '/files/')"/>
    <xsl:variable name="vAccession" select="fn:upper-case($accession)"/>
    <xsl:variable name="vData" select="search:queryIndex('files', fn:concat('accession:', $vAccession))"/>
    <xsl:variable name="vSampleFiles" select="$vData[@kind = 'sdrf' and @extension = 'txt']"/>

    <xsl:template name="root">
        <xsl:param name="pJson" as="xs:boolean"/>

        <experiment api-version="3" api-revision="091015" version="1.0" revision="091015">
            <accession><xsl:value-of select="$vAccession"/></accession>
            <xsl:for-each select="$vSampleFiles">
                <xsl:variable name="vTable" select="ae:tabularDocument($vAccession, @name, '- -header=1')/table"/>
                <xsl:variable name="vHeader" select="$vTable/header"/>
                <xsl:for-each select="$vTable/row">
                    <xsl:sort select="@seq" data-type="number" order="ascending"/>
                    <xsl:variable name="vRow" select="."/>
                    <sample>
                        <xsl:if test="$pJson">
                            <xsl:attribute name="json:force-array" namespace="http://json.org/" select="$pJson"/>
                        </xsl:if>
                        <xsl:for-each select="$vHeader/col">
                            <xsl:variable name="vPos" select="fn:position()"/>
                            <xsl:call-template name="sample-element">
                                <xsl:with-param name="pPos" select="$vPos"/>
                                <xsl:with-param name="pHeader" select="."/>
                                <xsl:with-param name="pCell" select="$vRow/col[$vPos]"/>
                                <xsl:with-param name="pJson" select="$pJson"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </sample>
                </xsl:for-each>
            </xsl:for-each>
        </experiment>
    </xsl:template>

    <xsl:template name="sample-element">
        <xsl:param name="pPos"/>
        <xsl:param name="pHeader"/>
        <xsl:param name="pCell"/>
        <xsl:param name="pJson"/>
        <xsl:variable name="vName" select="ae:normaliseHeader($pHeader)"/>
        <xsl:choose>
            <xsl:when test="$vName = 'sourcename'">
                <source>
                    <name><xsl:value-of select="$pCell"/></name>
                    <xsl:call-template name="comment-element">
                        <xsl:with-param name="pHeader" select="$pHeader/following-sibling::col"/>
                        <xsl:with-param name="pCell" select="$pCell/following-sibling::col"/>
                    </xsl:call-template>
                </source>
            </xsl:when>
            <xsl:when test="$vName = 'extractname'">
                <extract>
                    <name><xsl:value-of select="$pCell"/></name>
                    <xsl:call-template name="comment-element">
                        <xsl:with-param name="pHeader" select="$pHeader/following-sibling::col"/>
                        <xsl:with-param name="pCell" select="$pCell/following-sibling::col"/>
                    </xsl:call-template>
                </extract>
            </xsl:when>
            <xsl:when test="$vName = 'labeledextractname'">
                <labeled-extract>
                    <name><xsl:value-of select="$pCell"/></name>
                    <xsl:for-each select="$pHeader/following-sibling::col">
                        <xsl:if test="ae:normaliseHeader(.)='label'">
                            <xsl:variable name="vLabelPos" select="fn:position()"/>
                            <label>
                                <xsl:value-of select="$pCell/following-sibling::col[$vLabelPos]"/>
                            </label>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:call-template name="comment-element">
                        <xsl:with-param name="pHeader" select="$pHeader/following-sibling::col"/>
                        <xsl:with-param name="pCell" select="$pCell/following-sibling::col"/>
                    </xsl:call-template>
                </labeled-extract>
            </xsl:when>
            <xsl:when test="$vName = 'assayname' or $vName = 'hybridizationname'">
                <assay>
                    <name><xsl:value-of select="$pCell"/></name>
                    <xsl:call-template name="comment-element">
                        <xsl:with-param name="pHeader" select="$pHeader/following-sibling::col"/>
                        <xsl:with-param name="pCell" select="$pCell/following-sibling::col"/>
                    </xsl:call-template>
                </assay>
            </xsl:when>
            <xsl:when test="fn:starts-with($vName, 'characteristics')">
                <characteristic>
                    <xsl:if test="$pJson">
                        <xsl:attribute name="json:force-array" namespace="http://json.org/" select="$pJson"/>
                    </xsl:if>
                    <category><xsl:value-of select="fn:replace($vName, '^.+\[\s*(.+)\s*\]$', '$1')"/></category>
                    <value><xsl:value-of select="$pCell"/></value>
                    <xsl:if test="fn:starts-with(ae:normaliseHeader($pHeader/following-sibling::col[1]), 'unit')">
                        <unit><xsl:value-of select="$pCell/following-sibling::col[1]"/></unit>
                    </xsl:if>
                </characteristic>
            </xsl:when>
            <xsl:when test="fn:starts-with($vName, 'factorvalue')">
                <variable>
                    <xsl:if test="$pJson">
                        <xsl:attribute name="json:force-array" namespace="http://json.org/" select="$pJson"/>
                    </xsl:if>
                    <name><xsl:value-of select="fn:replace($vName, '^.+\[\s*(.+)\s*\]$', '$1')"/></name>
                    <value><xsl:value-of select="$pCell"/></value>
                    <xsl:if test="fn:starts-with(ae:normaliseHeader($pHeader/following-sibling::col[1]), 'unit')">
                        <unit><xsl:value-of select="$pCell/following-sibling::col[1]"/></unit>
                    </xsl:if>
                </variable>
            </xsl:when>
            <xsl:when test="fn:matches($vName, '^(derived|)arraydata(matrix|)file$')">
                <file>
                    <xsl:if test="$pJson">
                        <xsl:attribute name="json:force-array" namespace="http://json.org/" select="$pJson"/>
                    </xsl:if>
                    <type><xsl:value-of select="fn:normalize-space(fn:replace($vName,'^(derived|)array(data)(matrix|)file$', '$1 $2 $3'))"/></type>
                    <name><xsl:value-of select="$pCell"/></name>
                    <xsl:if test="fn:matches(ae:normaliseHeader($pHeader/following-sibling::col[1]), 'comment\[(Derived |)ArrayExpress FTP file\]')">
                        <url><xsl:value-of select="fn:concat(fn:replace($pCell/following-sibling::col[1],'ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/experiment/\w{4}/',$vFileUrl), '/', $pCell)"/></url>
                    </xsl:if>
                    <xsl:call-template name="comment-element">
                        <xsl:with-param name="pHeader" select="$pHeader/following-sibling::col"/>
                        <xsl:with-param name="pCell" select="$pCell/following-sibling::col"/>
                    </xsl:call-template>
                </file>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="comment-element">
        <xsl:param name="pHeader"/>
        <xsl:param name="pCell"/>
        <xsl:variable name="vName" select="ae:normaliseHeader($pHeader[1])"/>
        <xsl:choose>
            <xsl:when test="fn:starts-with($vName, 'comment')">
                <comment>
                    <name><xsl:value-of select="fn:replace($pHeader[1], '.+\[(.+)\].*', '$1')"/></name>
                    <value><xsl:value-of select="$pCell[1]"/></value>
                </comment>
            </xsl:when>
            <xsl:when test="ae:isNode($vName)"/>
            <xsl:otherwise>
                <xsl:if test="$pHeader/following-sibling::col">
                    <xsl:call-template name="comment-element">
                        <xsl:with-param name="pHeader" select="$pHeader/following-sibling::col"/>
                        <xsl:with-param name="pCell" select="$pCell/following-sibling::col"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:function name="ae:normaliseHeader">
        <xsl:param name="pHeader"/>
        <xsl:if test="$pHeader">
            <xsl:variable name="vName"
                          select="fn:lower-case(fn:replace(fn:replace($pHeader, '^(.+)\[.+\].*', '$1'), '\s+', ''))"/>
            <xsl:value-of select="if (fn:matches($pHeader,'\[.+\]')) then fn:concat($vName, fn:replace($pHeader, '.+(\[.+\]).*', '$1')) else $vName"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="ae:isNode">
        <xsl:param name="pName"/>
        <xsl:value-of
                select="fn:matches($pName, '^(sourcename|samplename|extractname|labeledextractname|assayname|scanname|normalizationname|(derived|)arraydata(matrix|)file|imagefile|protocolref)')"/>
    </xsl:function>
</xsl:stylesheet>