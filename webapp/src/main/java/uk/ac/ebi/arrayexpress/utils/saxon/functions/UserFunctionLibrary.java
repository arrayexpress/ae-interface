package uk.ac.ebi.arrayexpress.utils.saxon.functions;

import net.sf.saxon.expr.Expression;
import net.sf.saxon.expr.StaticContext;
import net.sf.saxon.expr.StaticProperty;
import net.sf.saxon.functions.FunctionLibrary;
import net.sf.saxon.functions.StandardFunction;
import net.sf.saxon.functions.SystemFunction;
import net.sf.saxon.om.NamespaceConstant;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.pattern.NodeKindTest;
import net.sf.saxon.trans.Err;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.type.BuiltInAtomicType;
import net.sf.saxon.type.ItemType;

import java.util.HashMap;

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

public class UserFunctionLibrary implements FunctionLibrary
{
    private HashMap<String, StandardFunction.Entry> functionTable;

    public UserFunctionLibrary()
    {
        init();
    }

    protected StandardFunction.Entry register( String name,
                                               Class implementationClass,
                                               int opcode,
                                               int minArguments,
                                               int maxArguments,
                                               ItemType itemType,
                                               int cardinality )
    {
        StandardFunction.Entry e = StandardFunction.makeEntry(
                name, implementationClass, opcode, minArguments, maxArguments, itemType, cardinality);
        functionTable.put(name, e);
        return e;
    }

    protected void init()
    {
        functionTable = new HashMap<String, StandardFunction.Entry>(30);
        StandardFunction.Entry e;

        e = register("parse-html", ParseHtml.class, 0, 1, 1, NodeKindTest.DOCUMENT, StaticProperty.EXACTLY_ONE);
        StandardFunction.arg(e, 0, BuiltInAtomicType.STRING, StaticProperty.EXACTLY_ONE, null);
    }

    public boolean isAvailable( StructuredQName functionName, int arity )
    {
        if (functionName.getNamespaceURI().equals(NamespaceConstant.SAXON)) {
            StandardFunction.Entry entry = functionTable.get(functionName.getLocalName());
            return entry != null && (arity == -1 ||
                    (arity >= entry.minArguments && arity <= entry.maxArguments));
        } else {
            return false;
        }
    }

    public Expression bind( StructuredQName functionName, Expression[] staticArgs, StaticContext env )
            throws XPathException
    {
        String uri = functionName.getNamespaceURI();
        String local = functionName.getLocalName();
        if (uri.equals(NamespaceConstant.SAXON)) {
            StandardFunction.Entry entry = functionTable.get(local);
            if (entry == null) {
                return null;
            }
            Class functionClass = entry.implementationClass;
            SystemFunction f;
            try {
                f = (SystemFunction) functionClass.newInstance();
            } catch (Exception err) {
                throw new AssertionError("Failed to load Saxon extension function: " + err.getMessage());
            }
            f.setDetails(entry);
            f.setFunctionName(functionName);
            f.setArguments(staticArgs);
            checkArgumentCount(staticArgs.length, entry.minArguments, entry.maxArguments, local);
            return f;
        } else {
            return null;
        }
    }

    private int checkArgumentCount( int numArgs, int min, int max, String local ) throws XPathException
    {
        if (min == max && numArgs != min) {
            throw new XPathException("Function " + Err.wrap("saxon:" + local, Err.FUNCTION) + " must have "
                    + min + pluralArguments(min));
        }
        if (numArgs < min) {
            throw new XPathException("Function " + Err.wrap("saxon:" + local, Err.FUNCTION) + " must have at least "
                    + min + pluralArguments(min));
        }
        if (numArgs > max) {
            throw new XPathException("Function " + Err.wrap("saxon:" + local, Err.FUNCTION) + " must have no more than "
                    + max + pluralArguments(max));
        }
        return numArgs;
    }

    public static String pluralArguments( int num )
    {
        if (num == 1) return " argument";
        return " arguments";
    }

    public FunctionLibrary copy()
    {
        return this;
    }
}