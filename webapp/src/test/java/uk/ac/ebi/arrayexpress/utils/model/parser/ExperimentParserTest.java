package uk.ac.ebi.arrayexpress.utils.model.parser;

import org.junit.Before;
import org.junit.Test;

public class ExperimentParserTest
{
    private final String SINGLE_EXPERIMENT_TEST_XML = "<?xml version=\"1.0\"?>" +
        "<experiment id=\"1711258082\" accession=\"E-GEOD-9914\" name=\"Transcription profiling of mouse knock in mutant uk.ac.ebi.arrayexpress.utils.model for spinocerebellar ataxia type 1 and type 7 - symptomatic Sca1154Q/2Q and Sca7266Q/5Q cerebellum\" releasedate=\"2009-01-08\">" +
        "<user>1</user>" +
        "<secondaryaccession>GDS3202</secondaryaccession>" +
        "<secondaryaccession>GSE9914</secondaryaccession>" +
        "<sampleattribute category=\"Age\" value=\"12 weeks\"/>" +
        "<sampleattribute category=\"Age\" value=\"4 weeks\"/>" +
        "<sampleattribute category=\"Age\" value=\"5 weeks\"/>" +
        "<sampleattribute category=\"DiseaseState\" value=\"reference\"/>" +
        "<sampleattribute category=\"DiseaseState\" value=\"spinocerebellar ataxia type 7\"/>" +
        "<sampleattribute category=\"Genotype\" value=\"SCA1 wild type\"/>" +
        "<sampleattribute category=\"Genotype\" value=\"SCA7 wild-type\"/>" +
        "<sampleattribute category=\"OrganismPart\" value=\"cerebellum\"/>" +
        "<sampleattribute category=\"StrainOrLine\" value=\"C57BL/6J\"/>" +
        "<sampleattribute category=\"Sex\" value=\"female\"/>" +
        "<sampleattribute category=\"Organism\" value=\"Mus musculus\"/>" +
        "<sampleattribute category=\"Genotype\" value=\"SCA7 knock-in\"/>" +
        "<sampleattribute category=\"Genotype\" value=\"SCA1 knock-in\"/>" +
        "<sampleattribute category=\"DiseaseState\" value=\"spinocerebellar ataxia type 1\"/>" +
        "<sampleattribute category=\"Age\" value=\"9 weeks\"/>" +
        "<experimentalfactor name=\"AGE\" value=\"12\"/>" +
        "<experimentalfactor name=\"AGE\" value=\"4\"/>" +
        "<experimentalfactor name=\"AGE\" value=\"5\"/>" +
        "<experimentalfactor name=\"Genotype\" value=\"SCA1 knock-in\"/>" +
        "<experimentalfactor name=\"Genotype\" value=\"SCA7 knock-in\"/>" +
        "<experimentalfactor name=\"Genotype\" value=\"SCA7 wild-type\"/>" +
        "<experimentalfactor name=\"Genotype\" value=\"SCA1 wild type\"/>" +
        "<experimentalfactor name=\"AGE\" value=\"9\"/>" +
        "<miamescore name=\"ReporterSequenceScore\" value=\"1\"/>" +
        "<miamescore name=\"FactorValueScore\" value=\"1\"/>" +
        "<miamescore name=\"MeasuredBioAssayDataScore\" value=\"1\"/>" +
        "<miamescore name=\"ProtocolScore\" value=\"1\"/>" +
        "<miamescore name=\"DerivedBioAssayDataScore\" value=\"1\"/>" +
        "<arraydesign id=\"447429329\" accession=\"A-AFFY-36\" name=\"Affymetrix GeneChip&#xAE; Mouse Genome 430A 2.0 [Mouse430A_2]\" count=\"22\"/>" +
        "<bioassaydatagroup id=\"1711258109\" name=\"Affymetrix:FeatureDimension:MOE430A\" bioassaydatacubes=\"12\" arraydesignprovider=\"AFFY\" dataformat=\"CELv4\" bioassays=\"12\" isderived=\"0\"/>" +
        "<bioassaydatagroup id=\"1711258110\" name=\"Affymetrix:FeatureDimension:Mouse430_2\" bioassaydatacubes=\"10\" arraydesignprovider=\"AFFY\" dataformat=\"CELv4\" bioassays=\"10\" isderived=\"0\"/>" +
        "<bioassaydatagroup id=\"1711258111\" name=\"ebi.ac.uk:MAGETabulator:E-GEOD-9914.Mouse430A_2.1.CompositeSequenceDimension\" bioassaydatacubes=\"22\" arraydesignprovider=\"AFFY\" dataformat=\"tab delimited\" bioassays=\"22\" isderived=\"1\"/>" +
        "<bibliography accession=\"18216249\" authors=\"Jennifer R Gatchel, Kei Watase, Christina Thaller, James P Carson, Paymaan Jafar-Nejad, Chad Shaw, Tao Zu, Harry T Orr, Huda Y Zoghbi\" title=\"The insulin-like growth factor pathway is altered in spinocerebellar ataxia type 1 and type 7.\"/>" +
        "<provider contact=\"Chad Shaw\" role=\"submitter\"/>" +
        "<experimentdesign>individual genetic characteristics unknown type</experimentdesign>" +
        "<experimenttype>transcription profiling</experimenttype>" +
        "<description id=\"1711258120\">(Generated description) Experiment with 22 hybridizations, using 22 samples of species [Mus musculus], using 22 arrays of array design [Affymetrix GeneChip&#xAE; Mouse Genome 430A 2.0 [Mouse430A_2]], producing 22 raw data files and 22 transformed and/or normalized data files.</description>" +
        "<description id=\"1711258089\">Comparative analysis of cerebellar gene expression changes occurring in Sca1154Q/2Q and Sca7266Q/5Q knock-in mice; Polyglutamine diseases are inherited neurodegenerative disorders caused by expansion of CAG repeats encoding a glutamine tract in the disease-causing proteins.  There are nine disorders each having distinct features but also clinical and pathological similarities.  In particular, spinocerebellar ataxia type 1 and type 7 (SCA1 and SCA7) patients manifest cerebellar ataxia with degeneration of Purkinje cells.  To determine whether the disorders share molecular pathogenic events, we studied two mouse models of SCA1 and SCA7 that express the glutamine-expanded protein from the respective endogenous loci.  We found common transcriptional changes, with down-regulation of Insulin-like growth factor binding protein 5 (Igfbp5) representing one of the most robust changes.  Igfbp5 down-regulation occurred in granule neurons through a non-cell autonomous mechanism and was concomitant with activation of of the Insulin-like growth factor (IGF) pathway and the type I IGF receptor on Purkinje cells.  These data define one common pathogenic response in SCA1 and SCA7 and reveal the importance of intercellular mechanisms in their pathogenesis.  Given that SCA1 and SCA7 share a cerebellar degenerative phenotype, we proposed that some shared molecular changes might occur in both diseases, and that common molecular alterations could pinpoint pathways that could be targeted to modulate or monitor the pathogenesis of more than one disease.  We focused on transcriptional changes because both ATXN1 and ATXN7 play roles in transcriptional regulation and transcriptional defects can be detected in early-symptomatic stages of both SCA1 and SCA7 mouse models. To test our hypothesis, we examined cerebellar gene expression patterns in SCA1 and SCA7 knock-in (KI) models--Sca1154Q/2Q and Sca7266Q/5Q mice. Experiment Overall Design: Total cerebellar RNA samples were collected from Sca1154Q/2Q knock-in and wild type mice at the early symptomatic disease stage (4 weeks, n=3 knock-in and 3 wild type; 9-12 weeks, n=3 knock-in and 3 wild type).  In parallel experiments, total cerebellar RNA samples were collected from Sca7266Q/5Q knock-in and wild type mice also at the early symptomatic disease stage (5 weeks, n=5 knock-in and 5 wild type).</description>" +
        "</experiment>";

