package uk.ac.ebi.fg.utils;

import net.sf.saxon.om.DocumentInfo;

public interface ISimilarityComponent
{
    void setDocument( DocumentInfo doc ) throws Exception;
    void sendExceptionReport( String message, Throwable x );
}
