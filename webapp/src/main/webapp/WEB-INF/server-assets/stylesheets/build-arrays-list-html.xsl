<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:html="http://www.w3.org/1999/xhtml"
    extension-element-prefixes="html"
    exclude-result-prefixes="html"
    version="2.0">

    <xsl:output omit-xml-declaration="yes" method="html"/>

    <xsl:template match="/experiments">
        <option value="">All arrays</option>
        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'Affymetrix'"/>
            <xsl:with-param name="pGroupSignature" select="'affymetrix'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'Agilent'"/>
            <xsl:with-param name="pGroupSignature" select="'agilent'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'Amersham'"/>
            <xsl:with-param name="pGroupSignature" select="'amersham'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'BuG@S'"/>
            <xsl:with-param name="pGroupSignature" select="'bug@s'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'CATMA'"/>
            <xsl:with-param name="pGroupSignature" select="'catma'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'EMBL'"/>
            <xsl:with-param name="pGroupSignature" select="'embl'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'Illumina'"/>
            <xsl:with-param name="pGroupSignature" select="'illumina'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'ILSI'"/>
            <xsl:with-param name="pGroupSignature" select="'[ilsi]'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'MIT'"/>
            <xsl:with-param name="pGroupSignature" select="'mit'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'NimbleGen'"/>
            <xsl:with-param name="pGroupSignature" select="'nimblegen'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'Sanger Institute'"/>
            <xsl:with-param name="pGroupSignature" select="'sanger'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'Stanford (SMD)'"/>
            <xsl:with-param name="pGroupSignature" select="'smd'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'TIGR'"/>
            <xsl:with-param name="pGroupSignature" select="'tigr'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'Utrecht (UMC)'"/>
            <xsl:with-param name="pGroupSignature" select="'umc'"/>
        </xsl:call-template>

        <xsl:call-template name="optgroup">
            <xsl:with-param name="pGroupTitle" select="'Yale'"/>
            <xsl:with-param name="pGroupSignature" select="'yale'"/>
        </xsl:call-template>

        <optgroup label="Other arrays">
            <xsl:for-each-group select="experiment/arraydesign[name and not(matches(name, 'affymetrix|agilent|amersham|bug@s|catma|embl|illumina|ilsi|mit|nimblegen|sanger|smd|tigr|umc|yale','i'))]" group-by="id">
                <xsl:sort select="lower-case(name)"/>
                <option>
                    <xsl:attribute name="value" select="id"/>
                    <xsl:value-of select="name"/>
                </option>                
            </xsl:for-each-group>
        </optgroup>

    </xsl:template>

    <xsl:template name="optgroup">
        <xsl:param name="pGroupTitle"/>
        <xsl:param name="pGroupSignature"/>
        <optgroup label="{$pGroupTitle} arrays">
            <xsl:for-each-group select="experiment/arraydesign[contains(lower-case(name), $pGroupSignature)]" group-by="id">
                <xsl:sort select="lower-case(name)"/>
                <option>
                    <xsl:attribute name="value" select="id"/>
                    <xsl:value-of select="name"/>
                </option>                
            </xsl:for-each-group>
        </optgroup>
    </xsl:template>

</xsl:stylesheet>