    private final String MULTIPLE_EXPERIMENTS_TEST_XML = "<?xml version=\"1.0\"?><experiments>" +
        "<experiment id=\"1711258082\" accession=\"E-GEOD-9914\" name=\"Transcription profiling of mouse knock in mutant uk.ac.ebi.arrayexpress.utils.model for spinocerebellar ataxia type 1 and type 7 - symptomatic Sca1154Q/2Q and Sca7266Q/5Q cerebellum\" releasedate=\"2009-01-08\">" +
        "<user>1</user>" +
        "<secondaryaccession>GSE9914</secondaryaccession>" +
        "<sampleattribute category=\"Age\" value=\"12 weeks\"/>" +
        "<experimentalfactor name=\"AGE\" value=\"12\"/>" +
        "<miamescore name=\"ReporterSequenceScore\" value=\"1\"/>" +
        "<miamescore name=\"FactorValueScore\" value=\"1\"/>" +
        "<miamescore name=\"MeasuredBioAssayDataScore\" value=\"1\"/>" +
        "<miamescore name=\"ProtocolScore\" value=\"1\"/>" +
        "<miamescore name=\"DerivedBioAssayDataScore\" value=\"1\"/>" +
        "<arraydesign id=\"447429329\" accession=\"A-AFFY-36\" name=\"Affymetrix GeneChip&#xAE; Mouse Genome 430A 2.0 [Mouse430A_2]\" count=\"22\"/>" +
        "<bioassaydatagroup id=\"1711258109\" name=\"Affymetrix:FeatureDimension:MOE430A\" bioassaydatacubes=\"12\" arraydesignprovider=\"AFFY\" dataformat=\"CELv4\" bioassays=\"12\" isderived=\"0\"/>" +
        "<bibliography accession=\"18216249\" authors=\"Jennifer R Gatchel, Kei Watase, Christina Thaller, James P Carson, Paymaan Jafar-Nejad, Chad Shaw, Tao Zu, Harry T Orr, Huda Y Zoghbi\" title=\"The insulin-like growth factor pathway is altered in spinocerebellar ataxia type 1 and type 7.\"/>" +
        "<provider contact=\"Chad Shaw\" role=\"submitter\"/>" +
        "<experimentdesign>individual genetic characteristics unknown type</experimentdesign>" +
        "<experimenttype>transcription profiling</experimenttype>" +
        "<description id=\"1711258120\">(Generated description) Experiment with 22 hybridizations, using 22 samples of species [Mus musculus], using 22 arrays of array design [Affymetrix GeneChip&#xAE; Mouse Genome 430A 2.0 [Mouse430A_2]], producing 22 raw data files and 22 transformed and/or normalized data files.</description>" +
        "</experiment>" +
        "<experiment id=\"2\" accession=\"E-TEST-1\" name=\"My miracle experiment\"/>" +
        "</experiments>";

