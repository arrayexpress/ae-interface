package uk.ac.ebi.arrayexpress.utils.autocompletion;

/*
 * Copyright 2009-2012 European Molecular Biology Laboratory
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

public class SetTrie
{
    private TreeSet<String> lines;

    public SetTrie()
    {
        lines = new TreeSet<String>();
    }

    public SetTrie( Comparator<? super String> comp )
    {
        lines = new TreeSet<String>(comp);
    }

    public void clear()
    {
        synchronized(this) {
            lines.clear();
        }
    }

    public void add( String line )
    {
        synchronized(this) {
            lines.add(line);
        }
    }

    public synchronized boolean matchPrefix( String prefix )
    {
        Set<String> tailSet;

        synchronized(this) {
            tailSet = lines.tailSet(prefix);
        }

        for (String tail : tailSet) {
            if (tail.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }

    public synchronized List<String> findCompletions( String prefix )
    {
        List<String> completions = new ArrayList<String>();
        Set<String> tailSet;

        synchronized(this) {
            tailSet = lines.tailSet(prefix);
        }

        for (String tail : tailSet) {
            if (tail.toLowerCase().startsWith(prefix.toLowerCase())) {
                completions.add(tail);
            } else {
                break;
            }
        }
        return completions;
    }
}