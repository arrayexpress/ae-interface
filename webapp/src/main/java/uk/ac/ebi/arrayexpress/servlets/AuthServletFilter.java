package uk.ac.ebi.arrayexpress.servlets;

/*
 * Copyright 2009-2010 Functional Genomics Group, European Bioinformatics Institute
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

import uk.ac.ebi.arrayexpress.utils.CookieMap;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;


public class AuthServletFilter implements Filter
{
    protected FilterConfig filterConfig;

    public void init( FilterConfig filterConfig ) throws ServletException
    {
        this.filterConfig = filterConfig;
    }

    public void destroy()
    {
        this.filterConfig = null;
    }

    public void doFilter( ServletRequest request, ServletResponse response, FilterChain chain ) throws java.io.IOException, ServletException
    {
        doAuthCheck(request);

        chain.doFilter(request, response);
    }

    private void doAuthCheck( ServletRequest request )
    {
        HttpServletRequest httpRequest = (HttpServletRequest)request;

        CookieMap cookies = new CookieMap(httpRequest.getCookies());
    }
}