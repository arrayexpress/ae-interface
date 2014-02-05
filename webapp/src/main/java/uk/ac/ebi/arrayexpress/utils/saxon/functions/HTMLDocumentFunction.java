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

import net.sf.saxon.Controller;
import net.sf.saxon.event.Builder;
import net.sf.saxon.event.Receiver;
import net.sf.saxon.event.Sender;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.AugmentedSource;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.EmptyIterator;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import net.sf.saxon.value.Whitespace;
import nu.validator.htmlparser.sax.HtmlParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.InputSource;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamSource;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;

public class HTMLDocumentFunction extends ExtensionFunctionDefinition
{

    private static final StructuredQName qName =
            new StructuredQName("", NamespaceConstant.AE_EXT, "htmlDocument");

    private static final long serialVersionUID = 2900492427992842625L;

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
        return new SequenceType[]{ SequenceType.SINGLE_STRING, SequenceType.OPTIONAL_STRING };
    }

    public SequenceType getResultType( SequenceType[] suppliedArgumentTypes )
    {
        return SequenceType.OPTIONAL_NODE;
    }

    public ExtensionFunctionCall makeCallExpression()
    {
        return new HTMLDocumentCall();
    }

    private static class HTMLDocumentCall extends ExtensionFunctionCall
    {
        // logging machinery
        private transient final Logger logger = LoggerFactory.getLogger(getClass());

        private static final long serialVersionUID = -3423794707455948444L;

        private transient HtmlParser parser;


        @SuppressWarnings("unchecked")
        public SequenceIterator<? extends Item> call( SequenceIterator[] arguments, XPathContext context ) throws XPathException
        {
            try {
                Controller controller = context.getController();
                String baseURI = ((NodeInfo)context.getContextItem()).getBaseURI();

                StringValue locationValue = (StringValue) arguments[0].next();

                if (null != locationValue) {
                    StreamSource ss = null;
                    try {
                        ss = (StreamSource)controller.getURIResolver().resolve(locationValue.getStringValue(), "");
                    } catch (TransformerException x ) {
                        logger.error("Unable to open document [{}]", locationValue.getStringValue());
                    }

                    if (null != ss) {
                        try (InputStream is = ss.getInputStream()) {

                            Reader isr = new InputStreamReader(is);

                            InputSource isc = new InputSource();
                            isc.setCharacterStream(isr);
                            isc.setSystemId(baseURI);

                            Source source = new SAXSource(getParser(), isc);
                            source.setSystemId(baseURI);

                            Builder b = controller.makeBuilder();
                            Receiver s = b;

                            source = AugmentedSource.makeAugmentedSource(source);
                            ((AugmentedSource) source).setStripSpace(Whitespace.XSLT);

                            if (controller.getExecutable().stripsInputTypeAnnotations()) {
                                s = controller.getConfiguration().getAnnotationStripper(s);
                            }

                            Sender.send(source, s, null);

                            NodeInfo node = b.getCurrentRoot();
                            b.reset();

                            return SingletonIterator.makeIterator(node);
                        } catch ( IOException x ) {
                            throw new XPathException(x);
                        }
                    }
                }
            } catch ( TransformerException x ) {
                throw new XPathException(x);
            }
            return EmptyIterator.emptyIterator();
        }
        private HtmlParser getParser()
        {
            if (null == parser) {
                parser = new HtmlParser();
                // configure it the way we want
                //try {
                    //parser.setFeature(Parser.defaultAttributesFeature, false);
                    //parser.setFeature(Parser.ignoreBogonsFeature, false);
                //} catch (Exception x) {
                    // do nothing
                //}
            }

            return parser;
        }
    }

}
