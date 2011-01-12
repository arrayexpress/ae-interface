<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="search html"
                exclude-result-prefixes="search html"
                version="2.0">

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

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="ISO-8859-1" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-sort-users.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">
                    <xsl:text>Users | ArrayExpress Archive | EBI</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_common_20.css" type="text/css"/>
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
        <script type="text/javascript">
            <xsl:text>var basePath = "</xsl:text>
            <xsl:value-of select="$basepath"/>
            <xsl:text>";</xsl:text>
        </script>

        <div id="ae_contents_box_100pc">
            <xsl:choose>
                <xsl:when test="not($userid)">
                    <xsl:variable name="vFilteredData" select="search:queryIndex($queryid)"/>
                    <xsl:variable name="vTotal" select="count($vFilteredData)"/>

                    <div id="ae_content">
                        <div id="ae_query_box">
                            <form id="ae_query_form" method="get" action="browse.html">
                                <fieldset id="ae_keywords_fset">
                                    <label for="ae_keywords_field">Users</label>
                                    <input id="ae_keywords_field" type="text" name="keywords" value="{$keywords}" maxlength="255" class="ae_assign_font"/>
                                </fieldset>
                                <div id="ae_submit_box"><input id="ae_query_submit" type="submit" value="Query"/></div>
                            </form>
                        </div>
                        <xsl:choose>
                            <xsl:when test="$vTotal&gt;0">
                                <div id="ae_results_header">
                                    <xsl:text>There </xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="$vTotal = 1">
                                            <xsl:text>is a user </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>are </xsl:text>
                                            <xsl:value-of select="$vTotal"/>
                                            <xsl:text> users </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text> matching your search criteria found in ArrayExpress Archive.</xsl:text>
                                    <span id="ae_print_controls" class="noprint"><a href="javascript:window.print()"><img src="{$basepath}/assets/images/silk_print.gif" width="16" height="16" alt="Print"/>Print this window</a>.</span>
                                </div>
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
                                            <xsl:with-param name="pFrom"/>
                                            <xsl:with-param name="pTo"/>
                                            <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                            <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                        </xsl:call-template>
                                    </tbody>
                                </table>
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
                    </div>
                </xsl:when>
                <xsl:when test="$userid = '1'">
                    <div id="ae_content">
                        <div id="ae_login_box">
                            <div id="ae_login_title">Please login to access this page</div>
                            <form id="ae_login_form" method="get" action="index.html" onsubmit="return false">
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
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="block-access-restricted"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="user">
        <tr>
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
