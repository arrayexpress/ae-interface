package uk.ac.ebi.arrayexpress.utils.saxon.functions;

import net.sf.saxon.AugmentedSource;
import net.sf.saxon.Controller;
import net.sf.saxon.event.Builder;
import net.sf.saxon.event.Receiver;
import net.sf.saxon.event.Sender;
import net.sf.saxon.expr.Expression;
import net.sf.saxon.expr.ExpressionVisitor;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.functions.SystemFunction;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.AtomicValue;
import net.sf.saxon.value.Whitespace;
import org.ccil.cowan.tagsoup.Parser;
import org.xml.sax.InputSource;

import javax.xml.transform.Source;
import javax.xml.transform.sax.SAXSource;
import java.io.StringReader;

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

public class ParseHtml extends SystemFunction
{

    private String baseURI;
    private Parser parser;

    public void checkArguments( ExpressionVisitor visitor ) throws XPathException
    {
        if (baseURI == null) {
            super.checkArguments(visitor);
            baseURI = visitor.getStaticContext().getBaseURI();
        }
    }

    public Expression preEvaluate( ExpressionVisitor visitor ) throws XPathException
    {
        return this;
    }

    public Item evaluateItem( XPathContext c ) throws XPathException
    {
        Controller controller = c.getController();
        AtomicValue content = (AtomicValue) argument[0].evaluateItem(c);
        StringReader sr = new StringReader(content.getStringValue());
        InputSource is = new InputSource(sr);
        is.setSystemId(baseURI);
        Source source = new SAXSource(getParser(), is);
        source.setSystemId(baseURI);
        Builder b = controller.makeBuilder();
        Receiver s = b;
        source = AugmentedSource.makeAugmentedSource(source);
        ((AugmentedSource) source).setStripSpace(Whitespace.XSLT);
        if (controller.getExecutable().stripsInputTypeAnnotations()) {
            s = controller.getConfiguration().getAnnotationStripper(s);
        }
        try {
            new Sender(controller.makePipelineConfiguration()).send(source, s);
            NodeInfo node = b.getCurrentRoot();
            b.reset();
            return node;
        } catch (XPathException err) {
            throw new XPathException(err);
        }
    }

    private Parser getParser()
    {
        if (null == parser) {
            parser = new Parser();
            // configure it the way we want
            try {
                parser.setFeature(Parser.defaultAttributesFeature, false);
                parser.setFeature(Parser.ignoreBogonsFeature, true);
            } catch (Exception x) {
                // do nothing
            }
        }

        return parser;
    }
}