    @Before
    public void intializeApplication()
    {
    //  new AEInterfaceTestApplication();
    }

    @Test
    public void testParseSingle()
    {
//        ExperimentParser parser = new ExperimentParser(ExperimentParserMode.SINGLE_EXPERIMENT);
//        ExperimentBean experiment = parser.parseSingle(SINGLE_EXPERIMENT_TEST_XML);
//        assertTrue("Experiment instance was null", null != experiment);
//        assertEquals("1711258082", experiment.getId());
//        assertEquals("E-GEOD-9914", experiment.getAccession());
//        assertEquals("Transcription profiling of mouse knock in mutant uk.ac.ebi.arrayexpress.utils.model for spinocerebellar ataxia type 1 and type 7 - symptomatic Sca1154Q/2Q and Sca7266Q/5Q cerebellum", experiment.getName());
//        assertEquals("2009-01-08", experiment.getReleaseDate());
//        assertEquals(null, experiment.getMiameGold());
//
//        assertEquals(1, experiment.getUser().size());
//        assertEquals("1", experiment.getUser().get(0));
//
//        assertEquals(2, experiment.getSecondaryAccession().size());
//        assertEquals("GDS3202", experiment.getSecondaryAccession().get(0));
//
//        assertEquals(7, experiment.getSampleAttribute().size());
    }

    @Test
    public void testParseMultiple()
    {
//        ExperimentParser parser = new ExperimentParser(ExperimentParserMode.MULTIPLE_EXPERIMENTS);
//        ExperimentList experiments = parser.parseMultiple(MULTIPLE_EXPERIMENTS_TEST_XML);
//        assertTrue("Experiments instance was null", null != experiments);
    }
}
