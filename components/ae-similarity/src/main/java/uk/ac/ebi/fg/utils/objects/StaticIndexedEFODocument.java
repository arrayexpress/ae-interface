package uk.ac.ebi.fg.utils.objects;

import uk.ac.ebi.fg.utils.lucene.IndexedDocumentController;

/**
 * Provides access to static lucene indexed EFO object
 */
public class StaticIndexedEFODocument
{
    private static IndexedDocumentController indexedEFO;

    public StaticIndexedEFODocument()
    {}

    public static void setDoc( IndexedDocumentController doc )
    {
        indexedEFO = doc;
    }

    public static IndexedDocumentController getDoc()
    {
        return indexedEFO;
    }
}
