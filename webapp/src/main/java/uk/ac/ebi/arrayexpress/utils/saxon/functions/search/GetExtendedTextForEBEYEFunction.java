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
import net.sf.saxon.om.Item;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.EmptyIterator;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import net.sf.saxon.value.Value;
import org.apache.commons.lang.StringUtils;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.Ontologies;
import uk.ac.ebi.arrayexpress.utils.saxon.search.Controller;

import java.io.IOException;
import java.util.Set;

public class GetExtendedTextForEBEYEFunction extends ExtensionFunctionDefinition {


	private static final StructuredQName qName = new StructuredQName("",
			NamespaceConstant.AE_SEARCH_EXT, "getExtendedTextForEBEYE");

	private Controller searchController;

	public GetExtendedTextForEBEYEFunction(Controller controller) {
		this.searchController = controller;
	}

    @Override
	public StructuredQName getFunctionQName() {
		return qName;
	}

    @Override
	public int getMinimumNumberOfArguments() {
		return 1;
	}

    @Override
	public int getMaximumNumberOfArguments() {
		return 1;
	}

    @Override
	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] { SequenceType.SINGLE_STRING };
	}

    @Override
	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.SINGLE_STRING;
	}

    @Override
	public ExtensionFunctionCall makeCallExpression() {
		return new ExtendedTextForEBEYE(searchController);
	}

	private static class ExtendedTextForEBEYE extends ExtensionFunctionCall {

        // logging machinery
        private transient final Logger logger = LoggerFactory.getLogger(getClass());

		private Controller searchController;

		public ExtendedTextForEBEYE( Controller searchController ) {
			this.searchController = searchController;
		}

        @Override
        @SuppressWarnings("unchecked")
		public SequenceIterator<? extends Item> call( SequenceIterator[] arguments, XPathContext context )
				throws XPathException {
			StringValue text = (StringValue) arguments[0].next();

            //TODO: get this from search engine
            try (IndexReader reader = IndexReader.open(searchController.getEnvironment("experiments").indexDirectory);
                 IndexSearcher searcher = new IndexSearcher(reader)) {

				Term t = new Term("accession", text.getStringValue()
						.toLowerCase());
				Query query = new TermQuery(t);

				Ontologies ont = (Ontologies) Application
						.getAppComponent("Ontologies");

				logger.debug("Accession [{}]", text.getStringValue());
				TopDocs hits = searcher.search(query, 1);
				System.out.println("hits ->" + hits.totalHits);
				for (int i = 0; i < hits.scoreDocs.length; i++) {
					ScoreDoc scoreDoc = hits.scoreDocs[i];
					Document doc = searcher.doc(scoreDoc.doc);
					String keywords = doc.get("keywords");

                    Set<String> expansion = ont.getExpansionLookupIndex().getReverseExpansion(keywords);
                    return Value.asIterator(StringValue.makeStringValue(StringUtils.join(expansion, ", ")));
				}
			} catch ( IOException x ) {
                throw new XPathException(x);
            }

            return EmptyIterator.emptyIterator();
		}
    }
}