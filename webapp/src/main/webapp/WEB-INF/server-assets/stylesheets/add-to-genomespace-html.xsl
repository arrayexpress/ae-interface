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
                extension-element-prefixes="xs fn ae search"
                exclude-result-prefixes="xs fn ae search html"
                version="2.0">

    <xsl:param name="accession"/>

    <xsl:variable name="vAccession" select="fn:upper-case($accession)"/>

    <xsl:include href="ae-html-page.xsl"/>

    <xsl:template match="/">
        <xsl:call-template name="ae-page">
            <xsl:with-param name="pIsSearchVisible" select="fn:true()"/>
            <xsl:with-param name="pSearchInputValue"/>
            <xsl:with-param name="pExtraSearchFields"/>
            <xsl:with-param name="pTitleTrail">
                <xsl:text>Send to GenomeSpace &lt; </xsl:text>
                <xsl:value-of select="$vAccession"/>
                <xsl:text> &lt; Browse</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="pExtraCSS">
                <link rel="stylesheet" href="{$context-path}/assets/stylesheets/ae-add-to-gs-1.0.0.css" type="text/css"/>
            </xsl:with-param>
            <xsl:with-param name="pBreadcrumbTrail">
                <li><a href="{$context-path}/browse.html">Browse</a></li>
                <li><a href="{$context-path}/experiments/{$vAccession}/"><xsl:value-of select="$vAccession"/></a></li>
                <li><xsl:text>Send to GenomeSpace</xsl:text></li>
            </xsl:with-param>
            <xsl:with-param name="pExtraJS">
                <script src="{$context-path}/assets/scripts/jquery.ae-add-to-gs-1.0.0.js" type="text/javascript"/>
            </xsl:with-param>
            <xsl:with-param name="pExtraBodyClasses"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="ae-content-section">
        <xsl:variable name="vFolder" select="ae:getMappedValue('ftp-folder', $vAccession)"/>
        <xsl:variable name="vMetaData" select="search:queryIndex('experiments', fn:concat('accession:', $vAccession, if ($userid) then fn:concat(' userid:(', $userid, ')') else ''))[accession = $vAccession]" />
        <section>
            <div id="ae-content">
                <xsl:choose>
                    <xsl:when test="exists($vFolder) and exists($vMetaData)">
                        <div id="ae_contents_box_740px">
                            <div id="ae_content">
                                <div id="gs_title"><img src="{$context-path}/assets/images/send-to-gs-header.gif" width="480" height="54" alt="Send to GenomeSpace"/></div>
                                <div id="gs_description"/>
                                <div id="gs_login_section" style="display:none">
                                    Please <a href="{$context-path}/gs/auth">login to (or register an account at) GenomeSpace</a> first.
                                </div>
                                <div id="gs_auth_message" style="display:none"/>
                                <div id="gs_upload_section" style="display:none">
                                    <div id="gs_upload_prompt">You have successfully logged in to GenomeSpace, <span id="gs_auth_username"/>. Please select files to upload:</div>
                                    <div id="gs_files">
                                        <xsl:for-each select="$vFolder/file[@kind = 'idf' or @kind = 'sdrf' or @kind = 'raw' or @kind = 'processed']">
                                            <xsl:sort select="fn:translate(fn:substring(@kind, 1, 1), 'isrf', 'abcd')"/>
                                            <xsl:sort select="fn:lower-case(@name)" order="ascending"/>
                                            <div id="file_{fn:position()}" class="file_div">
                                                <input id="file_{fn:position()}_check" class="file_check" type="checkbox" checked="true"/>
                                                <label for="file_{fn:position()}_check"><xsl:value-of select="fn:concat(@name, ' (', ae:formatFileSize(@size), ')')"/></label>
                                                <div id="file_{fn:position()}_progress" class="file_progress">
                                                    <img src="{$context-path}/assets/images/empty.gif" width="16" height="16"/>
                                                </div>
                                                <input id="file_{fn:position()}_name" type="hidden" name="file_{fn:position()}_name" value="{@name}"/>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                    <div id="gs_warning" style="display:none">Warning! Target directory&#160;<span id="gs_target_dir"/>&#160;already exists in GenomeSpace.<br/>
                                        The files you are about to upload will be overwritten if present in the directory whilst all other files will remain unchanged.</div>
                                    <div id="gs_upload_button">
                                        <div id="gs_progress_status"/>
                                        <div id="gs_upload_form">
                                            <form name="upload_form" action="" onsubmit="return false">
                                                <input id="ae_accession" type="hidden" name="ae_accession" value="{$vAccession}"/>
                                                <input id="gs_upload_submit" name="gs_upload_submit" type="submit" value="Upload"/>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </xsl:when>
                    <xsl:when test="exists($vFolder) and not(exists($vMetaData))">
                        <xsl:value-of select="ae:httpStatus(403)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ae:httpStatus(404)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </section>
    </xsl:template>

</xsl:stylesheet>
