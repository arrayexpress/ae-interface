<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="xs aejava search html"
                exclude-result-prefixes="xs aejava search html"
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
    <xsl:param name="keywords"/>
    <xsl:param name="id"/>
    <xsl:param name="accession"/>

    <xsl:param name="userid"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:variable name="vBrowseMode" select="not($accession) and not($id)"/>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-sort-protocols.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">
                    <xsl:value-of select="if (not($vBrowseMode)) then (if (not($accession)) then concat('Protocol #', $id, ' | ') else concat(upper-case($accession), ' | ')) else ''"/>
                    <xsl:text>Protocols | ArrayExpress Archive | EBI</xsl:text>
                </xsl:with-param>

                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_protocols_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_protocols_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">

        <xsl:variable name="vFilteredProtocols" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredProtocols)"/>

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

        <div id="ae_contents_box_100pc">
            <div id="ae_content">
                <div id="ae_navi">
                    <a href="${interface.application.link.www_domain}/">EBI</a>
                    <xsl:text> > </xsl:text>
                    <a href="{$basepath}">ArrayExpress</a>
                    <xsl:text> > </xsl:text>
                    <a href="{$basepath}/protocols">Protocols</a>
                    <xsl:choose>
                        <xsl:when test="not(not($accession))">
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/protocols/{upper-case($accession)}">
                                <xsl:value-of select="upper-case($accession)"/>
                            </a>
                        </xsl:when>
                        <xsl:when test="not(not($id))">
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/protocols/{$id}">
                                <xsl:value-of select="concat('Protocol #', $id)"/>
                            </a>
                        </xsl:when>
                    </xsl:choose>
                </div>
                <xsl:if test="$vBrowseMode">
                    <div id="ae_query_box">
                        <form id="ae_query_form" method="get" action="browse.html">
                            <fieldset id="ae_keywords_fset">
                                <label for="ae_keywords_field">Protocol accessions, names, types or text [<a href="javascript:aeClearField('#ae_keywords_field')">clear</a>]</label>
                                <input id="ae_keywords_field" type="text" name="keywords" value="{$keywords}" maxlength="255" class="ae_assign_font"/>
                            </fieldset>
                            <div id="ae_submit_box"><input id="ae_query_submit" type="submit" value="Query"/></div>
                            <div id="ae_results_stats">
                                <div>
                                    <xsl:value-of select="$vTotal"/>
                                    <xsl:text> protocol</xsl:text>
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
                                        <th class="col_type sortable">
                                            <xsl:text>Type</xsl:text>
                                            <xsl:call-template name="add-sort">
                                                <xsl:with-param name="pKind" select="'type'"/>
                                            </xsl:call-template>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:call-template name="ae-sort-protocols">
                                        <xsl:with-param name="pProtocols" select="$vFilteredProtocols"/>
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
                                <xsl:text>There are no protocols matching your search criteria found in ArrayExpress Archive.</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="protocol">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>main</xsl:text>
                    <xsl:if test="not($vBrowseMode)">
                        <xsl:text> expanded</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <td class="col_accession">
                    <div>
                        <a href="{$basepath}/protocols/{id}">
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pText" select="accession" />
                                <xsl:with-param name="pFieldName" select="'accession'" />
                            </xsl:call-template>
                        </a>
                        <xsl:if test="not(user/@id = '1')">
                            <img src="{$basepath}/assets/images/silk_lock.gif" width="8" height="9"/>
                        </xsl:if>
                    </div>
                </td>
                <td class="col_name">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="name"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                        <xsl:if test="count(name) = 0">&#160;</xsl:if>
                    </div>
                </td>
                <td class="col_type">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="type"/>
                            <xsl:with-param name="pFieldName" select="'species'"/>
                        </xsl:call-template>
                        <xsl:if test="count(type) = 0"><xsl:text>&#160;</xsl:text></xsl:if>
                    </div>
                </td>
            </tr>
            <xsl:if test="not($vBrowseMode)">
            <tr>
                <td class="col_detail" colspan="3">
                    <div class="detail_table">
                        <xsl:call-template name="detail-table"/>

                    </div>
                </td>
            </tr>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template name="detail-table">
        <xsl:variable name="vExpsWithProtocol" select="search:queryIndex('experiments', concat('visible:true protocol:', id, if ($userid) then concat(' userid:(', $userid, ')') else ''))"/>

        <table border="0" cellpadding="0" cellspacing="0">
            <tbody>
                <xsl:if test="not($userid)">
                    <xsl:call-template name="detail-section">
                        <xsl:with-param name="pName" select="'Source'"/>
                        <xsl:with-param name="pContent"><div>AE2</div></xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Description'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue" select="text"/>
                </xsl:call-template>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="if (count(parameter) &gt; 1) then 'Parameters' else 'Parameter'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue"><xsl:value-of select="string-join(parameter, ', ')"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Hardware'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue" select="hardware"/>
                </xsl:call-template>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Software'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue" select="software"/>
                </xsl:call-template>
                <xsl:call-template name="detail-section">
                    <xsl:with-param name="pName" select="'Links'"/>
                    <xsl:with-param name="pContent">
                        <xsl:choose>
                            <xsl:when test="count($vExpsWithProtocol) > 10">
                               <a href="{$basepath}/browse.html?keywords=protocol:{id}">All <xsl:value-of select="count($vExpsWithProtocol)"/> experiments using protocol <xsl:value-of select="accession"/></a>
                            </xsl:when>
                            <xsl:when test="count($vExpsWithProtocol) > 1">
                                <a href="{$basepath}/browse.html?keywords=protocol:{id}">All experiments using protocol <xsl:value-of select="accession"/></a>
                                <xsl:text>: (</xsl:text>
                                    <xsl:for-each select="$vExpsWithProtocol">
                                        <xsl:sort select="accession"/>
                                        <a href="{$vBaseUrl}/experiments/{accession}">
                                            <xsl:value-of select="accession"/>
                                        </a>
                                        <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                    </xsl:for-each>
                                <xsl:text>)</xsl:text>
                            </xsl:when>
                            <xsl:when test="count($vExpsWithProtocol) = 1">
                                <a href="{$vBaseUrl}/experiments/{$vExpsWithProtocol/accession}">
                                    <xsl:text>Experiment </xsl:text><xsl:value-of select="$vExpsWithProtocol/accession"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </tbody>
        </table>

    </xsl:template>

    <xsl:template name="detail-row">
        <xsl:param name="pName"/>
        <xsl:param name="pFieldName"/>
        <xsl:param name="pValue"/>
        <xsl:if test="$pValue/node() and ($pValue/text() != '')">
            <xsl:call-template name="detail-section">
                <xsl:with-param name="pName" select="$pName"/>
                <xsl:with-param name="pContent">
                    <xsl:for-each select="$pValue">
                        <div>
                            <xsl:apply-templates select="." mode="highlight">
                                <xsl:with-param name="pFieldName" select="$pFieldName"/>
                            </xsl:apply-templates>
                        </div>
                    </xsl:for-each>
                </xsl:with-param>
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
