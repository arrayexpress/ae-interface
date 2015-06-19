package uk.ac.ebi.arrayexpress.utils;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

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

public class StringToolsTest
{
    @Test
    public void testUnescapeHTMLDecimalEntities()
    {
        assertEquals("hello world", StringTools.unescapeHTMLEntities("hello world"));
        assertEquals("hello &xx; world", StringTools.unescapeHTMLEntities("hello &xx; world"));
        assertEquals("hello &; world", StringTools.unescapeHTMLEntities("hello &; world"));
        assertEquals("hello &apos world; '", StringTools.unescapeHTMLEntities("hello &apos world; &apos;"));
        assertEquals("hello ø world &#48;", StringTools.unescapeHTMLEntities("hello &oslash; world &#48;"));
    }

    @Test
    public void testUnescapeXMLDecimalEntities()
    {
        assertEquals("hello world", StringTools.unescapeXMLDecimalEntities("hello world"));
        assertEquals("hello &# world", StringTools.unescapeXMLDecimalEntities("hello &# world"));
        assertEquals("hello &# world &#", StringTools.unescapeXMLDecimalEntities("hello &# world &#"));
        assertEquals("hello &# world 0", StringTools.unescapeXMLDecimalEntities("hello &# world &#48;"));
        String experimentsXmlText = "12 AgilentC&#2;B&#18;s C&#2;B&#19;44K whole genomeC&#2;B&#20; arrays";
            experimentsXmlText = experimentsXmlText.replaceAll("&amp;#(\\d+);", "&#$1;");
            experimentsXmlText = StringTools.unescapeXMLDecimalEntities(experimentsXmlText);
            experimentsXmlText = StringTools.detectDecodeUTF8Sequences(experimentsXmlText);
            experimentsXmlText = StringTools.replaceIllegalHTMLCharacters(experimentsXmlText, true);
    }

    @Test
    public void testDetectDecodeUTF8Sequences()
    {
        String in = "Biom�rieux \"Antonio Rodr�guez-Garc�a\"";
        String out = StringTools.detectDecodeUTF8Sequences(in);
        assertEquals(in, out);

        assertEquals("\u2019", StringTools.detectDecodeUTF8Sequences("\u00e2\u0080\u0099"));
    }
}
