<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="xs ae aejava search"
                exclude-result-prefixes="xs ae aejava search html"
                version="2.0">

    <xsl:param name="page"/>
    <xsl:param name="pagesize"/>
    
    <xsl:variable name="vPage" select="if ($page) then $page cast as xs:integer else 1"/>
    <xsl:variable name="vPageSize" select="if ($pagesize) then $pagesize cast as xs:integer else 25"/>
    
    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>
    
    <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'accession'"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'ascending'"/>
    
    <xsl:param name="queryid"/>
    <xsl:param name="accession"/>
    <xsl:param name="keywords"/>
    <xsl:param name="userid"/>
    <xsl:param name="kind"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:include href="ae-file-functions.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>
    <xsl:include href="ae-sort-files.xsl"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    <xsl:variable name="vBrowseMode" select="not($accession)"/>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="ISO-8859-1" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">
                    <xsl:value-of select="if (not($vBrowseMode)) then concat(upper-case($accession), ' | ') else ''"/>
                    <xsl:text>Files | ArrayExpress Archive | EBI</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_common_20.css" type="text/css"/>
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_files_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.cookie-1.0.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_files_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">
        <xsl:choose>
            <xsl:when test="not($vBrowseMode)">
                <xsl:variable name="vAccession" select="upper-case($accession)"/>
                <xsl:variable name="vFolder" select="aejava:getAcceleratorValueAsSequence('ftp-folder', $vAccession)"/>
                <xsl:variable name="vFolderKind" select="$vFolder/@kind"/>
                <xsl:variable name="vMetaData" select="search:queryIndex(concat($vFolderKind, 's'), concat('visible:true accession:', $accession, if ($userid) then concat(' userid:(', $userid, ')') else ''))[accession = $vAccession]" />
                <xsl:choose>
                    <xsl:when test="exists($vFolder) and exists($vMetaData)">
                        <div id="ae_contents_box_740px">
                            <div id="ae_content">
                                <div id="ae_navi">
                                    <a href="${interface.application.link.www_domain}/">EBI</a>
                                    <xsl:text> > </xsl:text>
                                    <a href="{$basepath}">ArrayExpress</a>
                                    <xsl:text> > </xsl:text>
                                    <a href="{$basepath}/files">Files</a>
                                    <xsl:text> > </xsl:text>
                                    <a href="{$basepath}/arrays/{upper-case($accession)}">
                                        <xsl:value-of select="upper-case($accession)"/>
                                    </a>
                                </div>
                                <xsl:call-template name="list-folder">
                                    <xsl:with-param name="pFolder" select="$vFolder"/>
                                    <xsl:with-param name="pMetaData" select="$vMetaData"/>
                                </xsl:call-template>
                                <xsl:if test="$vFolderKind='experiment' and not($kind)">
                                    <xsl:for-each select="$vMetaData/arraydesign">
                                        <xsl:sort select="accession" order="ascending"/>
                                        <xsl:variable name="vArrAccession" select="string(accession)"/>
                                        <xsl:if test="matches($vArrAccession, '^[aA]-\w{4}-\d+$')">
                                            <xsl:variable name="vArrFolder" select="aejava:getAcceleratorValueAsSequence('ftp-folder', $vArrAccession)"/>
                                            <xsl:variable name="vArrMetaData" select="search:queryIndex('arrays', concat('visible:true accession:', $vArrAccession, if ($userid) then concat(' userid:(', $userid, ')') else ''))"/>
                                            <xsl:choose>
                                                <xsl:when test="exists($vArrMetaData)">
                                                    <xsl:call-template name="list-folder">
                                                        <xsl:with-param name="pFolder" select="$vArrFolder"/>
                                                        <xsl:with-param name="pMetaData" select="$vArrMetaData"/>
                                                    </xsl:call-template>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <div class="ae_accession">
                                                        <xsl:value-of select="concat(upper-case(substring($vArrFolder/@kind, 1, 1)), substring($vArrFolder/@kind, 2))"/>
                                                        <xsl:text> </xsl:text>
                                                        <xsl:value-of select="$vMetaData/accession"/>
                                                        <xsl:text> - access prohibited.</xsl:text>
                                                    </div>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:if>
                            </div>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="exists($vFolder) and not(exists($vMetaData))">
                                <xsl:call-template name="block-access-restricted"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="block-not-found"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:otherwise>
                <div id="ae_contents_box_100pc">
                    <div id="ae_content">
                        <div id="ae_navi">
                            <a href="${interface.application.link.www_domain}/">EBI</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}">ArrayExpress</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/files">Files</a>
                        </div>
                        <xsl:choose>
                            <xsl:when test="not($userid)">
                                <xsl:variable name="vFilteredFiles" select="search:queryIndex($queryid)"/>
                                <xsl:variable name="vTotal" select="count($vFilteredFiles)"/>

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

                                <div id="ae_query_box">
                                    <form id="ae_query_form" method="get" action="browse.html">
                                        <fieldset id="ae_keywords_fset">
                                            <label for="ae_keywords_field">Filter by folder, name, kind, or extension [<a href="javascript:aeClearField('#ae_keywords_field')">clear</a>]</label>
                                            <input id="ae_keywords_field" type="text" name="keywords" value="{$keywords}" maxlength="255" class="ae_assign_font"/>
                                        </fieldset>
                                        <div id="ae_submit_box"><input id="ae_query_submit" type="submit" value="Query"/></div>
                                        <div id="ae_results_stats">
                                            <div>
                                                <xsl:value-of select="$vTotal"/>
                                                <xsl:text> file</xsl:text>
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
                                <xsl:choose>
                                    <xsl:when test="$vTotal&gt;0">
                                        <div id="ae_results_box">
                                            <table id="ae_results_table" border="0" cellpadding="0" cellspacing="0">
                                                <thead>
                                                    <tr>
                                                        <th class="col_accession sortable">
                                                            <xsl:text>Accession</xsl:text>
                                                            <xsl:call-template name="add-sort">
                                                                <xsl:with-param name="pKind" select="'accession'"/>
                                                            </xsl:call-template>
                                                        </th>
                                                        <th class="col_name sortable">
                                                            <xsl:text>Name</xsl:text>
                                                            <xsl:call-template name="add-sort">
                                                                <xsl:with-param name="pKind" select="'name'"/>
                                                            </xsl:call-template>
                                                        </th>
                                                        <th class="col_size sortable">
                                                            <xsl:text>Size</xsl:text>
                                                            <xsl:call-template name="add-sort">
                                                                <xsl:with-param name="pKind" select="'size'"/>
                                                            </xsl:call-template>
                                                        </th>
                                                        <th class="col_lastmodified">
                                                            <xsl:text>Last modified</xsl:text>
                                                        </th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <xsl:call-template name="ae-sort-files">
                                                        <xsl:with-param name="pFiles" select="$vFilteredFiles"/>
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
                                                <xsl:text>There are no platform designs matching your search criteria found in ArrayExpress Archive.</xsl:text>
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
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="file">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <tr>
                <td class="col_accession">
                    <div>
                        <a href="{$basepath}/files/{../@accession}">
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pText" select="../@accession" />
                                <xsl:with-param name="pFieldName" select="'accession'" />
                            </xsl:call-template>
                        </a>
                    </div>
                </td>
                <td class="col_name">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="@name"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                        <xsl:if test="not(@name)">&#160;</xsl:if>
                    </div>
                </td>
                <td class="col_size">
                    <div>
                        <xsl:value-of select="ae:formatfilesize(@size)"/>
                        <xsl:if test="not(@size)"><xsl:text>&#160;</xsl:text></xsl:if>
                    </div>
                </td>
                <td class="col_lastmodified">
                    <div>
                        <xsl:value-of select="@lastmodified"/>
                        <xsl:if test="not(@lastmodified)"><xsl:text>&#160;</xsl:text></xsl:if>
                    </div>
                </td>
            </tr>
        </xsl:if>
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
    
    <xsl:template name="list-folder">
        <xsl:param name="pFolder"/>
        <xsl:param name="pMetaData"/>

        <div class="ae_accession">
            <xsl:value-of select="concat(upper-case(substring($pFolder/@kind, 1, 1)),substring($pFolder/@kind, 2))"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$pMetaData/accession"/>
            <xsl:if test="not($pMetaData/user/@id = '1')">
                <img src="{$basepath}/assets/images/silk_lock.gif" alt="Access to the data is restricted" width="8" height="9"/>
            </xsl:if>
        </div>
        <div class="ae_title"><xsl:value-of select="$pMetaData/name"/></div>
        <xsl:call-template name="list-files">
            <xsl:with-param name="pFolder" select="$pFolder"/>
        </xsl:call-template>
        <xsl:variable name="vComment">
            <xsl:if test="($kind = 'raw' or $kind = 'fgem') and count($pFolder/file[@kind = $kind]) > 1">
                <div>
                    <xsl:text>Due to the large amount of data there are multiple archive files for download.</xsl:text>
                </div>
            </xsl:if>
            <xsl:if test="($pMetaData/user/@id = '1') and (count($pFolder/file[size>2048000000])>0)">
                <div>
                    <xsl:text>Some files are larger that 2 GB, please use </xsl:text>
                    <a href="ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/experiment/{substring($pMetaData/accession, 3, 4)}/{$pMetaData/accession}">ArrayExpress FTP</a>
                    <xsl:text> to download these.</xsl:text>
                </div>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="string-length($vComment)>0">
            <div class="ae_comment"><xsl:copy-of select="$vComment"/></div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="list-files">
        <xsl:param name="pFolder"/>

        <xsl:variable name="vAccession" select="$pFolder/@accession"/>

        <table class="ae_files_table" border="0" cellpadding="0" cellspacing="0">
            <tbody>
                <xsl:if test="not($pFolder/file)">
                    <tr><td class="td_all" colspan="3"><div>No files</div></td></tr>
                </xsl:if>
                <xsl:for-each select="$pFolder/file[not($kind) or (@kind = $kind)]">
                    <xsl:sort select="contains(lower-case(@name), 'readme')" order="descending"/>
                    <xsl:sort select="@kind = 'raw' or @kind = 'fgem'" order="descending"/>
                    <xsl:sort select="@kind = 'adf' or @kind = 'idf' or @kind = 'sdrf'" order="descending"/>
                    <xsl:sort select="lower-case(@name)" order="ascending"/>
                    <tr>
                        <td class="td_name"><a href="{$vBaseUrl}/files/{$vAccession}/{@name}"><xsl:value-of select="@name"/></a></td>
                        <td class="td_size"><xsl:value-of select="ae:formatfilesize(@size)"/></td>
                        <td class="td_date"><xsl:value-of select="@lastmodified"/></td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>

</xsl:stylesheet>
