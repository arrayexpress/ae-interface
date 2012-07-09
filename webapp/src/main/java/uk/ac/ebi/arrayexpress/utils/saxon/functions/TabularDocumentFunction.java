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
import org.xml.sax.InputSource;
import uk.ac.ebi.arrayexpress.utils.io.FilteringIllegalHTMLCharactersReader;
import uk.ac.ebi.arrayexpress.utils.io.SmartUTF8CharsetDecoder;
import uk.ac.ebi.arrayexpress.utils.io.UnescapingXMLNumericReferencesReader;
import uk.ac.ebi.arrayexpress.utils.saxon.FlatFileXMLReader;

import javax.xml.transform.Source;
import javax.xml.transform.sax.SAXSource;
import java.io.*;

public class TabularDocumentFunction extends ExtensionFunctionDefinition
{
    private static final long serialVersionUID = 7434621414885530725L;

    private static final StructuredQName qName =
            new StructuredQName("", NamespaceConstant.AE_EXT, "tabularDocument");

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
        return SequenceType.SINGLE_NODE;
    }

    public ExtensionFunctionCall makeCallExpression()
    {
        return new TabularDocumentCall();
    }

    private static class TabularDocumentCall extends ExtensionFunctionCall
    {
        private static final long serialVersionUID = 8149635307726580689L;

        public SequenceIterator<? extends Item> call( SequenceIterator[] arguments, XPathContext context ) throws XPathException
        {
            try {
                Controller controller = context.getController();
                String baseURI = ((NodeInfo)context.getContextItem()).getBaseURI();

                StringValue locationValue = (StringValue) arguments[0].next();
                StringValue optionsValue = (StringValue) arguments[1].next();

                if (null != locationValue) {
                    File flatFile = new File(locationValue.getStringValue());

                    if (!flatFile.exists()) {
                        throw new XPathException("Unable to open document [" + locationValue.getStringValue() + "]");
                    }

                    InputStream in = new FileInputStream(flatFile);
                    InputSource is = new InputSource(
                            new FilteringIllegalHTMLCharactersReader(
                                    new UnescapingXMLNumericReferencesReader(
                                            new InputStreamReader(
                                                    in
                                                    , new SmartUTF8CharsetDecoder()
                                            )
                                    )
                            )
                    );
                    is.setSystemId(baseURI);

                    Source source = new SAXSource(
                            new FlatFileXMLReader(
                                    null != optionsValue ? optionsValue.getStringValue() : null
                            )
                            , is
                    );
                    source.setSystemId(baseURI);

                    Builder b = controller.makeBuilder();
                    Receiver s = b;

                    source = AugmentedSource.makeAugmentedSource( source );
                    ((AugmentedSource) source).setStripSpace(Whitespace.XSLT);

                    if (controller.getExecutable().stripsInputTypeAnnotations()) {
                        s = controller.getConfiguration().getAnnotationStripper(s);
                    }

                    Sender.send( source, s, null );
                    NodeInfo node = b.getCurrentRoot();
                    b.reset();
                    return SingletonIterator.makeIterator(node);
                }
            } catch ( FileNotFoundException x ) {
                throw new XPathException(x);
            }
            return EmptyIterator.emptyIterator();
        }
    }
}
