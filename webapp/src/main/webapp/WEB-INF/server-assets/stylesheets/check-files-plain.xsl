<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2013 European Molecular Biology Laboratory
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
                extension-element-prefixes="xs fn ae search"
                exclude-result-prefixes="xs fn ae search"
                version="2.0">
    
    <xsl:param name="rescanMessage" as="xs:string"/>

    <xsl:output method="text" indent="no" encoding="US-ASCII"/>

    <xsl:variable name="vExperiments" select="search:queryIndex('experiments', 'visible:true')"/>
    <xsl:variable name="vArrays" select="search:queryIndex('arrays', 'visible:true')"/>

    <!--
    <xsl:variable name="experiments">
        <experiment><accession>E-AFMX-1</accession><user>1</user></experiment>
        <experiment><accession>E-AFMX-2</accession><user>1</user></experiment>
        <experiment><accession>E-AFMX-10</accession><user>1</user></experiment>
    </xsl:variable>
    <xsl:variable name="vExperiments" select="$experiments/experiment"/>
    <xsl:variable name="arrays">
        <array_design><accession>A-AFFY-1</accession><user id="1"/></array_design>
        <array_design><accession>A-AFFY-2</accession><user id="1"/></array_design>
        <array_design><accession>A-AFFY-10</accession><user id="1"/></array_design>
    </xsl:variable>
    <xsl:variable name="vArrays" select="$arrays/array_design"/>
    -->
    
    <xsl:template match="/files">
        <xsl:if test="string-length($rescanMessage)">
            <xsl:text>================================================================================&#10;</xsl:text>
            <xsl:text> IMPORTANT: please inspect the following message from file system scanner&#10;</xsl:text>
            <xsl:text>            before analysing checker report results&#10;</xsl:text>
            <xsl:text>---&#10;</xsl:text>
            <xsl:value-of select="$rescanMessage"/><xsl:text>&#10;</xsl:text>
            <xsl:text>================================================================================&#10;&#10;</xsl:text>
        </xsl:if>

        <xsl:variable name="vExperimentFolders" select="folder[@kind='experiment']"/>
        <xsl:variable name="vArrayFolders" select="folder[@kind='array']"/>
        
        <!-- 
            1. check directory exists
            2. check directory ownership; tomcat/microarray
            3. check directory permissions; rwxr-xr-x for public; rwxr-x... for private
            4. check idf and sdrf files presence
            5. check file name is unique within folder
        -->
        
        <xsl:text>--- EXPERIMENTS ----------------------------------------------------------------&#10;</xsl:text>
        <xsl:for-each select="$vExperiments">
            <xsl:sort select="substring(accession, 3, 4)" order="ascending"/>
            <xsl:sort select="substring(accession, 8)" order="ascending" data-type="number"/>
            
            <xsl:variable name="vExpFolder" select="$vExperimentFolders[@accession = current()/accession]"/>
            <xsl:choose>
                <xsl:when test="not($vExpFolder)">
                    <xsl:value-of select="current()/accession"/>
                    <xsl:text> - directory not found or inaccessible&#10;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$vExpFolder/@owner != 'tomcat'">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - owner is "</xsl:text>
                        <xsl:value-of select="$vExpFolder/@owner"/>
                        <xsl:text>", should be "tomcat"&#10;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$vExpFolder/@group != 'microarray'">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - group is "</xsl:text>
                        <xsl:value-of select="$vExpFolder/@group"/>
                        <xsl:text>", should be "microarray"&#10;</xsl:text>
                    </xsl:if>
                    <xsl:if test="current()/user/@id = '1' and not(matches($vExpFolder/@access,'r.xr.xr.x'))">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - directory permissions "</xsl:text>
                        <xsl:value-of select="$vExpFolder/@access"/>
                        <xsl:text>", should be "r?xr?xr?x"&#10;</xsl:text>
                    </xsl:if>
                    <xsl:if test="not(current()/user/@id = '1') and not(matches($vExpFolder/@access,'r.xr.x---'))">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - private experiment directory permissions "</xsl:text>
                        <xsl:value-of select="$vExpFolder/@access"/>
                        <xsl:text>", should be "r?xr?x---"&#10;</xsl:text>
                    </xsl:if>            
                    <xsl:if test="not($vExpFolder/file[@kind = 'idf'])">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - missing IDF file&#10;</xsl:text>
                    </xsl:if>            
                    <xsl:if test="not($vExpFolder/file[@kind = 'sdrf'])">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - missing SDRF file(s)&#10;</xsl:text>
                    </xsl:if>
                    <xsl:for-each-group select="$vExpFolder/file" group-by="@name">
                        <xsl:if test="fn:count(fn:current-group()) > 1">
                            <xsl:text> - multiple files with name </xsl:text>
                            <xsl:value-of select="fn:current-grouping-key()"/>
                            <xsl:text> found in the following locations: </xsl:text>
                            <xsl:value-of select="fn:string-join(fn:current-group()/@location, ', ')"/>
                        </xsl:if>
                    </xsl:for-each-group>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>

        <xsl:variable name="vExperimentAccessions" as="xs:string" select="concat('|', string-join($vExperiments/accession, '|'), '|')"/>
        <xsl:variable name="vOrphanExperimentFolders" select="$vExperimentFolders[not(contains($vExperimentAccessions, concat('|', @accession, '|')))]"/>

        <xsl:if test="count($vOrphanExperimentFolders) > 0">
            <xsl:text>Found </xsl:text>
            <xsl:value-of select="count($vOrphanExperimentFolders)"/>
            <xsl:text> experiment FTP directories without matching experiments in the database:&#10;&#10;</xsl:text>
            <xsl:value-of select="string-join($vOrphanExperimentFolders/@accession, ', ')"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>        

        <xsl:text>&#10;--- ARRAYS ---------------------------------------------------------------------&#10;</xsl:text>
        <!-- 
            1. check directory exists
            2. check directory ownership; tomcat/microarray
            3. check directory permissions; rwxr-xr-x for public; rwxr-x... for private
            4. check adf file presence
        -->
        <xsl:for-each select="$vArrays">
            <xsl:sort select="substring(accession, 3, 4)" order="ascending"/>
            <xsl:sort select="substring(accession, 8)" order="ascending" data-type="number"/>

            <xsl:variable name="vArrayFolder" select="$vArrayFolders[@accession = current()/accession]"/>
            <xsl:choose>
                <xsl:when test="not($vArrayFolder)">
                    <xsl:value-of select="current()/accession"/>
                    <xsl:text> - directory not found or inaccessible&#10;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$vArrayFolder/@owner != 'tomcat'">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - owner is "</xsl:text>
                        <xsl:value-of select="$vArrayFolder/@owner"/>
                        <xsl:text>", should be "tomcat"&#10;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$vArrayFolder/@group != 'microarray'">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - group is "</xsl:text>
                        <xsl:value-of select="$vArrayFolder/@group"/>
                        <xsl:text>", should be "microarray"&#10;</xsl:text>
                    </xsl:if>
                    <xsl:if test="current()/user/@id = '1' and not(matches($vArrayFolder/@access,'r.xr.xr.x'))">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - directory permissions "</xsl:text>
                        <xsl:value-of select="$vArrayFolder/@access"/>
                        <xsl:text>", should be "r?xr?xr?x"&#10;</xsl:text>
                    </xsl:if>
                    <xsl:if test="not(current()/user/@id = '1') and not(matches($vArrayFolder/@access,'r.xr.x---'))">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - private array directory permissions "</xsl:text>
                        <xsl:value-of select="$vArrayFolder/@access"/>
                        <xsl:text>", should be "r?xr?x---"&#10;</xsl:text>
                    </xsl:if>            
                    <xsl:if test="not($vArrayFolder/file[@kind = 'adf'])">
                        <xsl:value-of select="current()/accession"/>
                        <xsl:text> - missing ADF file&#10;</xsl:text>
                    </xsl:if>
                    <xsl:for-each-group select="$vArrayFolder/file" group-by="@name">
                        <xsl:if test="fn:count(fn:current-group()) > 1">
                            <xsl:text> - multiple files with name </xsl:text>
                            <xsl:value-of select="fn:current-grouping-key()"/>
                            <xsl:text> found in the following locations: </xsl:text>
                            <xsl:value-of select="fn:string-join(fn:current-group()/@location, ', ')"/>
                        </xsl:if>
                    </xsl:for-each-group>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>

        <xsl:variable name="vArrayAccessions" as="xs:string" select="concat('|', string-join($vArrays/accession, '|'), '|')"/>
        <xsl:variable name="vOrphanArrayFolders" select="$vArrayFolders[not(contains($vArrayAccessions, concat('|', @accession, '|')))]"/>
        
        <xsl:if test="count($vOrphanArrayFolders) > 0">
            <xsl:text>Found </xsl:text>
            <xsl:value-of select="count($vOrphanArrayFolders)"/>
            <xsl:text> array FTP directories without matching arrays in the database:&#10;&#10;</xsl:text>
            <xsl:value-of select="string-join($vOrphanArrayFolders/@accession, ', ')"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>        
        
    </xsl:template>
</xsl:stylesheet>
