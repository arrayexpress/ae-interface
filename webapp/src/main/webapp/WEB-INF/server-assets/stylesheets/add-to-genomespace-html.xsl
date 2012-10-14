<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:search="http://www.ebi.ac.uk/arrayexpress/XSLT/SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="xs fn ae search"
                exclude-result-prefixes="xs fn ae search html"
                version="2.0">

    <xsl:param name="accession"/>
    <xsl:param name="step"/>
    <xsl:param name="userid"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>
    <xsl:variable name="vAccession" select="fn:upper-case($accession)"/>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">
                    <xsl:value-of select="concat('Send to GenomeSpace | ', $vAccession, ' | ')"/>
                    <xsl:text>Experiments | ArrayExpress Archive | EBI</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_add_to_gs_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.cookie-1.0.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_add_to_gs_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">
        <xsl:variable name="vFolder" select="ae:getAcceleratorValue('ftp-folder', $vAccession)"/>
        <xsl:variable name="vMetaData" select="search:queryIndex('experiments', concat('visible:true accession:', $accession, if ($userid) then concat(' userid:(', $userid, ')') else ''))[accession = $vAccession]" />
        <xsl:choose>
            <xsl:when test="exists($vFolder) and exists($vMetaData)">
                <div id="ae_contents_box_740px">
                    <div id="ae_content">
                        <div id="ae_navi">
                            <a href="${interface.application.link.www_domain}/">EBI</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}">ArrayExpress</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments">Experiments</a>
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments/{upper-case($accession)}">
                                <xsl:value-of select="upper-case($accession)"/>
                            </a>
                        </div>
                        <div>
                            <a href="{$basepath}/gs-auth.txt">Log in to GenomeSpace</a>
                        </div>
                        <!--
                        <xsl:call-template name="list-folder">
                            <xsl:with-param name="pFolder" select="$vFolder"/>
                            <xsl:with-param name="pMetaData" select="$vMetaData"/>
                        </xsl:call-template>
                        <xsl:if test="$vFolderKind='experiment' and not($kind)">
                            <xsl:for-each select="$vMetaData/arraydesign">
                                <xsl:sort select="accession" order="ascending"/>
                                <xsl:variable name="vArrAccession" select="string(accession)"/>
                                <xsl:if test="matches($vArrAccession, '^[aA]-\w{4}-\d+$')">
                                    <xsl:variable name="vArrFolder" select="ae:getAcceleratorValue('ftp-folder', $vArrAccession)"/>
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
                                                <xsl:value-of select="$vArrAccession"/>
                                                <xsl:text> - access restricted.</xsl:text>
                                            </div>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        -->
                    </div>
                </div>
            </xsl:when>
            <xsl:when test="exists($vFolder) and not(exists($vMetaData))">
                <xsl:call-template name="block-access-restricted"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="block-not-found"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
    <xsl:template match="file">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <tr>
                <td class="col_accession">
                    <div>
                        <a href="{$basepath}/files/{../@accession}">
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
                        <a href="{$basepath}/files/{../@accession}/{@name}">
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pQueryId" select="$queryid" />
                                <xsl:with-param name="pText" select="@name"/>
                                <xsl:with-param name="pFieldName"/>
                            </xsl:call-template>
                        </a>
                        <xsl:if test="not(@name)">&#160;</xsl:if>
                    </div>
                </td>
                <td class="col_size">
                    <div>
                        <xsl:value-of select="ae:formatFileSize(@size)"/>
                        <xsl:if test="not(@size)"><xsl:text>&#160;</xsl:text></xsl:if>
                    </div>
                </td>
                <td class="col_lastmodified">
                    <div>
                        <xsl:value-of select="ae:formatDateTime(@lastmodified)"/>
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
            <a href="{$basepath}/{$pFolder/@kind}s/{$pMetaData/accession}">
                <xsl:value-of select="concat(upper-case(substring($pFolder/@kind, 1, 1)),substring($pFolder/@kind, 2))"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$pMetaData/accession"/>
            </a>
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
                    <xsl:sort select="xs:string(contains(lower-case(@name), 'readme'))" order="descending"/>
                    <xsl:sort select="xs:string(@kind = 'raw' or @kind = 'fgem')" order="descending"/>
                    <xsl:sort select="xs:string(@kind = 'adf' or @kind = 'idf' or @kind = 'sdrf')" order="descending"/>
                    <xsl:sort select="lower-case(@name)" order="ascending"/>
                    <tr>
                        <td class="td_name"><a href="{$vBaseUrl}/files/{$vAccession}/{@name}"><xsl:value-of select="@name"/></a></td>
                        <td class="td_size"><xsl:value-of select="ae:formatFileSize(@size)"/></td>
                        <td class="td_date"><xsl:value-of select="ae:formatDateTime(@lastmodified)"/></td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>
    -->
</xsl:stylesheet>
