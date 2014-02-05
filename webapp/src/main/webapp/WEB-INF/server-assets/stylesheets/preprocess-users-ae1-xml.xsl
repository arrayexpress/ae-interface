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
                version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/users">
        <users>
            <xsl:apply-templates select="user">
                <xsl:sort select="id" order="ascending" data-type="number"/>
            </xsl:apply-templates>
        </users>
    </xsl:template>

    <xsl:template match="user">
        <user>
            <xsl:attribute name="source">ae1</xsl:attribute>
            <xsl:copy-of select="*"/>
        </user>
    </xsl:template>

</xsl:stylesheet>