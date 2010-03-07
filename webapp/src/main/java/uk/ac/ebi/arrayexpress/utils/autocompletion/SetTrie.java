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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

public class SetTrie<T extends IObjectWithAStringKey>
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

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

    public void add( T object, boolean shouldOverride )
    {
        String key = object.getKey();
        if (lines.contains(key)) {
            if (!shouldOverride) {
                logger.warn("Set already contains [{}], ignoring object [{}]", key, object.toString());
                return;
            } else {
                logger.warn("Set already contains [{}], overriding with object [{}]", key, object.toString());
                lines.remove(key);
                objects.remove(key);
            }
        }
        lines.add(key);
        objects.put(key, object);
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