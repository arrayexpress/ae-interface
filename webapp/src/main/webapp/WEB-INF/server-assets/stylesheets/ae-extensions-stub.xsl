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
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs ae fn html"
    version="2.0">
    
    <xsl:function name="ae:getMappedValue">
        <xsl:param name="pMapName" as="xs:string"/>
        <xsl:param name="pKey" as="xs:string"/>
        <xsl:value-of select="'1'"/>
    </xsl:function>

    <xsl:function name="ae:htmlDocument">
        <xsl:param name="pFileName" as="xs:string"/>
        <html xmlns="http://www.w3.org/1999/xhtml"><body><div id="content"><i>Help!</i></div></body></html>
    </xsl:function>
</xsl:stylesheet>