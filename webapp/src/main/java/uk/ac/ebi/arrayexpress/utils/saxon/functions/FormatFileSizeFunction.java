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
import net.sf.saxon.om.Item;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.*;

public class FormatFileSizeFunction extends ExtensionFunctionDefinition
{
    private static final long serialVersionUID = 7995886291705633633L;

    private static final StructuredQName qName =
            new StructuredQName("", NamespaceConstant.AE_EXT, "formatFileSize");

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
        return new SequenceType[]{ SequenceType.SINGLE_INTEGER };
    }

    public SequenceType getResultType( SequenceType[] suppliedArgumentTypes )
    {
        return SequenceType.SINGLE_STRING;
    }

    public ExtensionFunctionCall makeCallExpression()
    {
        return new FormatFileSizeCall();
    }

    private static class FormatFileSizeCall extends ExtensionFunctionCall
    {
        private static final long serialVersionUID = -8209172163832123502L;

        @SuppressWarnings("unchecked")
        public SequenceIterator<? extends Item> call( SequenceIterator[] arguments, XPathContext context ) throws XPathException
        {
            NumericValue sizeValue = (NumericValue) arguments[0].next();
            Long size = (sizeValue instanceof Int64Value) ? ((Int64Value)sizeValue).asBigInteger().longValue() : sizeValue.longValue();

            StringBuilder str = new StringBuilder();
            if (922L > size) {
                str.append(size).append(" B");
            } else if (944128L > size) {
                str.append(String.format("%.0f KB", (size / 1024.0)));
            } else if (1073741824L > size) {
                str.append(String.format("%.1f MB", (size / 1048576.0)));
            } else if (1099511627776L > size) {
                str.append(String.format("%.2f GB", (size / 1073741824.0)));
            } else if (1125899906842624L > size) {
                str.append(String.format("%.2f TB", (size / 1099511627776.0)));
            }
            return Value.asIterator(StringValue.makeStringValue(str.toString()));
        }
    }
}
