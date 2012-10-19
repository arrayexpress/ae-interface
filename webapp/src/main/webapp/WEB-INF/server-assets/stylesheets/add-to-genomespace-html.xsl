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
                    <script src="{$basepath}/assets/scripts/jquery-1.8.2.min.js" type="text/javascript"/>
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
                            <xsl:text> > </xsl:text>
                            <a href="{$basepath}/experiments/{upper-case($accession)}/genomespace.html">
                                Send to GenomeSpace
                            </a>
                        </div>
                        <div id="gs_auth_message"></div>
                        <div id="gs_title"><img src="{$basepath}/assets/images/send_to_gs_header.gif" width="480" height="54" alt="Send to GenomeSpace"/></div>
                        <div id="gs_description"></div>
                        <div id="gs_login_section" style="display:none">
                            Please <a href="{$basepath}/gs/auth">login to (or register an account at) GenomeSpace</a> first.
                        </div>
                        <div id="gs_upload_section" style="display:none">
                            <div id="gs_upload_prompt">You have successfully logged in to GenomeSpace, <span id="gs_auth_username"/>. Please select files to upload:</div>
                            <div id="gs_files">
                                <xsl:for-each select="$vFolder/file[@kind = 'idf' or @kind = 'sdrf' or @kind = 'raw' or @kind = 'fgem']">
                                    <xsl:sort select="fn:translate(fn:substring(@kind, 1, 1), 'isrf', 'abcd')"/>
                                    <xsl:sort select="fn:lower-case(@name)" order="ascending"/>
                                    <div id="file_{fn:position()}" class="file_div">
                                        <input id="file_{fn:position()}_check" class="file_check" type="checkbox" checked="true"/>
                                        <label for="file_{fn:position()}_check"><xsl:value-of select="fn:concat(@name, ' (', ae:formatFileSize(@size), ')')"/></label>
                                        <div id="file_{fn:position()}_progress" class="file_progress">
                                            <img src="{$basepath}/assets/images/empty.gif" width="16" height="16"/>
                                        </div>
                                        <input id="file_{fn:position()}_name" type="hidden" name="file_{fn:position()}_name" value="{@name}"/>
                                    </div>
                                </xsl:for-each>
                            </div>
                            <div id="gs_warning" style="display:none">Warning! Target directory <span id="gs_target_dir"/> already exists in GenomeSpace.<br/>
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
                <xsl:call-template name="block-access-restricted"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="block-not-found"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
