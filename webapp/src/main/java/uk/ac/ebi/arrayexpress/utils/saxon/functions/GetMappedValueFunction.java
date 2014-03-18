package uk.ac.ebi.arrayexpress.utils.saxon.functions;

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

import net.sf.saxon.expr.JPConverter;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.SequenceTool;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.EmptySequence;
import net.sf.saxon.value.SequenceType;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.MapEngine;

public class GetMappedValueFunction extends ExtensionFunctionDefinition
{
    private static final long serialVersionUID = 4695269638102509735L;

    private static final StructuredQName qName =
            new StructuredQName("", NamespaceConstant.AE_EXT, "getMappedValue");

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
        return new GetMappedValueCall();
    }

    private static class GetMappedValueCall extends ExtensionFunctionCall
    {
        private static final long serialVersionUID = -1342342397189997194L;

        private MapEngine mapEngine = (MapEngine) Application.getAppComponent("MapEngine");

        public Sequence call( XPathContext context, Sequence[] arguments ) throws XPathException
        {
            if (null == mapEngine) {
                return EmptySequence.getInstance();
            }

            String mapName = SequenceTool.getStringValue(arguments[0]);
            String mapKey = SequenceTool.getStringValue(arguments[1]);
            Object value = mapEngine.getMappedValue(mapName, mapKey);

            if (null == value) {
                return EmptySequence.getInstance();
            } else {
                JPConverter converter = JPConverter.allocate(value.getClass(), context.getConfiguration());
                return converter.convert(value, context);
            }
        }
    }
}
