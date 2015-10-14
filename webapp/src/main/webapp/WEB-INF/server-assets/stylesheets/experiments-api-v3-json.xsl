<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright 2009-2015 European Molecular Biology Laboratory
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
                xmlns:json="http://json.org/"
                extension-element-prefixes="fn json"
                exclude-result-prefixes="fn json"
                version="2.0">

    <xsl:import href="experiments-api-v3.xsl"/>
    <xsl:import href="xml-to-json.xsl"/>
    <xsl:param name="skip-root" as="xs:boolean" select="fn:true()"/>

    <xsl:output method="text" omit-xml-declaration="no" indent="no" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:variable name="vJson" select="fn:true()" as="xs:boolean"/>

    <xsl:template match="/">
        <xsl:variable name="vXml">
            <xsl:call-template name="root"/>
        </xsl:variable>
        <xsl:value-of select="json:generate($vXml)"/>
    </xsl:template>

</xsl:stylesheet>