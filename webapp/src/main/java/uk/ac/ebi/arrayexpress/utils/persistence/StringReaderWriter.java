package uk.ac.ebi.arrayexpress.utils.persistence;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;

/**
 * Created by IntelliJ IDEA.
 * User: nataliyasklyar
 * Date: Jun 17, 2010
 * Time: 10:36:08 AM
 * To change this template use File | Settings | File Templates.
 */
public class StringReaderWriter {

    public final static String EOL = System.getProperty("line.separator");

    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public String load(File persistenceFile) throws Exception
    {
        logger.debug("Retrieving persistable object [{}] from [{}]", persistenceFile.getName());

        StringBuilder result = new StringBuilder();
        if (persistenceFile.exists()) {
            BufferedReader r = new BufferedReader(new InputStreamReader(new FileInputStream(persistenceFile)));
            while ( r.ready() ) {
                String str = r.readLine();
                // null means stream has reached the end
                if (null != str) {
                    result.append(str).append(EOL);
                } else {
                    break;
                }
            }
            logger.debug("Object successfully retrieved");
        } else {
            logger.warn("Persistence file [{}] not found", persistenceFile.getAbsolutePath());
            return null;
        }

        return result.toString();
    }

    public void save( String objectString, File persistenceFile ) throws Exception
    {
        logger.debug("Saving persistable object [{}] to [{}]",  persistenceFile.getName());
        BufferedWriter w = new BufferedWriter(new FileWriter(persistenceFile));
        w.write(objectString);
        w.close();
        logger.debug("Object successfully saved");
    }
}
