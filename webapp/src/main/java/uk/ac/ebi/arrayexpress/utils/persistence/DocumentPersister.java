package uk.ac.ebi.arrayexpress.utils.persistence;

import net.sf.saxon.om.DocumentInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;

import java.io.File;

/**
 * Created by IntelliJ IDEA.
 * User: nataliyasklyar
 * Date: Jun 17, 2010
 * Time: 10:33:21 AM
 * To change this template use File | Settings | File Templates.
 */
public class DocumentPersister {

    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    //ToDo: it's better to inject this object
    private StringReaderWriter stringReaderWriter = new StringReaderWriter();

    public DocumentInfo loadObject(String fileLocation) {
        DocumentInfo document = null;

        try {
            String strDocument = stringReaderWriter.load(new File(fileLocation));
            document = ((SaxonEngine) Application.getAppComponent("SaxonEngine")).buildDocument(strDocument);

        } catch (Exception e) {
            throw new PersistenceException("Problem with loading ", e);
        }

        if (null == document) {
            createDocument();
        }

        return document;
    }

    public void saveObject(DocumentInfo document, String fileLocation) {

        try {
            String strDocument = ((SaxonEngine) Application.getAppComponent("SaxonEngine")).serializeDocument(document);
            stringReaderWriter.save(strDocument, new File(fileLocation));
        } catch (Exception e) {
            throw new PersistenceException("Problem with persisting document ", e);
        }
    }

    public boolean isEmpty(DocumentInfo document) throws Exception {
        if (null == document)
            return true;

        String total = ((SaxonEngine) Application.getAppComponent("SaxonEngine")).evaluateXPathSingle(document, "/experiments/@total");

        return (null == total || total.equals("0"));
    }

    private DocumentInfo createDocument() {
        DocumentInfo document = null;
        try {
            document = ((SaxonEngine) Application.getAppComponent("SaxonEngine")).buildDocument("<?xml version=\"1.0\"?><experiments total=\"0\"></experiments>");
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }

        if (null == document) {
            logger.error("The document WAS NOT created, expect problems down the road");
        }

        return document;
    }


}
