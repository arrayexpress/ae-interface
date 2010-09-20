package uk.ac.ebi.arrayexpress.utils;

import au.com.bytecode.opencsv.CSVReader;

import java.io.Reader;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

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

public class SynonymsFileReader extends CSVReader
{
    public SynonymsFileReader( Reader ioReader )
    {
        super(ioReader, ' ', '\"');    
    }

    public Map<String, Set<String>> readSynonyms()
    {
        return new HashMap<String, Set<String>>();    
    }
}
