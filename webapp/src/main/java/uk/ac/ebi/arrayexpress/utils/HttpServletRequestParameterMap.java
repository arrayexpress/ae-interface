package uk.ac.ebi.arrayexpress.utils;

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

import javax.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.util.*;

public class HttpServletRequestParameterMap extends HashMap<String,String[]>
{
    private static final long serialVersionUID = -9113326940165926711L;

    private final static RegexHelper ALL_SANS_SQUARE_BRACKETS = new RegexHelper("^(.*)\\[\\d*\\]$", "ig");

    private final static Map<String, String> PARAM_ALIASES_MAP = createAliasesMap();

    private static Map<String, String> createAliasesMap()
    {
        Map<String, String> result = new HashMap<>();
        result.put("query", "keywords");
        result.put("species", "organism");
        return Collections.unmodifiableMap(result);
    }

    public HttpServletRequestParameterMap( HttpServletRequest request ) throws UnsupportedEncodingException
    {
        if (null != request) {
            Map params = request.getParameterMap();
            for ( Object param : params.entrySet() ) {
                Map.Entry p = (Map.Entry) param;
                String key = filterArrayBrackets((String)p.getKey());
                String[] values = fixUTF8Values((String[])p.getValue());
                List<String> newValues = Arrays.asList(values);
                if (this.containsKey(key)) {
                    List<String> oldValues = Arrays.asList(this.get(key));
                    List<String> combined = new ArrayList<>();
                    combined.addAll(oldValues);
                    combined.addAll(newValues);
                    this.put(key, combined.toArray(new String[combined.size()]));
                } else {
                    this.put(key, values);
                }
            }
            // populating some extra parameters from the Request object
            String host = request.getScheme() + "://" + request.getHeader("host");
            this.put("user-agent", request.getHeader("User-agent"));
            this.put("host", host);
            this.put("context-path", request.getContextPath());
            this.put("request-uri", request.getRequestURI());
            this.put("path-info", request.getPathInfo());
            this.put("query-string", request.getQueryString());

            String referer = request.getHeader("Referer");

            if (null != referer && referer.startsWith(host)) {
                referer = referer.replace(host, "");
            }
            this.put("referer", referer);

            if (null != request.getAttribute("javax.servlet.error.status_code")) {
                this.put("error-code", String.valueOf(request.getAttribute("javax.servlet.error.status_code")));
                this.put("error-message", String.valueOf(request.getAttribute("javax.servlet.error.message")));
                this.put("error-request-uri", StringTools.safeToString(request.getAttribute("javax.servlet.error.request_uri"), ""));
            }
        }
    }

    @Override
    public String[] put( String key, String[] value )
    {
        if (PARAM_ALIASES_MAP.containsKey(key)) {
            key = PARAM_ALIASES_MAP.get(key);
        }
        return super.put(key, value);
    }

    public void put( String key, String value )
    {
        if (null != value) {
            String[] arrValue = new String[1];
            arrValue[0] = value;
            this.put(key, arrValue);
        }
    }

    public void put( String key, List<String> values )
    {
        if (null != values) {
            this.put(key, values.toArray(new String[values.size()]));
        }
    }

    public String getString( String key )
    {
        if (this.containsKey(key)) {
            return StringTools.arrayToString(this.get(key), ",");
        }
        return null;
    }

    private String filterArrayBrackets( String key )
    {
        String result = ALL_SANS_SQUARE_BRACKETS.matchFirst(key);
        return !"".equals(result) ? result : key;
    }

    private String[] fixUTF8Values( String[] values ) throws UnsupportedEncodingException
    {
        if (null != values && 0 != values.length) {
            String[] fixedValues = new String[values.length];
            for (int pos = 0; pos < values.length; ++pos) {
                if (null != values[pos] && 0 != values[pos].length()) {
                    fixedValues[pos] = new String(values[pos].getBytes("ISO-8859-1"), "UTF-8");
                } else {
                    fixedValues[pos] = values[pos];
                }
            }
            return fixedValues;
        } else {
            return values;
        }
    }
}
