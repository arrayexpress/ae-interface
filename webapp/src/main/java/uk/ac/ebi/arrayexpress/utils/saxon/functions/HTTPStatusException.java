package uk.ac.ebi.arrayexpress.utils.saxon.functions;

import net.sf.saxon.trans.XPathException;

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

public class HTTPStatusException extends XPathException
{
    private static final long serialVersionUID = 3616976123541179808L;

    private Integer statusCode;

    public HTTPStatusException( Integer statusCode )
    {
        super("HTTP Status [" + String.valueOf(statusCode) + "]");
        this.statusCode = statusCode;
    }

    public Integer getStatusCode()
    {
        return this.statusCode;
    }
}
