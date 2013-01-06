package uk.ac.ebi.arrayexpress.utils.saxon.functions;

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

import net.sf.saxon.event.PipelineConfiguration;
import net.sf.saxon.event.Receiver;
import net.sf.saxon.event.SequenceReceiver;
import net.sf.saxon.expr.Expression;
import net.sf.saxon.expr.StaticContext;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.lib.SerializerFactory;
import net.sf.saxon.lib.Validation;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import net.sf.saxon.value.Value;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.stream.StreamResult;
import java.io.StringWriter;
import java.util.Properties;

public class SerializeXMLFunction extends ExtensionFunctionDefinition
{
    private static final long serialVersionUID = 2833370612309346918L;

    private static final StructuredQName qName =
            new StructuredQName("", NamespaceConstant.AE_EXT, "serializeXml");

    @Override
    public StructuredQName getFunctionQName()
    {
        return qName;
    }

    @Override
    public int getMinimumNumberOfArguments()
    {
        return 2;
    }

    @Override
    public int getMaximumNumberOfArguments()
    {
        return 2;
    }

    @Override
    public SequenceType[] getArgumentTypes()
    {
        return new SequenceType[]{SequenceType.OPTIONAL_NODE, SequenceType.SINGLE_STRING};
    }

    @Override
    public SequenceType getResultType(SequenceType[] suppliedArgumentTypes)
    {
        return SequenceType.SINGLE_STRING;
    }

    @Override
    public ExtensionFunctionCall makeCallExpression()
    {
        return new SerializeXMLCall();
    }

    private static class SerializeXMLCall extends ExtensionFunctionCall
    {
        private static final long serialVersionUID = 4046135620725571811L;

        private int locationId;

        @Override
        public void  supplyStaticContext(StaticContext context, int locationId, Expression[] arguments) throws XPathException
        {
            this.locationId = locationId;
        }

        @Override
        public SequenceIterator<? extends Item> call(SequenceIterator[] arguments, XPathContext context) throws XPathException
        {
            NodeInfo node = (NodeInfo)arguments[0].next();
            if (null == node) {
                return Value.asIterator(StringValue.EMPTY_STRING);
            }

            StringValue encodingValue = (arguments.length > 1 && null != arguments[1])
                    ? (StringValue) arguments[1].next()
                    : null;

            Properties props = new Properties();
            props.put(OutputKeys.METHOD, "xml");
            props.put(OutputKeys.OMIT_XML_DECLARATION, "yes");
            props.put(OutputKeys.INDENT, "no");
            if (null != encodingValue) {
                props.put(OutputKeys.ENCODING, encodingValue.getStringValue());
            }

            try {
                StringWriter result = new StringWriter();
                XPathContext c2 = context.newMinorContext();

                SerializerFactory serializerFactory = context.getConfiguration().getSerializerFactory();
                Receiver r = serializerFactory.getReceiver(
                        new StreamResult(result)
                        , new PipelineConfiguration(context.getConfiguration())
                        , props
                );

                c2.changeOutputDestination(
                        r
                        , Validation.PRESERVE
                        , null);

                SequenceReceiver out = c2.getReceiver();
                out.open();
                node.copy(out, NodeInfo.ALL_NAMESPACES, locationId);
                out.close();
                return Value.asIterator(new StringValue(result.toString()));
            } catch (XPathException err) {
                throw new XPathException(err);
            }
        }
    }}
