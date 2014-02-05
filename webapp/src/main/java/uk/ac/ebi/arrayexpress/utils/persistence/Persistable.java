package uk.ac.ebi.arrayexpress.utils.persistence;

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

/**
 * Persistable class implements three basic functions
 *
 * - toPersisence() that creates a String based upon object contents
 * - fromPersistence( String ) that initializes an Object based upon a String parameter
 * - isEmpty() that returns true if object should be loaded from persistence
 */
public interface Persistable
{
    public String toPersistence();

    public void fromPersistence( String str );

    public boolean isEmpty();
}
