package uk.ac.ebi.arrayexpress.utils.autocompletion;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

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

public class AutocompleteStore
{
    private SetTrie trie;
    private HashMap<String, AutocompleteData> objects;

    public AutocompleteStore()
    {
        this.trie = new SetTrie();
        this.objects = new HashMap<String, AutocompleteData>();
    }

    public void clear()
    {
        trie.clear();
        objects.clear();
    }
    
    public void addData( AutocompleteData data )
    {
        String key = data.getKey();
        this.trie.add(key);
        this.objects.put(key, data);
    }

    public List<AutocompleteData> findCompletions( String prefix, String fieldName, Integer limit )
    {
        List<AutocompleteData> comps = new ArrayList<AutocompleteData>();
        if ("".equals(fieldName) || -1 == " assaycount samplecount rawcount fgemcount efcount sacount miamescore ".indexOf(" " + fieldName + " ")) {
            List<String> matches = trie.findCompletions(prefix);

            for (String key : matches) {
                AutocompleteData data = this.objects.get(key);
                if ("".equals(fieldName)) {
                    // in this case we put "keyword" data, EFO and fieldNames, EFO will override keywords
                    if (AutocompleteData.DATA_TEXT == data.getDataType() && "keywords".equals(data.getData())
                            || AutocompleteData.DATA_TEXT != data.getDataType()) {
                        comps.add(data);
                    }
                } else {
                    if ((AutocompleteData.DATA_TEXT == data.getDataType() && fieldName.equals(data.getData()))
                            || (-1 != "sa efv exptype".indexOf(fieldName) && AutocompleteData.DATA_EFO_NODE == data.getDataType())) {
                        comps.add(data);
                    }
                }
                if (null != limit && comps.size() == limit) {
                    break;
                }
            }
        }
        return comps;
    }
}
