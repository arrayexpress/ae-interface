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

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.SequenceTool;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import uk.ac.ebi.arrayexpress.utils.StringTools;

public class TrimTrailingDotFunction extends ExtensionFunctionDefinition
{
    private static final StructuredQName qName =
            new StructuredQName("", NamespaceConstant.AE_EXT, "trimTrailingDot");

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
        return 1;
    }

    public SequenceType[] getArgumentTypes()
    {
        return new SequenceType[]{ SequenceType.OPTIONAL_STRING };
    }

    public SequenceType getResultType( SequenceType[] suppliedArgumentTypes )
    {
        return SequenceType.OPTIONAL_STRING;
    }

    public ExtensionFunctionCall makeCallExpression()
    {
        return new TrimTrailingDotCall();
    }

    private static class TrimTrailingDotCall extends ExtensionFunctionCall
    {
        public Sequence call( XPathContext context, Sequence[] arguments ) throws XPathException
        {
            String str = SequenceTool.getStringValue(arguments[0]).trim();

            if (str.endsWith(".")) {
                str = StringTools.unescapeHTMLEntities(str.substring(0, str.length() - 1));
            }

            return new StringValue(str);
        }
    }
}
