<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ae="http://www.ebi.ac.uk/arrayexpress/XSLT/Extension"
    xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
    extension-element-prefixes="xs ae aejava"
    exclude-result-prefixes="xs ae aejava"                
    version="2.0">
    <xsl:output method="xml" version="1.0" encoding="UTF8" indent="no"/>
    
    <xsl:param name="rootFolder"/>
    
    <xsl:variable name="vRoot" select="$rootFolder"/>
    
    <xsl:include href="ae-file-functions.xsl"/>
    
    <xsl:function name="ae:isFolder" as="xs:boolean">
        <xsl:param name="pRow"/>
        <xsl:value-of select="starts-with($pRow/col[1], 'd')"/>
    </xsl:function>
    
    <xsl:function name="ae:getAccess" as="xs:string">
        <xsl:param name="pRow"/>
        <xsl:value-of select="substring($pRow/col[1], 2)"/>
    </xsl:function>
    
    <xsl:function name="ae:getOwner" as="xs:string">
        <xsl:param name="pRow"/>
        <xsl:value-of select="$pRow/col[3]"/>
    </xsl:function>
    
    <xsl:function name="ae:getGroup" as="xs:string">
        <xsl:param name="pRow"/>
        <xsl:value-of select="$pRow/col[4]"/>
    </xsl:function>
    
    <xsl:function name="ae:getSize" as="xs:integer">
        <xsl:param name="pRow"/>
        <xsl:value-of select="$pRow/col[5]"/>
    </xsl:function>
    
    <xsl:function name="ae:getModifyDate" as="xs:dateTime">
        <xsl:param name="pRow"/>
        <xsl:value-of select="concat($pRow/col[6], 'T', $pRow/col[7], ':00')"/>
    </xsl:function>
    
    <xsl:function name="ae:getName">
        <xsl:param name="pRow"/>
        <xsl:value-of select="replace($pRow/col[8], '.+/([^/]+)$', '$1')"/>
    </xsl:function>
    
    <xsl:function name="ae:getExtension" as="xs:string">
        <xsl:param name="pRow"/>
        <xsl:choose>
            <xsl:when test="ends-with($pRow/col[8], '.tar.gz')">
                <xsl:text>tar.gz</xsl:text>    
            </xsl:when>
            <xsl:when test="not(contains($pRow/col[8], '.'))">
                <xsl:text/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($pRow/col[8], '.+[.]([^.]+)$', '$1')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ae:getFileKind" as="xs:string">
        <xsl:param name="pRow"/>
        <xsl:variable name="vPath" select="$pRow/col[8]"/>
        <xsl:choose>
            <xsl:when test="matches($vPath, '[.]processed[.](\d+[.])?(zip|tgz|tar[.]gz)$')">
                <xsl:text>fgem</xsl:text>    
            </xsl:when>
            <xsl:when test="matches($vPath, '[.]raw[.](\d+[.])?(zip|tgz|tar[.]gz)$')">
                <xsl:text>raw</xsl:text>    
            </xsl:when>
            <xsl:when test="matches($vPath, '[.]cel[.](\d+[.])?(zip|tgz|tar[.]gz)$')">
                <xsl:text>cel</xsl:text>    
            </xsl:when>
            <xsl:when test="matches($vPath, '[.]mageml[.](zip|tgz|tar[.]gz)$')">
                <xsl:text>mageml</xsl:text>    
            </xsl:when>
            <xsl:when test="matches($vPath, '[.]adf[.](txt|xls)$')">
                <xsl:text>adf</xsl:text>    
            </xsl:when>
            <xsl:when test="matches($vPath, '[.]idf[.](txt|xls)$')">
                <xsl:text>idf</xsl:text>    
            </xsl:when>
            <xsl:when test="matches($vPath, '[.]sdrf[.](txt|xls)$')">
                <xsl:text>sdrf</xsl:text>    
            </xsl:when>
            <xsl:when test="matches($vPath, '[.]2columns[.](txt|xls)$')">
                <xsl:text>twocolumns</xsl:text>    
            </xsl:when>
            <xsl:when test="matches($vPath, '[.]biosamples[.](map|png|svg)$')">
                <xsl:text>biosamples</xsl:text>    
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ae:getFolder" as="xs:string">
        <xsl:param name="pRow"/>
        <xsl:choose>
            <xsl:when test="ae:isFolder($pRow)">
                <xsl:value-of select="$pRow/col[8]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($pRow/col[8], '/[^/]+$', '')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ae:getFolderKind" as="xs:string">
        <xsl:param name="pPath"/>
        <xsl:choose>
            <xsl:when test="contains($pPath, '/array/')">
                <xsl:value-of select="'array'"/>
            </xsl:when>
            <xsl:when test="contains($pPath, '/experiment/')">
                <xsl:value-of select="'experiment'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ae:getAccession" as="xs:string">
        <xsl:param name="pPath"/>
        
        <xsl:value-of select="replace($pPath, '.+/([aAeE]-\w{4}-.+)$', '$1')"/>
    </xsl:function>
    
    <xsl:function name="ae:getRelativePath" as="xs:string">
        <xsl:param name="pPath" as="xs:string"/>
        <xsl:value-of select="replace($pPath, concat('^', $vRoot), '')"/>
    </xsl:function>
    
    <xsl:template match="table">
        <files root="{$vRoot}">
            <xsl:for-each-group select="row" group-by="ae:getFolder(.)">
                <xsl:variable name="vFolder" select="current-group()[ae:isFolder(.)]"/>
                <xsl:if test="$vFolder">
                    <xsl:variable name="vAccession" select="ae:getAccession(current-grouping-key())"/>
                    <folder
                        location="{ae:getRelativePath(current-grouping-key())}"
                        kind="{ae:getFolderKind(current-grouping-key())}"
                        accession="{$vAccession}"
                        owner="{ae:getOwner($vFolder)}"
                        group="{ae:getGroup($vFolder)}"
                        access="{ae:getAccess($vFolder)}"
                        lastmodified="{ae:getModifyDate($vFolder)}">
                        <xsl:for-each select="current-group()[not(ae:isFolder(.))]">
                            <xsl:variable name="vFileKind" select="ae:getFileKind(.)"/>
                            <file
                                name="{ae:getName(.)}"
                                extension="{ae:getExtension(.)}"
                                kind="{$vFileKind}"
                                owner="{ae:getOwner($vFolder)}"
                                group="{ae:getGroup(.)}"
                                access="{ae:getAccess(.)}"
                                size="{ae:getSize(.)}"
                                lastmodified="{ae:getModifyDate(.)}">
                                <xsl:if test="$vFileKind = 'raw' or $vFileKind = 'fgem'">
                                    <xsl:call-template name="add-dataformat-attribute">
                                        <xsl:with-param name="pAccession" select="$vAccession"/>
                                        <xsl:with-param name="pName" select="@name"/>
                                        <xsl:with-param name="pKind" select="@kind"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </file>
                            
                        </xsl:for-each>
                    </folder>
                </xsl:if>    
            </xsl:for-each-group>
        </files>    
    </xsl:template>
    
    <xsl:function name="ae:getDataFormat">
        <xsl:param name="pBDG"/>
        <xsl:param name="pKind"/>
        <xsl:variable name="vIsDerived">
            <xsl:choose>
                <xsl:when test="$pKind = 'fgem'">
                    <xsl:text>1</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join(distinct-values($pBDG[isderived = $vIsDerived]/dataformat), ', ')"/>
    </xsl:function>
    
    
    <xsl:template name="add-dataformat-attribute">
        <xsl:param name="pAccession"/>
        <xsl:param name="pName"/>
        <xsl:param name="pKind"/>
        
        <xsl:variable name="vExperiment" select="aejava:getAcceleratorValueAsSequence('visible-experiments', $pAccession)"/>
        <xsl:attribute name="dataformat" select="ae:getDataFormat($vExperiment/bioassaydatagroup, $pKind)"/>
    </xsl:template>
</xsl:stylesheet>
