<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="xs search html"
                exclude-result-prefixes="xs search html"
                version="2.0">

    <xsl:param name="page"/>
    <xsl:param name="pagesize"/>

    <xsl:variable name="vPage" select="if ($page) then $page cast as xs:integer else 1"/>
    <xsl:variable name="vPageSize" select="if ($pagesize) then $pagesize cast as xs:integer else 25"/>

    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'id'"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'ascending'"/>

    <xsl:param name="userid"/>

    <xsl:param name="queryid"/>
    <xsl:param name="keywords"/>
    <xsl:param name="id"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:variable name="vBrowseMode" select="not($id)"/>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-sort-users.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">
                    <xsl:value-of select="if (not($vBrowseMode)) then concat('User #', $id, ' | ') else ''"/>
                    <xsl:text>Users | ArrayExpress Archive | EBI</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_users_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.cookie-1.0.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_users_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">

        <div id="ae_contents_box_100pc">
            <div id="ae_content">
                <div id="ae_navi">
                    <a href="${interface.application.link.www_domain}/">EBI</a>
                    <xsl:text> > </xsl:text>
                    <a href="{$basepath}">ArrayExpress</a>
                    <xsl:text> > </xsl:text>
                    <a href="{$basepath}/users">Users</a>
                    <xsl:if test="not($vBrowseMode)">
                        <xsl:text> > </xsl:text>
                        <a href="{$basepath}/users/{$id}">
                            <xsl:value-of select="concat('User #', $id)"/>
                        </a>
                    </xsl:if>
                </div>
                <xsl:choose>
                    <xsl:when test="not($userid)">

                        <xsl:variable name="vFilteredData" select="search:queryIndex($queryid)"/>
                        <xsl:variable name="vTotal" select="count($vFilteredData)"/>

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
                        
                        <xsl:if test="$vBrowseMode">

                            <div id="ae_query_box">
                                <form id="ae_query_form" method="get" action="browse.html">
                                    <fieldset id="ae_keywords_fset">
                                        <label for="ae_keywords_field">Filter by user identifier, source, name, email and even password</label>
                                        <input id="ae_keywords_field" type="text" name="keywords" value="{$keywords}" maxlength="255" class="ae_assign_font"/>
                                    </fieldset>
                                    <div id="ae_submit_box"><input id="ae_query_submit" type="submit" value="Query"/></div>
                                    <div id="ae_results_stats">
                                    <div>
                                        <xsl:value-of select="$vTotal"/>
                                        <xsl:text> user</xsl:text>
                                        <xsl:if test="$vTotal != 1">
                                            <xsl:text>s</xsl:text>
                                        </xsl:if>
                                        <xsl:text> found</xsl:text>
                                        <xsl:if test="$vTotal > $vPageSize">
                                            <xsl:text>, displaying </xsl:text>
                                            <xsl:value-of select="$vFrom"/>
                                            <xsl:text> - </xsl:text>
                                            <xsl:value-of select="$vTo"/>
                                        </xsl:if>
                                        <xsl:text>.</xsl:text>
                                    </div>
                                    <xsl:if test="$vTotal > $vPageSize">
                                        <xsl:variable name="vTotalPages" select="floor( ( $vTotal - 1 ) div $vPageSize ) + 1"/>
                                        <div id="ae_results_pager">
                                            <div id="total_pages"><xsl:value-of select="$vTotalPages"/></div>
                                            <div id="page"><xsl:value-of select="$vPage"/></div>
                                            <div id="page_size"><xsl:value-of select="$vPageSize"/></div>
                                        </div>
                                    </xsl:if>
                                </div>
                                </form>
                            </div>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="$vTotal&gt;0">
                                <div id="ae_results_box">
                                    <table id="ae_results_table" border="0" cellpadding="0" cellspacing="0">
                                        <thead>
                                            <tr>
                                                <th class="col_id sortable">
                                                    <xsl:text>ID</xsl:text>
                                                    <xsl:call-template name="add-sort">
                                                        <xsl:with-param name="pKind" select="'id'"/>
                                                    </xsl:call-template>
                                                </th>
                                                <th class="col_source sortable">
                                                    <xsl:text>Source</xsl:text>
                                                    <xsl:call-template name="add-sort">
                                                        <xsl:with-param name="pKind" select="'source'"/>
                                                    </xsl:call-template>
                                                </th>
                                                <th class="col_name sortable">
                                                    <xsl:text>Name</xsl:text>
                                                    <xsl:call-template name="add-sort">
                                                        <xsl:with-param name="pKind" select="'name'"/>
                                                    </xsl:call-template>
                                                </th>
                                                <th class="col_email sortable">
                                                    <xsl:text>E-mail</xsl:text>
                                                    <xsl:call-template name="add-sort">
                                                        <xsl:with-param name="pKind" select="'email'"/>
                                                    </xsl:call-template>
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <xsl:call-template name="ae-sort-users">
                                                <xsl:with-param name="pSequence" select="$vFilteredData"/>
                                                <xsl:with-param name="pFrom" select="$vFrom"/>
                                                <xsl:with-param name="pTo" select="$vTo"/>
                                                <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                                <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                            </xsl:call-template>
                                        </tbody>
                                    </table>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="block-warning">
                                    <xsl:with-param name="pStyle" select="'ae_warn_area'"/>
                                    <xsl:with-param name="pMessage">
                                        <xsl:text>There are no users matching your search criteria found in ArrayExpress Archive.</xsl:text>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$userid = '1'">
                        <div id="ae_login_box">
                            <div id="ae_login_title">Please login to access this page</div>
                            <form id="ae_login_form" method="get" action="." onsubmit="return false">
                                <fieldset id="ae_login_user_fset">
                                    <label for="ae_user_field">User name</label>
                                    <input id="ae_user_field" name="u" maxlength="50" class="ae_assign_font"/>
                                </fieldset>
                                <fieldset id="ae_login_pass_fset">
                                    <label for="ae_pass_field">Password</label>
                                    <input id="ae_pass_field" type="password" name="p" maxlength="50" class="ae_assign_font"/>
                                </fieldset>
                                <input id="ae_login_submit" type="submit" name="s" value="Log in"/>
                                <span>
                                    <input id="ae_login_remember" name="r" type="checkbox"/>
                                    <label for="ae_login_remember">Remember me</label>
                                </span>
                            </form>
                            <div id="ae_login_status"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="block-access-restricted"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="user">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <tr>
                <xsl:if test="not($vBrowseMode)">
                    <xsl:attribute name="class">expanded</xsl:attribute>
                </xsl:if>
                <td class="col_id">
                    <div>
                        <a href="{$basepath}/users/{id}">
                            <xsl:value-of select="id"/>
                        </a>
                    </div>
                </td>
                <td class="col_source">
                    <div>
                        <xsl:value-of select="@source"/>
                    </div>
                </td>
                <td class="col_name">
                    <div>
                        <xsl:value-of select="name"/>
                        <xsl:if test="count(name) = 0">&#160;</xsl:if>
                    </div>
                </td>
                <td class="col_email">
                    <div>
                        <xsl:value-of select="email"/>
                        <xsl:if test="count(email) = 0"><xsl:text>&#160;</xsl:text></xsl:if>
                    </div>
                </td>
            </tr>
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
        </xsl:if>
    </xsl:template>

    <xsl:template name="detail-table">
        <xsl:param name="pUserId"/>
        <xsl:variable name="vExpsForUser" select="search:queryIndex('experiments', concat('visible:true userid:', $pUserId))"/>

        <table border="0" cellpadding="0" cellspacing="0">
            <tbody>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Experiments'"/>
                    <xsl:with-param name="pValue">
                        <xsl:value-of select="string-join($vExpsForUser/accession, ', ')"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Platforms'"/>
                    <xsl:with-param name="pValue">
                    </xsl:with-param>
                </xsl:call-template>
            </tbody>
        </table>

    </xsl:template>
    <xsl:template name="detail-row">
        <xsl:param name="pName"/>
        <xsl:param name="pValue"/>
        <xsl:if test="$pValue/node()">
            <xsl:call-template name="detail-section">
                <xsl:with-param name="pName" select="$pName"/>
                <xsl:with-param name="pContent" select="$pValue"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="detail-section">
        <xsl:param name="pName"/>
        <xsl:param name="pContent"/>
        <tr>
            <td class="detail_name">
                <div class="outer"><xsl:value-of select="$pName"/></div>
            </td>
            <td class="detail_value">
                <div class="outer"><xsl:copy-of select="$pContent"/></div>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="add-sort">
        <xsl:param name="pKind"/>
        <xsl:if test="$pKind = $vSortBy">
            <xsl:choose>
                <xsl:when test="'ascending' = $vSortOrder"><img src="{$basepath}/assets/images/mini_arrow_up.gif" width="12" height="16" alt="^"/></xsl:when>
                <xsl:otherwise><img src="{$basepath}/assets/images/mini_arrow_down.gif" width="12" height="16" alt="v"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
