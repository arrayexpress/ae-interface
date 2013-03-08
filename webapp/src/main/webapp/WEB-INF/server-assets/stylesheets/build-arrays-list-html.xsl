<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    extension-element-prefixes="html fn"
    exclude-result-prefixes="html fn"
    version="2.0">

    <xsl:output omit-xml-declaration="yes" method="html" encoding="UTF-8"/>

    <xsl:template match="/experiments">
        <option value="">All arrays</option>
        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'Top'"/>
            <xsl:with-param name="pOptionsHtml">
                <xsl:variable name="vTopArrays">
                    <xsl:for-each-group select="experiment[source/@visible = 'true']/arraydesign" group-by="accession">
                        <xsl:sort select="fn:count(current-group()/ancestor::node())" data-type="number" order="descending"/>"
                        <xsl:if test="fn:count(current-group()/ancestor::node()) &gt;= 150">
                            <option>
                                <xsl:attribute name="value" select="accession"/>
                                <xsl:value-of select="name"/>
                            </option>
                        </xsl:if>
                    </xsl:for-each-group>
                </xsl:variable>
                <xsl:for-each select="$vTopArrays/option">
                    <xsl:sort select="lower-case(text())"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'Affymetrix'"/>
            <xsl:with-param name="pGroupSignature" select="'affymetrix'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'Agilent'"/>
            <xsl:with-param name="pGroupSignature" select="'agilent'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'Amersham'"/>
            <xsl:with-param name="pGroupSignature" select="'amersham'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'BuG@S'"/>
            <xsl:with-param name="pGroupSignature" select="'bug@s'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'CATMA'"/>
            <xsl:with-param name="pGroupSignature" select="'catma'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'EMBL'"/>
            <xsl:with-param name="pGroupSignature" select="'embl'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'Illumina'"/>
            <xsl:with-param name="pGroupSignature" select="'illumina'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'ILSI'"/>
            <xsl:with-param name="pGroupSignature" select="'[ilsi]'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'MIT'"/>
            <xsl:with-param name="pGroupSignature" select="'mit'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'NimbleGen'"/>
            <xsl:with-param name="pGroupSignature" select="'nimblegen'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'Sanger Institute'"/>
            <xsl:with-param name="pGroupSignature" select="'sanger'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'Stanford (SMD)'"/>
            <xsl:with-param name="pGroupSignature" select="'smd'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'TIGR'"/>
            <xsl:with-param name="pGroupSignature" select="'tigr'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'Utrecht (UMC)'"/>
            <xsl:with-param name="pGroupSignature" select="'umc'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup-by-signature">
            <xsl:with-param name="pGroupTitle" select="'Yale'"/>
            <xsl:with-param name="pGroupSignature" select="'yale'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'Other'"/>
            <xsl:with-param name="pOptionsHtml">
                <xsl:for-each-group select="experiment[source/@visible = 'true']/arraydesign[name and not(fn:matches(name, 'affymetrix|agilent|amersham|bug@s|catma|embl|illumina|ilsi|mit|nimblegen|sanger|smd|tigr|umc|yale','i'))]" group-by="accession">
                    <xsl:sort select="fn:lower-case(name)"/>
                    <option>
                        <xsl:attribute name="value" select="accession"/>
                        <xsl:value-of select="name"/>
                    </option>
                </xsl:for-each-group>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template name="optgroup-by-signature">
        <xsl:param name="pGroupTitle"/>
        <xsl:param name="pGroupSignature"/>
        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="$pGroupTitle"/>
            <xsl:with-param name="pOptionsHtml">
                <xsl:for-each-group select="experiment[source/@visible = 'true']/arraydesign[fn:contains(fn:lower-case(name), $pGroupSignature)]" group-by="accession">
                    <xsl:sort select="fn:lower-case(name)"/>
                    <option>
                        <xsl:attribute name="value" select="accession"/>
                        <xsl:value-of select="name"/>
                    </option>
                </xsl:for-each-group>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="optgroup">
        <xsl:param name="pGroupTitle"/>
        <xsl:param name="pOptionsHtml"/>
        <option disabled="true" value="-">&#x2500;&#x2500; <xsl:value-of select="$pGroupTitle"/> arrays &#x2500;&#x2500;</option>
        <xsl:copy-of select="$pOptionsHtml"/>
    </xsl:template>

</xsl:stylesheet>
