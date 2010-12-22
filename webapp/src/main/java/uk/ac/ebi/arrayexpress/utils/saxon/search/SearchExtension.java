package uk.ac.ebi.arrayexpress.utils.saxon.search;

/*
 * Copyright 2009-2010 European Molecular Biology Laboratory
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
 */

import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.NodeListIterator;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.trans.XPathException;
import org.apache.lucene.queryParser.ParseException;

import java.io.IOException;
import java.util.List;

public final class SearchExtension
{
    // logging machinery
    //private static final Logger logger = LoggerFactory.getLogger(SearchExtension.class);

    private static Controller controller;

    public static SequenceIterator queryIndex( String queryId ) throws IOException, XPathException
    {
        Integer intQueryId;
        try {
            intQueryId = Integer.decode(queryId);
        } catch (NumberFormatException x) {
            throw new XPathException("queryId [" + String.valueOf(queryId) + "] must be integer");
        }
        List<NodeInfo> nodes = getController().queryIndex(intQueryId);
        if (null != nodes) {
            return new NodeListIterator(nodes);
        }

        return null;
    }

    public static SequenceIterator queryIndex( String indexId, String queryString ) throws IOException, ParseException
    {
        List<NodeInfo> nodes = getController().queryIndex(indexId, queryString);
        if (null != nodes) {
            return new NodeListIterator(nodes);
        }

        return null;
    }

    public static String highlightQuery( String queryId, String fieldName, String text )
    {
        return getController().highlightQuery(Integer.decode(queryId), fieldName, text);
    }

    public static String getQueryString( String queryId )
    {
        return getController().getQueryString(Integer.decode(queryId));
    }

    // get/set
    public static void setController( Controller ctrl )
    {
        controller = ctrl;
    }

    public static Controller getController()
    {
        return controller;
    }
}
