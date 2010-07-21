package uk.ac.ebi.arrayexpress.components;

import net.sf.saxon.om.DocumentInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.DocumentTypes;

/**
 * Created by IntelliJ IDEA.
 * User: nataliyasklyar
 * Date: Jul 19, 2010
 * Time: 10:29:49 AM
 * To change this template use File | Settings | File Templates.
 */
public abstract class XMLDocumentComponent extends ApplicationComponent {

    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    protected SaxonEngine saxon;
    protected DocumentContainer documentContainer;
    

    public XMLDocumentComponent(String name) {
        super(name);
    }

    @Override
    public void initialize() throws Exception {
        saxon = (SaxonEngine) getComponent("SaxonEngine");
        documentContainer = (DocumentContainer) getComponent("DocumentContainer");
    }

    public void terminate() throws Exception
     {
          saxon = null;
     }

    public abstract void reload(String xmlString) throws Exception;

    protected synchronized DocumentInfo loadXMLString(DocumentTypes type, String xmlString) throws Exception {
        DocumentInfo documentInfo = saxon.transform(xmlString, type.getXslName(), null);
        if (documentInfo != null) {
            documentContainer.putDocument(type, documentInfo);
        } else {
            this.logger.error(type.getTextName() + " NOT updated, NULL document passed");
        }
        return documentInfo;
    }
}
