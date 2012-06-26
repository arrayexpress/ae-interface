package uk.ac.ebi.arrayexpress.utils.saxon.functions;

/*
 * Copyright 2009-2012 European Molecular Biology Laboratory
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

import net.sf.saxon.expr.JPConverter;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.om.ValueRepresentation;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.EmptyIterator;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.Value;

public class GetAcceleratorValueFunction extends ExtensionFunctionDefinition
{
    private static final long serialVersionUID = 5507446309416498174L;

    private static final StructuredQName qName =
            new StructuredQName("", NamespaceConstant.AE_EXT, "getAcceleratorValue");

    public StructuredQName getFunctionQName()
    {
        return qName;
    }

    public int getMinimumNumberOfArguments()
    {
        return 2;
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
        return SequenceType.ANY_SEQUENCE;
    }

    public ExtensionFunctionCall makeCallExpression()
    {
        return new GetAcceleratorValueCall();
    }

    private static class GetAcceleratorValueCall extends ExtensionFunctionCall
    {
        private static final long serialVersionUID = -4826080754394968349L;

        public SequenceIterator<? extends Item> call( SequenceIterator[] arguments, XPathContext context ) throws XPathException
        {
            // to do: redevelop accelerators as a part of search engine;
            // or make them a separate component with configuration
            String acceleratorName = arguments[0].next().getStringValue();
            String key = arguments[1].next().getStringValue();
            Object value = ExtFunctions.getAcceleratorValue(acceleratorName, key);
            if (null == value) {
                return EmptyIterator.emptyIterator();
            } else {
                JPConverter converter = JPConverter.allocate(value.getClass(), context.getConfiguration());
                return Value.asIterator((ValueRepresentation<? extends Item>)converter.convert(value, context));
            }
        }
    }
}
