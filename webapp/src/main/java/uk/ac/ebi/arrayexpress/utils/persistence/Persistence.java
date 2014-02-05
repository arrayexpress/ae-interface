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

import java.io.IOException;

public abstract class Persistence<T extends Persistable>
{
	private T object = null;

    public Persistence( T object )
    {
        assignObject(object);
    }

    private void assignObject( T object )
    {
        if (null == object) {
            throw new IllegalArgumentException("Persistence created with null object");
        }

        this.object = object;
    }

	public T getObject() throws IOException
	{
		if (this.object.isEmpty()) {
			restore(this.object);
		}
        return this.object;
	}

	public void setObject( T object ) throws IOException
	{
        assignObject(object);
		persist(this.object);
	}

	abstract void persist( T object ) throws IOException;
	abstract void restore( T object ) throws IOException;
}
