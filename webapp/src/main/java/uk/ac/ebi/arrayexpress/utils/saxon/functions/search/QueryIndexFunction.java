package uk.ac.ebi.arrayexpress.utils.saxon.functions.search;

/*
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
 */

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.SequenceTool;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.ListIterator;
import net.sf.saxon.value.EmptySequence;
import net.sf.saxon.value.SequenceType;
import org.apache.lucene.queryparser.classic.ParseException;
import uk.ac.ebi.arrayexpress.utils.saxon.search.Controller;

import java.io.IOException;
import java.util.List;

public class QueryIndexFunction extends ExtensionFunctionDefinition
{
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
        private Controller searchController;

        public QueryIndexCall( Controller searchController )
        {
            this.searchController = searchController;
        }

        public Sequence call( XPathContext context, Sequence[] arguments ) throws XPathException
        {
            String first = SequenceTool.getStringValue(arguments[0]);
            String second = arguments.length > 1 ? SequenceTool.getStringValue(arguments[1]) : null;

            List<NodeInfo> nodes;
            try {
                if (null == second) {
                    Integer intQueryId;
                    try {
                        intQueryId = Integer.decode(first);
                    } catch (NumberFormatException x) {
                        throw new XPathException("queryId [" + first + "] must be integer");
                    }

                    nodes = searchController.queryIndex(intQueryId);
                } else {
                    nodes = searchController.queryIndex(first, second);
                }
            } catch (IOException x) {
                throw new XPathException("Caught IOException while querying index", x);
            } catch (ParseException x) {
                throw new XPathException("Caught ParseException while querying index", x);

            }
            return null != nodes
                    ? SequenceTool.toLazySequence(new ListIterator(nodes))
                    : EmptySequence.getInstance();
        }
    }
}

