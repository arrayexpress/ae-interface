package uk.ac.ebi.arrayexpress.utils.autocompletion;

/*
 * Copyright 2009-2010 Microarray Informatics Group, European Bioinformatics Institute
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

import java.util.*;

public class SetTrie<T extends IObjectWithAStringKey>
{
    private TreeSet<String> lines;
    private HashMap<String, T> objects;

    public SetTrie()
    {
        lines = new TreeSet<String>();
        objects = new HashMap<String, T>();
    }

    public void clear()
    {
        lines.clear();
        objects.clear();
    }

    public void add( T object )
    {
        lines.add(object.getKey());
        objects.put(object.getKey(), object);
    }

    public boolean matchPrefix( String prefix )
    {
        Set<String> tailSet = lines.tailSet(prefix);
        for (String tail : tailSet) {
            if (tail.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }

    public List<T> findCompletions( String prefix, Integer limit )
    {
        List<T> completions = new ArrayList<T>();
        Set<String> tailSet = lines.tailSet(prefix);
        int count = 0;
        for (String tail : tailSet) {
            if (tail.startsWith(prefix)) {
                completions.add(objects.get(tail));
                if (null != limit && ++count >= limit) {
                    break;
                }
            } else {
                break;
            }
        }
        return completions;
    }
}