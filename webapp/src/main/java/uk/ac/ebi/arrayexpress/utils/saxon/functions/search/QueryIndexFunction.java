package uk.ac.ebi.arrayexpress.utils.saxon.functions.search;

/*
 * Copyright 2009-2013 European Molecular Biology Laboratory
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

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.EmptyIterator;
import net.sf.saxon.tree.iter.ListIterator;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import org.apache.lucene.queryParser.ParseException;
import uk.ac.ebi.arrayexpress.utils.saxon.search.Controller;

import java.io.IOException;
import java.util.List;

public class QueryIndexFunction extends ExtensionFunctionDefinition
{
    private static final long serialVersionUID = -498498336861433019L;

    private static final StructuredQName qName =
            new StructuredQName("", NamespaceConstant.AE_SEARCH_EXT, "queryIndex");

    private Controller searchController;

    public QueryIndexFunction( Controller controller )
    {
        this.searchController = controller;
    }

    public StructuredQName getFunctionQName()
    {
        return qName;
    }

    public int getMinimumNumberOfArguments()
    {
        return 1;
    }

    public int getMaximumNumberOfArguments()
    {
        return 2;
    }

    public SequenceType[] getArgumentTypes()
    {
        return new SequenceType[]{ SequenceType.SINGLE_STRING, SequenceType.SINGLE_STRING };
    }

    public SequenceType getResultType( SequenceType[] suppliedArgumentTypes )
    {
        return SequenceType.NODE_SEQUENCE;
    }

    public ExtensionFunctionCall makeCallExpression()
    {
        return new QueryIndexCall(searchController);
    }

    private static class QueryIndexCall extends ExtensionFunctionCall
    {
        private static final long serialVersionUID = -6204480413095253157L;

        private Controller searchController;

        public QueryIndexCall( Controller searchController )
        {
            this.searchController = searchController;
        }

        public SequenceIterator<? extends Item> call( SequenceIterator[] arguments, XPathContext context ) throws XPathException
        {
            StringValue first = (StringValue) arguments[0].next();
            StringValue second = (arguments.length > 1 && null != arguments[1])
                    ? (StringValue) arguments[1].next()
                    : null;

            List<NodeInfo> nodes;
            try {
                if (null == second) {
                    String queryId = first.getStringValue();
                    Integer intQueryId;
                    try {
                        intQueryId = Integer.decode(queryId);
                    } catch (NumberFormatException x) {
                        throw new XPathException("queryId [" + String.valueOf(queryId) + "] must be integer");
                    }

                    nodes = searchController.queryIndex(intQueryId);
                } else {
                    String indexId = first.getStringValue();
                    String queryString = second.getStringValue();

                    nodes = searchController.queryIndex(indexId, queryString);
                }
            } catch (IOException x) {
                throw new XPathException("Caught IOException while querying index", x);
            } catch (ParseException x) {
                throw new XPathException("Caught ParseException while querying index", x);

            }
            if (null != nodes) {
                return new ListIterator<>(nodes);
            } else {
                return EmptyIterator.emptyIterator();
            }
        }
    }
}
