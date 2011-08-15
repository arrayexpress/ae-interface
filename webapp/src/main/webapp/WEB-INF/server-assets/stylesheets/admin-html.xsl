<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="ae search html xs"
                exclude-result-prefixes="ae search html xs"
                version="2.0">

    <xsl:param name="userid"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-file-functions.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">Migration Status | ArrayExpress Archive | EBI</xsl:with-param>
                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_common_20.css" type="text/css"/>
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_admin_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.cookie-1.0.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_admin_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">
        <div id="ae_contents_box_100pc">
            <xsl:choose>
                <xsl:when test="not($userid)">
                    <xsl:variable name="vTotalVisibleExperiments" select="count(search:queryIndex('experiments', 'visible:true'))"/>
                    <xsl:variable name="vPublicVisibleExperiments" select="count(search:queryIndex('experiments', 'visible:true public:true'))"/>
                    <xsl:variable name="vPrivateVisibleExperiments" select="$vTotalVisibleExperiments - $vPublicVisibleExperiments"/>

                    <xsl:variable name="vTotalAe1Experiments" select="count(search:queryIndex('experiments', 'source:ae1'))"/>
                    <xsl:variable name="vPublicAe1Experiments" select="count(search:queryIndex('experiments', 'source:ae1 public:true'))"/>
                    <xsl:variable name="vPrivateAe1Experiments" select="$vTotalAe1Experiments - $vPublicAe1Experiments"/>
                    <xsl:variable name="vMigratedAe1Experiments" select="count(search:queryIndex('experiments', 'source:ae1 migrated:true'))"/>
                    <xsl:variable name="vOldAe1Experiments" select="$vTotalAe1Experiments - $vMigratedAe1Experiments"/>

                    <xsl:variable name="vTotalAe2Experiments" select="count(search:queryIndex('experiments', 'source:ae2'))"/>
                    <xsl:variable name="vPublicAe2Experiments" select="count(search:queryIndex('experiments', 'source:ae2 public:true'))"/>
                    <xsl:variable name="vPrivateAe2Experiments" select="$vTotalAe2Experiments - $vPublicAe2Experiments"/>
                    <xsl:variable name="vMigratedAe2Experiments" select="count(search:queryIndex('experiments', 'source:ae2 migrated:true'))"/>
                    <xsl:variable name="vNewAe2Experiments" select="$vTotalAe2Experiments - $vMigratedAe2Experiments"/>

                    <xsl:variable name="vVisibleAe1Experiments" select="count(search:queryIndex('experiments', 'visible:true source:ae1'))"/>
                    <xsl:variable name="vVisibleAe2Experiments" select="count(search:queryIndex('experiments', 'visible:true source:ae2'))"/>

                    <xsl:variable name="vTotalAe1Arrays" select="count(search:queryIndex('arrays', 'source:ae1'))"/>
                    <xsl:variable name="vPublicAe1Arrays" select="count(search:queryIndex('arrays', 'source:ae1 public:true'))"/>
                    <xsl:variable name="vPrivateAe1Arrays" select="$vTotalAe1Arrays - $vPublicAe1Arrays"/>
                    <xsl:variable name="vMigratedAe1Arrays" select="count(search:queryIndex('arrays', 'source:ae1 migrated:true'))"/>
                    <xsl:variable name="vOldAe1Arrays" select="$vTotalAe1Arrays - $vMigratedAe1Arrays"/>

                    <xsl:variable name="vTotalAe2Arrays" select="count(search:queryIndex('arrays', 'source:ae2'))"/>
                    <xsl:variable name="vPublicAe2Arrays" select="count(search:queryIndex('arrays', 'source:ae2 public:true'))"/>
                    <xsl:variable name="vPrivateAe2Arrays" select="$vTotalAe2Arrays - $vPublicAe2Arrays"/>
                    <xsl:variable name="vMigratedAe2Arrays" select="count(search:queryIndex('arrays', 'source:ae2 migrated:true'))"/>
                    <xsl:variable name="vNewAe2Arrays" select="$vTotalAe2Arrays - $vMigratedAe2Arrays"/>

                    <xsl:variable name="vTotalAe1Users" select="count(search:queryIndex('users', 'source:ae1'))"/>
                    <xsl:variable name="vMigratedAe1Users" select="count(search:queryIndex('users', 'source:ae1 migrated:true'))"/>
                    <xsl:variable name="vOldAe1Users" select="$vTotalAe1Users - $vMigratedAe1Users"/>

                    <xsl:variable name="vTotalAe2Users" select="count(search:queryIndex('users', 'source:ae2'))"/>
                    <xsl:variable name="vMigratedAe2Users" select="count(search:queryIndex('users', 'source:ae2 migrated:true'))"/>
                    <xsl:variable name="vNewAe2Users" select="$vTotalAe2Users - $vMigratedAe2Users"/>

                    <xsl:variable name="vLastUpdatedAe1">
                        <xsl:for-each select="search:queryIndex('events', 'category:experiments-update-ae1 success:true')">
                            <xsl:sort select="id" order="descending" data-type="number"/>
                            <xsl:if test="position() = 1">
                                <xsl:copy-of select="*"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="vLastUpdatedAe2">
                        <xsl:for-each select="search:queryIndex('events', 'category:experiments-update-ae2 success:true')">
                            <xsl:sort select="id" order="descending" data-type="number"/>
                            <xsl:if test="position() = 1">
                                <xsl:copy-of select="*"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>

                    <div id="ae_content">
                        <div id="ae_adm_header">
                            <img id="ae_top_secret_img" src="assets/images/ae_top_secret.gif" width="200" height="75" alt="Top Secret!"/>
                            <div id="ae_adm_h1">Migration Status Report</div>
                            <div id="ae_adm_h2"><xsl:value-of select="/application/@name"/></div>
                        </div>

                        <div class="ae_adm_table_box">
                            <table class="ae_adm_table" border="0" cellpadding="0" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th class="col_item">Experiments</th>
                                        <th class="col_ae1">AE1</th>
                                        <th class="col_ae2">AE2</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td class="col_item">Public</td>
                                        <td class="col_ae1"><a href="browse.html?keywords=source:ae1+public:true"><xsl:value-of select="$vPublicAe1Experiments"/></a></td>
                                        <td class="col_ae2"><a href="browse.html?keywords=source:ae2+public:true"><xsl:value-of select="$vPublicAe2Experiments"/></a></td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">Private</td>
                                        <td class="col_ae1"><a href="browse.html?keywords=source:ae1+public:false"><xsl:value-of select="$vPrivateAe1Experiments"/></a></td>
                                        <td class="col_ae2"><a href="browse.html?keywords=source:ae2+public:false"><xsl:value-of select="$vPrivateAe2Experiments"/></a></td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">Old</td>
                                        <td class="col_ae1"><a href="browse.html?keywords=source:ae1+migrated:false"><xsl:value-of select="$vOldAe1Experiments"/></a></td>
                                        <td class="col_ae2">-</td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">Migrated</td>
                                        <td class="col_ae1"><a href="browse.html?keywords=source:ae1+migrated:true"><xsl:value-of select="$vMigratedAe1Experiments"/></a></td>
                                        <td class="col_ae2"><a href="browse.html?keywords=source:ae2+migrated:true"><xsl:value-of select="$vMigratedAe2Experiments"/></a></td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">New</td>
                                        <td class="col_ae1">-</td>
                                        <td class="col_ae2"><a href="browse.html?keywords=source:ae2+migrated:false"><xsl:value-of select="$vNewAe2Experiments"/></a></td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">Total</td>
                                        <td class="col_ae1"><a href="browse.html?keywords=source:ae1"><xsl:value-of select="$vTotalAe1Experiments"/></a></td>
                                        <td class="col_ae2"><a href="browse.html?keywords=source:ae2"><xsl:value-of select="$vTotalAe2Experiments"/></a></td>
                                    </tr>
                                </tbody>
                            </table>
                            <table class="ae_adm_table" border="0" cellpadding="0" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th class="col_item">Array Designs</th>
                                        <th class="col_ae1">AE1</th>
                                        <th class="col_ae2">AE2</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td class="col_item">Public</td>
                                        <td class="col_ae1"><a href="arrays/browse.html?keywords=source:ae1+public:true"><xsl:value-of select="$vPublicAe1Arrays"/></a></td>
                                        <td class="col_ae2"><a href="arrays/browse.html?keywords=source:ae2+public:true"><xsl:value-of select="$vPublicAe2Arrays"/></a></td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">Private</td>
                                        <td class="col_ae1"><a href="arrays/browse.html?keywords=source:ae1+public:false"><xsl:value-of select="$vPrivateAe1Arrays"/></a></td>
                                        <td class="col_ae2"><a href="arrays/browse.html?keywords=source:ae2+public:false"><xsl:value-of select="$vPrivateAe2Arrays"/></a></td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">Old</td>
                                        <td class="col_ae1"><a href="arrays/browse.html?keywords=source:ae1+migrated:false"><xsl:value-of select="$vOldAe1Arrays"/></a></td>
                                        <td class="col_ae2">-</td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">Migrated</td>
                                        <td class="col_ae1"><a href="arrays/browse.html?keywords=source:ae1+migrated:true"><xsl:value-of select="$vMigratedAe1Arrays"/></a></td>
                                        <td class="col_ae2"><a href="arrays/browse.html?keywords=source:ae2+migrated:true"><xsl:value-of select="$vMigratedAe2Arrays"/></a></td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">New</td>
                                        <td class="col_ae1">-</td>
                                        <td class="col_ae2"><a href="arrays/browse.html?keywords=source:ae2+migrated:false"><xsl:value-of select="$vNewAe2Arrays"/></a></td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">Total</td>
                                        <td class="col_ae1"><a href="arrays/browse.html?keywords=source:ae1"><xsl:value-of select="$vTotalAe1Arrays"/></a></td>
                                        <td class="col_ae2"><a href="arrays/browse.html?keywords=source:ae2"><xsl:value-of select="$vTotalAe2Arrays"/></a></td>
                                    </tr>
                                </tbody>
                            </table>
                            <table class="ae_adm_table" border="0" cellpadding="0" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th class="col_item">Users</th>
                                        <th class="col_ae1">AE1</th>
                                        <th class="col_ae2">AE2</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td class="col_item">Old</td>
                                        <td class="col_ae1"><a href="users/browse.html?keywords=source:ae1+migrated:false"><xsl:value-of select="$vOldAe1Users"/></a></td>
                                        <td class="col_ae2">-</td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">Migrated</td>
                                        <td class="col_ae1"><a href="users/browse.html?keywords=source:ae1+migrated:true"><xsl:value-of select="$vMigratedAe1Users"/></a></td>
                                        <td class="col_ae2"><a href="users/browse.html?keywords=source:ae2+migrated:true"><xsl:value-of select="$vMigratedAe2Users"/></a></td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">New</td>
                                        <td class="col_ae1">-</td>
                                        <td class="col_ae2"><a href="users/browse.html?keywords=source:ae2+migrated:false"><xsl:value-of select="$vNewAe2Users"/></a></td>
                                    </tr>
                                    <tr>
                                        <td class="col_item">Total</td>
                                        <td class="col_ae1"><a href="users/browse.html?keywords=source:ae1"><xsl:value-of select="$vTotalAe1Users"/></a></td>
                                        <td class="col_ae2"><a href="users/browse.html?keywords=source:ae2"><xsl:value-of select="$vTotalAe2Users"/></a></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="ae_adm_last_updated_box">
                            <div>
                                <xsl:text>AE1 </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="exists($vLastUpdatedAe1/*)">
                                        <xsl:text> last updated </xsl:text>
                                        <xsl:value-of select="ae:formatDateTime($vLastUpdatedAe1/datetime)"/>
                                        <xsl:text> from </xsl:text>
                                        <xsl:value-of select="$vLastUpdatedAe1/location"/>
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="ae:formatDateTime($vLastUpdatedAe1/lastmodified)"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>never updated</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </div>
                        <div class="ae_adm_last_updated_box">
                            <div>
                                <xsl:text>AE2 </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="exists($vLastUpdatedAe2/*)">
                                        <xsl:text> last updated </xsl:text>
                                        <xsl:value-of select="ae:formatDateTime($vLastUpdatedAe2/datetime)"/>
                                        <xsl:text> from </xsl:text>
                                        <xsl:value-of select="$vLastUpdatedAe2/location"/>
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="ae:formatDateTime($vLastUpdatedAe2/lastmodified)"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>never updated</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </div>
                    </div>
                </xsl:when>
                <xsl:when test="$userid = '1'">
                    <div id="ae_admin_content">
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
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="block-access-restricted"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

</xsl:stylesheet>
