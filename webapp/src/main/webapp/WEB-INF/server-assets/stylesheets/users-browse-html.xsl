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
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="xs fn ae search html"
                exclude-result-prefixes="xs fn ae search html"
                version="2.0">

    <xsl:param name="page"/>
    <xsl:param name="pagesize"/>

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:param name="queryid"/>
    <xsl:param name="keywords"/>

    <!-- TODO: not sure if we need this mode at all
    <xsl:param name="id"/>
    <xsl:variable name="vBrowseMode" select="not($id)"/>
    -->
    <xsl:variable name="vBrowseMode" select="fn:true()"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>
    <xsl:include href="ae-sort-users.xsl"/>

    <xsl:template match="/">
        <xsl:call-template name="ae-page">
            <xsl:with-param name="pIsSearchVisible" select="fn:not($vBrowseMode)"/>
            <xsl:with-param name="pSearchInputValue"/>
            <xsl:with-param name="pExtraSearchFields"/>
            <xsl:with-param name="pTitleTrail">
                <xsl:text>Users</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="pExtraCSS">
                <link rel="stylesheet" href="{$context-path}/assets/stylesheets/ae-users-browse-1.0.130314.css" type="text/css"/>
            </xsl:with-param>
            <xsl:with-param name="pBreadcrumbTrail">
                <xsl:choose>
                    <xsl:when test="$vBrowseMode">Users</xsl:when>
                    <xsl:otherwise>
                        <!--
                        <a href="{$context-path}/users">Users</a>
                        <xsl:text> > </xsl:text>
                        <a href="{$context-path}/users/{$id}">
                            <xsl:value-of select="concat('User #', $id)"/>
                        </a>
                        -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="pEBISearchWidget"/>
            <xsl:with-param name="pExtraJS">
                <script src="{$context-path}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                <script src="{$context-path}/assets/scripts/jquery.ae-users-browse-1.0.130314.js" type="text/javascript"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="ae-content-section">
        <section>
            <div id="ae-content">
                <xsl:choose>
                    <xsl:when test="not($userid)">
                        <xsl:choose>
                            <xsl:when test="$vBrowseMode">
                                <xsl:call-template name="block-browse"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!--
                                <xsl:call-template name="block-user/>
                                -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ae:httpStatus(403)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </section>
    </xsl:template>

    <xsl:template name="block-browse">
        <xsl:variable name="vFilteredData" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredData)"/>

        <xsl:variable name="vPage" select="if ($page and $page castable as xs:integer) then $page cast as xs:integer else 1" as="xs:integer"/>
        <xsl:variable name="vPageSize" select="if ($pagesize and $pagesize castable as xs:integer) then $pagesize cast as xs:integer else 25" as="xs:integer"/>

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

        <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'id'"/>
        <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'ascending'"/>

        <div id="ae-query">
            <form method="get" action="{$context-path}/users/browse.html">
                <fieldset>
                    <label for="ae-query-keywords">Search users by name, email, or source (AE1/AE2)</label>
                    <input id="ae-query-keywords" type="text" name="keywords" value="{$keywords}" maxlength="255"/>
                    <div><input class="submit" type="submit" value="Search"/></div>
                </fieldset>
            </form>
        </div>

        <xsl:choose>
            <xsl:when test="$vTotal&gt;0">
                <div id="ae-browse" class="persist-area">
                    <table class="persist-header" border="0" cellpadding="0" cellspacing="0">
                        <col class="col_id"/>
                        <col class="col_name"/>
                        <col class="col_email"/>
                        <col class="col_experiments"/>
                        <col class="col_source"/>
                        <thead>
                            <xsl:call-template name="table-pager">
                                <xsl:with-param name="pColumnsToSpan" select="5"/>
                                <xsl:with-param name="pName" select="'user'"/>
                                <xsl:with-param name="pTotal" select="$vTotal"/>
                                <xsl:with-param name="pPage" select="$vPage"/>
                                <xsl:with-param name="pPageSize" select="$vPageSize"/>
                            </xsl:call-template>
                            <tr>
                                <th class="col_id sortable">
                                    <xsl:text>ID</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'id'"/>
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
                                <th class="col_email sortable">
                                    <xsl:text>E-mail</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'email'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_experiments sortable">
                                    <xsl:text>Experiments</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'experiments'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                                <th class="col_source sortable">
                                    <xsl:text>Source</xsl:text>
                                    <xsl:call-template name="add-table-sort">
                                        <xsl:with-param name="pKind" select="'source'"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </th>
                            </tr>
                        </thead>
                    </table>
                    <table border="0" cellpadding="0" cellspacing="0">
                        <col class="col_id"/>
                        <col class="col_name"/>
                        <col class="col_email"/>
                        <col class="col_experiments"/>
                        <col class="col_source"/>
                        <tbody>
                            <xsl:call-template name="ae-sort-users">
                                <xsl:with-param name="pSequence" select="$vFilteredData"/>
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
                    <span class="alert">There are no users matching your search criteria found in ArrayExpress.</span>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="user">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <tr>
                <!--
                <xsl:if test="not($vBrowseMode)">
                    <xsl:attribute name="class">expanded</xsl:attribute>
                </xsl:if>
                -->
                <td class="col_id">
                    <div>
                        <!-- <a href="{$context-path}/users/{id}"> -->
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pQueryId" select="$queryid"/>
                                <xsl:with-param name="pText" select="id"/>
                                <xsl:with-param name="pFieldName" select="'id'"/>
                            </xsl:call-template>
                        <!-- </a> -->
                    </div>
                </td>
                <td class="col_name">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="name"/>
                            <xsl:with-param name="pFieldName" select="'name'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_email">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="email"/>
                            <xsl:with-param name="pFieldName" select="'email'"/>
                        </xsl:call-template>
                    </div>
                </td>
                <td class="col_experiments">
                    <div>
                        <xsl:choose>
                            <xsl:when test="@experiment-count > 1">
                                <a href="{$context-path}/experiments/browse.html?keywords=userid:{id}">
                                    <xsl:value-of select="@experiment-count"/>
                                </a>
                            </xsl:when>
                            <xsl:when test="@experiment-count = 1">
                                <a href="{$context-path}/experiments/{ae:getMappedValue('experiments-for-user', id)[1]}/">
                                    <xsl:value-of select="@experiment-count"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>-</xsl:otherwise>
                        </xsl:choose>

                    </div>
                </td>
                <td class="col_source">
                    <div>
                        <xsl:value-of select="fn:upper-case(@source)"/>
                    </div>
                </td>
            </tr>
            <!--
            <xsl:if test="not($vBrowseMode)">
                <tr>
                    <td class="col_detail" colspan="4">
                        <div class="detail_table">
                            <xsl:call-template name="detail-table">
                                <xsl:with-param name="pUserId" select="id"/>
                            </xsl:call-template>
                        </div>
                    </td>
                </tr>
            </xsl:if>
            -->
        </xsl:if>
    </xsl:template>

    <!--
    <xsl:template name="detail-table">
        <xsl:param name="pUserId"/>

        <xsl:variable name="vExpsForUser" select="search:queryIndex('experiments', concat('visible:true userid:', $pUserId))"/>
        <xsl:variable name="vArraysForUser" select="search:queryIndex('arrays', concat('visible:true userid:', $pUserId))"/>

        <table border="0" cellpadding="0" cellspacing="0">
            <tbody>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="concat('Experiments (', count($vExpsForUser), ')')"/>
                    <xsl:with-param name="pValue">
                        <xsl:for-each select="$vExpsForUser[position() &lt; 50]/accession">
                            <xsl:sort select="substring(current(), 3, 4)" order="ascending"/>
                            <xsl:sort select="substring(current(), 8)" order="ascending" data-type="number"/>

                            <a href="{$context-path}/experiments/{current()}"><xsl:value-of select="current()"/></a>
                            <xsl:if test="position() != last()">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:if test="count($vExpsForUser) >= 50">
                            <xsl:text>, ...</xsl:text>
                            <div><br/><a href="{$context-path}/browse.html?keywords=userid:{$id}"><img src="{$context-path}/assets/images/silk_browse.gif" width="16" height="16"/>Browse all associated experiments</a></div>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="concat('Platform designs (', count($vArraysForUser), ')')"/>
                    <xsl:with-param name="pValue">
                        <xsl:for-each select="$vArraysForUser[position() &lt; 50]/accession">
                            <xsl:sort select="substring(current(), 3, 4)" order="ascending"/>
                            <xsl:sort select="substring(current(), 8)" order="ascending" data-type="number"/>

                            <a href="{$context-path}/arrays/{current()}"><xsl:value-of select="current()"/></a>
                            <xsl:if test="position() != last()">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:if test="count($vArraysForUser) >= 50">
                            <xsl:text>, ...</xsl:text>
                            <div><br/><a href="{$context-path}/arrays/browse.html?keywords=userid:{$id}"><img src="{$context-path}/assets/images/silk_browse.gif" width="16" height="16"/>Browse all associated platform designs</a><br/></div>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </tbody>
        </table>

    </xsl:template>
    -->
</xsl:stylesheet>
