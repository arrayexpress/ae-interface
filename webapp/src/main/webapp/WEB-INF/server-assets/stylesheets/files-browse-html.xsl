<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2013 European Molecular Biology Laboratory
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
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="xs fn ae search"
                exclude-result-prefixes="xs fn ae search html"
                version="2.0">

    <xsl:param name="page"/>
    <xsl:param name="pagesize"/>

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:param name="queryid"/>
    <xsl:param name="keywords"/>
    <xsl:param name="accession"/>
    <xsl:param name="kind"/>
    <xsl:param name="ref"/>

    <xsl:variable name="vAccession" select="fn:upper-case($accession)"/>
    <xsl:variable name="vRef" select="fn:upper-case($ref)"/>
    <xsl:variable name="vExperimentMode" select="fn:starts-with($relative-uri, '/experiments/') or fn:starts-with($vRef, 'E')"/>
    <xsl:variable name="vArrayMode" select="fn:starts-with($vRef, 'A')"/>
    <xsl:variable name="vRefAccession" select="if ($ref) then $vRef else $vAccession"/>
    <xsl:variable name="vExperimentArrayMode" select="$vRefAccession != $vAccession"/>
    <xsl:variable name="vQueryString" as="xs:string" select="if ($vExperimentMode or $vArrayMode) then fn:concat('?ref=', $vRefAccession) else ''"/>
    <xsl:variable name="vKindMode" select="$kind != ''"/>
    <xsl:variable name="vBrowseMode" select="fn:not($accession)"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-file-functions.xsl"/>
    <xsl:include href="ae-date-functions.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>
    <xsl:include href="ae-sort-files.xsl"/>

    <xsl:template match="/">
        <xsl:call-template name="ae-page">
            <xsl:with-param name="pIsFixedWidth" select="fn:false()"/>
            <xsl:with-param name="pIsSearchVisible" select="fn:not($vBrowseMode)"/>
            <xsl:with-param name="pSearchInputValue"/>
            <xsl:with-param name="pTitleTrail">
                <xsl:value-of select="if ((fn:not($vBrowseMode) and fn:not($vExperimentMode) and fn:not($vArrayMode)) or $vExperimentArrayMode) then fn:concat($vAccession, ' &lt; ') else ''"/>
                <xsl:text>Files</xsl:text>
                <xsl:choose>
                    <xsl:when test="$vExperimentMode">
                        <xsl:text> &lt; </xsl:text>
                        <xsl:value-of select="$vRefAccession"/>
                        <xsl:text> &lt; Experiments</xsl:text>
                    </xsl:when>
                    <xsl:when test="$vArrayMode">
                        <xsl:text> &lt; </xsl:text>
                        <xsl:value-of select="$vRefAccession"/>
                        <xsl:text> &lt; Arrays</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="pExtraCSS">
                <link rel="stylesheet" href="{$context-path}/assets/stylesheets/ae-files-browse-1.0.130314.css" type="text/css"/>
            </xsl:with-param>
            <xsl:with-param name="pBreadcrumbTrail">
                <xsl:choose>
                    <xsl:when test="$vExperimentMode">
                        <a href="{$context-path}/experiments/browse.html">Experiments</a>
                        <xsl:text> > </xsl:text>
                        <a href="{$context-path}/experiments/{$vRefAccession}/"><xsl:value-of select="$vRefAccession"/></a>
                        <xsl:text> > </xsl:text>
                        <xsl:if test="$vExperimentArrayMode or $vKindMode">
                            <a href="{$context-path}/experiments/{$vRefAccession}/files/">Files</a>
                            <xsl:text> > </xsl:text>
                            <xsl:if test="$vExperimentArrayMode and $vKindMode">
                                <a href="{$context-path}/files/{$vAccession}/?ref={$vRefAccession}">
                                    <xsl:value-of select="$vAccession"/>
                                </a>
                                <xsl:text> > </xsl:text>
                            </xsl:if>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="$vArrayMode">
                        <a href="{$context-path}/arrays/browse.html">Arrays</a>
                        <xsl:text> > </xsl:text>
                        <a href="{$context-path}/arrays/{$vRefAccession}/"><xsl:value-of select="$vRefAccession"/></a>
                        <xsl:text> > </xsl:text>
                        <xsl:if test="$vKindMode">
                            <a href="{$context-path}/arrays/{$vRefAccession}/files/">Files</a>
                            <xsl:text> > </xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="fn:not($vBrowseMode)">
                            <a href="{$context-path}/files/browse.html">Files</a>
                            <xsl:text> > </xsl:text>
                            <xsl:if test="$vKindMode">
                                <a href="{$context-path}/files/{$vAccession}/">
                                    <xsl:value-of select="$vAccession"/>
                                </a>
                                <xsl:text> > </xsl:text>
                            </xsl:if>

                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$vKindMode">
                        <xsl:value-of select="ae:getKindTitle($kind)"/>
                    </xsl:when>
                    <xsl:when test="$vBrowseMode or ($vExperimentMode and fn:not($vExperimentArrayMode)) or $vArrayMode">
                        <xsl:text>Files</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$vAccession"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="pExtraJS">
                <script src="{$context-path}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                <script src="{$context-path}/assets/scripts/jquery.ae-files-browse-1.0.0.js" type="text/javascript"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="ae-content-section">
        <section>
            <div id="ae-content">
                <xsl:choose>
                    <xsl:when test="$vBrowseMode">
                        <xsl:call-template name="block-browse"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="block-files-for-accession">
                            <xsl:with-param name="pAccession" select="$vAccession"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </section>
    </xsl:template>

    <xsl:template name="block-browse">
        <xsl:variable name="vFilteredFiles" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredFiles)"/>

        <xsl:variable name="vPage" select="if ($page) then $page cast as xs:integer else 1"/>
        <xsl:variable name="vPageSize" select="if ($pagesize) then $pagesize cast as xs:integer else 25"/>

        <xsl:variable name="vFrom" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$vPage > 0"><xsl:value-of select="1 + ( $vPage - 1 ) * $vPageSize"/></xsl:when>
                <xsl:when test="$vTotal = 0">0</xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vTo" as="xs:integer">
            <xsl:choose>
                <xsl:when test="( $vFrom + $vPageSize - 1 ) > $vTotal"><xsl:value-of select="$vTotal"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$vFrom + $vPageSize - 1"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'accession'"/>
        <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'ascending'"/>

        <div id="ae-query">
            <form method="get" action="browse.html">
                <fieldset>
                    <label for="ae-query-keywords">Search files by experiment/array accessions, kinds, names, or extensions</label>
                    <input id="ae-query-keywords" type="text" name="keywords" value="{$keywords}" maxlength="255"/>
                    <div><input type="submit" value="Search"/></div>
                </fieldset>
            </form>
        </div>

        <xsl:choose>
            <xsl:when test="$vTotal&gt;0">
                <div id="ae-browse" class="persist-area">
                    <table class="persist-header" border="0" cellpadding="0" cellspacing="0">
                        <col class="col_accession"/>
                        <col class="col_name"/>
                        <col class="col_kind"/>
                        <col class="col_size"/>
                        <col class="col_lastmodified"/>
                        <thead>
                            <xsl:call-template name="table-pager">
                                <xsl:with-param name="pColumnsToSpan" select="5"/>
                                <xsl:with-param name="pName" select="'file'"/>
                                <xsl:with-param name="pTotal" select="$vTotal"/>
                                <xsl:with-param name="pPage" select="$vPage"/>
                                <xsl:with-param name="pPageSize" select="$vPageSize"/>
                            </xsl:call-template>
                            <tr>
                                <th class="col_accession sortable">
                                    <xsl:text>Accession</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'accession'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_name sortable">
                                    <xsl:text>Name</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'name'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_kind sortable">
                                    <xsl:text>Kind</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'kind'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_size sortable">
                                    <xsl:text>Size</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'size'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_lastmodified sortable">
                                    <xsl:text>Last modified</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'lastmodified'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                            </tr>
                        </thead>
                    </table>
                    <table border="0" cellpadding="0" cellspacing="0">
                        <col class="col_accession"/>
                        <col class="col_name"/>
                        <col class="col_kind"/>
                        <col class="col_size"/>
                        <col class="col_lastmodified"/>
                        <tbody>
                            <xsl:call-template name="ae-sort-files">
                                <xsl:with-param name="pFiles" select="$vFilteredFiles"/>
                                <xsl:with-param name="pFrom" select="$vFrom"/>
                                <xsl:with-param name="pTo" select="$vTo"/>
                                <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                            </xsl:call-template>
                            <tr>
                                <td colspan="5" class="col_footer">&#160;</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div id="ae-infotext">
                    <span class="alert">There are no files matching your search criteria found in ArrayExpress.</span>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="file">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <xsl:variable name="vUserInfo" select="ae:getMappedValue('users-for-accession', ../@accession)"/>
            <xsl:variable name="vFilePath" select="fn:concat($context-path, '/files/', ../@accession, '/', @name)"/>
            <tr>
                <td class="col_accession">
                    <div>
                        <a href="{$context-path}/files/{../@accession}">
                            <xsl:if test="not($vUserInfo = '1')">
                                <xsl:attribute name="class" select="'icon icon-functional'"/>
                                <xsl:attribute name="data-icon" select="'L'"/>
                            </xsl:if>
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pQueryId" select="$queryid" />
                                <xsl:with-param name="pText" select="../@accession"/>
                                <xsl:with-param name="pFieldName" select="'accession'"/>
                            </xsl:call-template>
                        </a>
                    </div>
                </td>
                <td class="col_name">
                    <div>
                        <a href="{$vFilePath}" class="icon icon-functional" data-icon="=">
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pQueryId" select="$queryid" />
                                <xsl:with-param name="pText" select="@name"/>
                                <xsl:with-param name="pFieldName" select="'name'"/>
                            </xsl:call-template>
                        </a>
                    </div>
                </td>
                <td class="col_kind">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid" />
                            <xsl:with-param name="pText" select="@kind"/>
                            <xsl:with-param name="pFieldName" select="'kind'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_size">
                    <div>
                        <xsl:value-of select="ae:formatFileSize(@size)"/>
                    </div>
                </td>
                <td class="col_lastmodified">
                    <div>
                        <xsl:value-of select="ae:formatDateTime(@lastmodified)"/>
                    </div>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="block-files-for-accession">
        <xsl:param name="pAccession"/>

        <xsl:variable name="vFolder" select="ae:getMappedValue('ftp-folder', $pAccession)"/>
        <xsl:variable name="vFolderKind" select="$vFolder/@kind"/>
        <xsl:variable name="vMetaData" select="search:queryIndex(concat($vFolderKind, 's'), concat('visible:true accession:', $pAccession, if ($userid) then concat(' userid:(', $userid, ')') else ''))[accession = $vAccession]" />
        <xsl:choose>
            <xsl:when test="exists($vFolder) and exists($vMetaData)">
                <section>
                    <div id="ae-files">
                        <xsl:call-template name="list-folder">
                            <xsl:with-param name="pFolder" select="$vFolder"/>
                            <xsl:with-param name="pMetaData" select="$vMetaData"/>
                        </xsl:call-template>
                        <xsl:if test="$vExperimentMode and $vFolderKind='experiment' and fn:not($kind)">
                            <xsl:for-each select="$vMetaData/arraydesign">
                                <xsl:sort select="accession" order="ascending"/>
                                <xsl:variable name="vArrAccession" select="string(accession)"/>
                                <xsl:if test="fn:matches($vArrAccession, '^[aA]-\w{4}-\d+$')">
                                    <xsl:variable name="vArrFolder" select="ae:getMappedValue('ftp-folder', $vArrAccession)"/>
                                    <xsl:variable name="vArrMetaData" select="search:queryIndex('arrays', concat('visible:true accession:', $vArrAccession, if ($userid) then concat(' userid:(', $userid, ')') else ''))"/>
                                    <xsl:choose>
                                        <xsl:when test="exists($vArrMetaData)">
                                            <div class="ae-array-folder">
                                                <xsl:call-template name="list-folder">
                                                    <xsl:with-param name="pFolder" select="$vArrFolder"/>
                                                    <xsl:with-param name="pMetaData" select="$vArrMetaData"/>
                                                </xsl:call-template>
                                            </div>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </div>
                </section>
            </xsl:when>
            <xsl:when test="exists($vFolder) and not(exists($vMetaData))">
                <xsl:value-of select="ae:httpStatus(403)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="ae:httpStatus(404)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="list-folder">
        <xsl:param name="pFolder"/>
        <xsl:param name="pMetaData"/>

        <h4>
            <xsl:if test="not($pMetaData/user/@id = '1')">
                <xsl:attribute name="class" select="'icon icon-functional'"/>
                <xsl:attribute name="data-icon" select="'L'"/>
            </xsl:if>
            <xsl:value-of select="$pMetaData/accession"/>
            <xsl:text> - </xsl:text>
            <xsl:value-of select="fn:string-join($pMetaData/name, ', ')"/>
        </h4>
        <xsl:call-template name="list-files">
            <xsl:with-param name="pFolder" select="$pFolder"/>
            <xsl:with-param name="pComment">
                <xsl:if test="($kind = 'raw' or $kind = 'processed') and count($pFolder/file[@kind = $kind]) > 1">
                    <div class="icon icon-generic" data-icon="l">
                        <xsl:text>Due to the large amount of data there are multiple archive files for download.</xsl:text>
                    </div>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template name="list-files">
        <xsl:param name="pFolder"/>
        <xsl:param name="pComment"/>

        <div class="ae-files">
            <table border="0" cellpadding="0" cellspacing="0">
                <col class="col_name"/>
                <col class="col_size"/>
                <col class="col_lastmodified"/>
                <tbody>
                    <xsl:if test="not($pFolder/file)">
                        <tr><td class="col_all" colspan="3"><div>No files</div></td></tr>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="$kind != ''">
                            <xsl:call-template name="list-files-kind">
                                <xsl:with-param name="pFiles" select="$pFolder/file[@hidden = 'false' and @kind = $kind]"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each-group select="$pFolder/file[@hidden = 'false']" group-by="@kind">
                                <xsl:sort select="xs:string(@kind != '')" order="descending"/>
                                <xsl:sort select="xs:string(fn:count(fn:current-group()) > 9)" order="descending"/>
                                <xsl:sort select="xs:string(@kind = 'raw' or @kind = 'processed')" order="descending"/>
                                <xsl:sort select="xs:string(@kind = 'adf' or @kind = 'idf' or @kind = 'sdrf')" order="descending"/>
                                <xsl:sort select="@kind" order="ascending"/>

                                <xsl:choose>
                                    <xsl:when test="fn:count(fn:current-group()) > 9 and @kind != ''">
                                        <tr>
                                            <td colspan="3">
                                                <a class="icon icon-awesome" data-icon="&#xf07b;" href="{$context-path}{$relative-uri}{fn:current-grouping-key()}/{$vQueryString}"><xsl:value-of select="fn:concat(ae:getKindTitle(fn:current-grouping-key()), ' (', fn:count(fn:current-group()), ')')"/></a>
                                            </td>
                                        </tr>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="list-files-kind">
                                            <xsl:with-param name="pFiles" select="fn:current-group()"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each-group>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="$pComment/div">
                        <tr>
                            <td class="col_all comment" colspan="3">
                                <xsl:copy-of select="$pComment"/>
                            </td>
                        </tr>
                    </xsl:if>
                </tbody>
            </table>
        </div>
    </xsl:template>

    <xsl:template name="list-files-kind">
        <xsl:param name="pFiles"/>
        <xsl:for-each select="$pFiles">
            <xsl:sort select="xs:string(fn:contains(fn:lower-case(@name), 'readme'))" order="descending"/>
            <xsl:sort select="fn:replace(@name, '^.+[.](\d+)[.].+$', '$1')" data-type="number" order="ascending"/>
            <xsl:sort select="fn:lower-case(@name)" order="ascending"/>
            <tr>
                <td class="col_name"><div><a href="{$context-path}/files/{../@accession}/{@name}" title="Click to download {@name}" class="icon icon-functional" data-icon="="><xsl:value-of select="@name"/></a></div></td>
                <td class="col_size"><div><xsl:value-of select="ae:formatFileSize(@size)"/></div></td>
                <td class="col_lastmodified"><div><xsl:value-of select="ae:formatDateTime(@lastmodified)"/></div></td>
            </tr>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
