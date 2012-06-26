package uk.ac.ebi.arrayexpress.utils.saxon.functions.old;

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
/*
public class ParseHtml extends SystemFunction
{

    private static final long serialVersionUID = -3160902172545280473L;

    private String baseURI;
    private transient Parser parser;

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
*/