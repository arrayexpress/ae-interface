<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
    xmlns:html="http://www.w3.org/1999/xhtml"
    extension-element-prefixes="xs aejava html"
    exclude-result-prefixes="xs aejava html"
    version="2.0">

    <xsl:include href="ae-highlight.xsl"/>
    
    <xsl:template name="details">
        <xsl:param name="pBasePath"/>
        <table cellpadding="0" cellspacing="0" border="0">
            <xsl:variable name="vDescription" select="description[string-length(text) > 0 and not(contains(text, '(Generated description)'))]"/>
            <xsl:if test="$vDescription">
                <tr>
                    <td class="name"><div class="name">Description</div></td>
                    <td class="value">
                        <div class="value">
                            <xsl:for-each select="$vDescription">
                                <xsl:sort select="id" data-type="number"/>
                                <xsl:apply-templates select="text" mode="highlight"/>
                            </xsl:for-each>
                        </div>
                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="minseqescores">
                <tr>
                    <td class="name"><div class="name">MINSEQE score</div></td>
                    <td class="value">
                        <div class="value">
                            <xsl:call-template name="min-score">
                                <xsl:with-param name="pScores" select="minseqescores"/>
                                <xsl:with-param name="pKind" select="'minseqe'"/>
                            </xsl:call-template>
                        </div>
                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="miamescores">
                <tr>
                    <td class="name"><div class="name">MIAME score</div></td>
                    <td class="value">
                        <div class="value">
                            <xsl:call-template name="min-score">
                                <xsl:with-param name="pScores" select="miamescores"/>
                                <xsl:with-param name="pKind" select="'miame'"/>
                            </xsl:call-template>
                        </div>
                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="provider[role!='data_coder']">
                <tr>
                    <td class="name"><div class="name">Contact<xsl:if test="count(provider[role!='data_coder']) > 1">s</xsl:if></div></td>
                    <td class="value">
                        <div class="value">
                            <xsl:call-template name="providers"/>
                        </div>
                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="bibliography/*">
                <tr>
                    <td class="name"><div class="name">Citation<xsl:if test="count(bibliography/*) > 1">s</xsl:if></div></td>
                    <td class="value"><div class="value"><xsl:apply-templates select="bibliography"/></div></td>
                </tr>
            </xsl:if>

            <tr>
                <td class="name"><div class="name">Links</div></td>
                <td class="value">
                    <div class="value">
                        <xsl:if test="@loadedinatlas">
                            <div><a href="${interface.application.link.atlas.exp_query.url}{accession}&amp;ref=aebrowse">Query Gene Expression Atlas</a></div>
                        </xsl:if>
                        <xsl:if test="secondaryaccession">
                            <div><xsl:call-template name="secondaryaccession"/></div>
                        </xsl:if>
                        <xsl:if test="arraydesign">
                            <xsl:for-each select="arraydesign">
                                <div>
                                    <a href="{$pBasePath}/arrays/{accession}">
                                        <xsl:text>Array design </xsl:text>
                                        <xsl:call-template name="highlight">
                                            <xsl:with-param name="pText" select="concat(accession, ' - ', name)"/>
                                            <xsl:with-param name="pFieldName" select="'array'"/>
                                        </xsl:call-template>
                                    </a>
                                </div>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="source/@id = 'ae1'">
                            <div>
                                <a href="${interface.application.link.aer_old.base.url}/details?class=MAGE.Experiment_protocols&amp;criteria=Experiment%3D{id}&amp;contextClass=MAGE.Protocol&amp;templateName=Protocol.vm">
                                    <xsl:text>Experimental protocols (old interface)</xsl:text>
                                </a>
                            </div>
                            <div>
                                <a href="${interface.application.link.aer_old.base.url}/result?queryFor=Experiment&amp;eAccession={accession}">Experiment Page (old interface)</a>
                            </div>
                        </xsl:if>
                    </div>
                </td>
            </tr>

            <tr>
                <td class="name"><div class="name">Files</div></td>
                <xsl:choose>
                    <xsl:when test="$vFilesDoc/files/folder[@accession = $vAccession]/file[@kind='raw' or @kind='fgem' or @kind='adf' or @kind='idf' or @kind='sdrf' or @kind='biosamples']">

                        <td class="attrs">
                            <div class="attrs">
                                <table cellpadding="0" cellspacing="0" border="0">
                                    <tbody>
                                        <xsl:call-template name="data-files"/>
                                        <xsl:call-template name="magetab-files"/>
                                        <xsl:call-template name="image-files"/>
                                        <xsl:call-template name="magetab-files-array"/>
                                    </tbody>
                                </table>
                            </div>
                            <div class="attrs">
                                <a href="{$pBasePath}/files/{$pAccession}">
                                    <img src="{$pBasePath}/assets/images/silk_ftp.gif" width="16" height="16" alt=""/>
                                    <xsl:text>Browse all available files</xsl:text>
                                </a>
                            </div>

                        </td>
                    </xsl:when>
                    <xsl:otherwise>
                        <td class="value">
                            <div class="value">
                                <a href="{$pBasePath}/files/{$pAccession}">
                                    <img src="{$pBasePath}/assets/images/silk_ftp.gif" width="16" height="16" alt=""/>
                                    <xsl:text>Browse all available files</xsl:text>
                                </a>
                            </div>
                        </td>
                    </xsl:otherwise>
                </xsl:choose>
            </tr>
            <xsl:variable name="vExpTypeAndDesign" select="experimenttype | experimentdesign"/>
            <xsl:if test="$vExpTypeAndDesign">
                <tr>

                    <td class="name"><div class="name">Experiment type<xsl:if test="count($vExpTypeAndDesign) > 1">s</xsl:if></div></td>
                    <td class="value">
                        <div class="value">
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pText" select="string-join(experimenttype, ', ')"/>
                                <xsl:with-param name="pFieldName" select="'exptype'"/>
                            </xsl:call-template>
                            <xsl:if test="count(experimenttype) > 0 and count(experimentdesign) > 0">, </xsl:if>
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pText" select="string-join(experimentdesign, ', ')"/>
                                <xsl:with-param name="pFieldName" select="'expdesign'"/>
                            </xsl:call-template>
                        </div>
                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="experimentalfactor/name">
                <tr>
                    <td class="name"><div class="name">Experimental factors</div></td>
                    <td class="attrs"><div class="attrs">
                        <table cellpadding="0" cellspacing="0" border="0">
                            <thead>
                                <tr>
                                    <th class="attr_name">Factor name</th>
                                    <th class="attr_value">Factor values</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="experimentalfactor">
                                    <tr>
                                        <td class="attr_name">
                                            <xsl:call-template name="highlight">
                                                <xsl:with-param name="pText" select="name"/>
                                                <xsl:with-param name="pFieldName" select="'ef'"/>
                                            </xsl:call-template>
                                        </td>
                                        <td class="attr_value">
                                            <xsl:call-template name="highlight">
                                                <xsl:with-param name="pText" select="string-join(value, ', ')"/>
                                                <xsl:with-param name="pFieldName" select="'efv'"/>
                                            </xsl:call-template>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table></div>
                   </td>
                </tr>
            </xsl:if>

            <xsl:if test="sampleattribute/category">
                <tr>
                    <td class="name"><div class="name">Sample attributes</div></td>
                    <td class="attrs"><div class="attrs">
                        <table cellpadding="0" cellspacing="0" border="0">
                            <thead>
                                <tr>
                                    <th class="attr_name">Attribute name</th>
                                    <th class="attr_value">Attribute values</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="sampleattribute">
                                    <tr>
                                        <td class="attr_name">
                                            <xsl:call-template name="highlight">
                                                <xsl:with-param name="pText" select="category"/>
                                                <xsl:with-param name="pFieldName"/>
                                            </xsl:call-template>
                                        </td>
                                        <td class="attr_value">
                                            <xsl:call-template name="highlight">
                                                <xsl:with-param name="pText" select="string-join(value, ', ')"/>
                                                <xsl:with-param name="pFieldName" select="'sa'"/>
                                            </xsl:call-template>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table></div>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="submissiondate | lastupdatedate | releasedate">
                <tr>
                    <td class="name">
                        <div class="name">
                            <xsl:if test="submissiondate">
                                <div>Submitted on</div>
                            </xsl:if>
                            <xsl:if test="lastupdatedate">
                                <div>Last updated on</div>
                            </xsl:if>
                            <xsl:if test="releasedate">
                                <div>Released on</div>
                            </xsl:if>
                        </div>
                    </td>
                    <td class="value">
                        <div class="value">
                            <xsl:if test="submissiondate">
                                <div>
                                    <xsl:apply-templates select="submissiondate/text()" mode="highlight"/>
                                </div>
                            </xsl:if>
                            <xsl:if test="lastupdatedate">
                                <div>
                                    <xsl:apply-templates select="lastupdatedate/text()" mode="highlight"/>
                                </div>
                            </xsl:if>
                            <xsl:if test="releasedate">
                                <div>
                                    <xsl:apply-templates select="releasedate/text()" mode="highlight">
                                        <xsl:with-param name="pFieldName" select="'date'"/>
                                    </xsl:apply-templates>
                                </div>
                            </xsl:if>
                        </div>
                    </td>
                </tr>
            </xsl:if>
        </table>
    </xsl:template>

    <xsl:template name="secondaryaccession">
        <xsl:for-each select="secondaryaccession">
            <xsl:choose>
                <xsl:when test="string-length(.) = 0"/>
                <xsl:when test="substring(., 1, 3)='GSE' or substring(., 1, 3)='GDS'">
                    <a href="http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?acc={.}">
                        <xsl:text>GEO - </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="."/>
                            <xsl:with-param name="pFieldName" select="'accession'"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:when test="substring(., 1, 2)='E-' and substring(., 7, 1)='-'">
                    <a href="{$basepath}/experiments/{.}">
                        <xsl:text>ArrayExpress - </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="."/>
                            <xsl:with-param name="pFieldName" select="'accession'"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:when test="substring(., 1, 3)='SRP' or substring(., 1, 3)='ERP'">
                    <a href="http://www.ebi.ac.uk/ena/data/view/{.}">
                        <xsl:text>ENA - </xsl:text>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="."/>
                            <xsl:with-param name="pFieldName" select="'accession'"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="."/>
                        <xsl:with-param name="pFieldName" select="'accession'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() != last() and string-length(.) > 0">, </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="providers">
        <xsl:for-each select="provider[not(contact=following-sibling::provider/contact) and role!='data_coder']">
            <xsl:sort select="role='submitter'" order="descending"/>
            <xsl:sort select="lower-case(contact)"/>
            <xsl:choose>
                <xsl:when test="role='submitter' and string-length(email) > 0">
                    <a href="mailto:{email}">
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pText" select="concat(contact, ' &lt;', email, '&gt;')"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="highlight">
                        <xsl:with-param name="pText" select="contact"/>
                        <xsl:with-param name="pFieldName"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position()!=last()">, </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="min-score">
        <xsl:param name="pScores"/>
        <xsl:param name="pKind"/>
        
        <table class="min-score-tbl" border="0" cellpadding="0" cellspacing="0">
            <thead>
                <tr>
                    <xsl:if test="$pKind = 'miame'">
                        <th>Array designs</th>
                    </xsl:if>
                    <xsl:if test="$pKind = 'minseqe'">
                        <th>Expt. design</th>
                    </xsl:if>
                    <th>Protocols</th>
                    <th>Factors</th>
                    <th>Processed data</th>
                    <xsl:if test="$pKind = 'miame'">
                        <th>Raw data</th>
                    </xsl:if>
                    <xsl:if test="$pKind = 'minseqe'">
                        <th>Sequence Reads</th>
                    </xsl:if>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        <xsl:if test="$pKind = 'miame'">
                            <xsl:call-template name="min-score-tick">
                                <xsl:with-param name="pValue" select="$pScores/reportersequencescore"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$pKind = 'minseqe'">
                            <xsl:call-template name="min-score-tick">
                                <xsl:with-param name="pValue" select="$pScores/experimentdesignscore"/>
                            </xsl:call-template>
                        </xsl:if>
                    </td>
                    <td>
                        <xsl:call-template name="min-score-tick">
                            <xsl:with-param name="pValue" select="$pScores/protocolscore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="min-score-tick">
                            <xsl:with-param name="pValue" select="$pScores/factorvaluescore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="min-score-tick">
                            <xsl:with-param name="pValue" select="$pScores/derivedbioassaydatascore"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="min-score-tick">
                            <xsl:with-param name="pValue" select="$pScores/measuredbioassaydatascore"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:template>
    
    <xsl:template name="min-score-tick">
        <xsl:param name="pValue"/>
        
        <xsl:choose>
            <xsl:when test="$pValue='1'">
                <img src="{$basepath}/assets/images/basic_tick.gif" width="16" height="16" alt="*"/>
            </xsl:when>
            <xsl:otherwise>
                <img src="{$basepath}/assets/images/silk_data_unavail.gif" width="16" height="16" alt="-"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>