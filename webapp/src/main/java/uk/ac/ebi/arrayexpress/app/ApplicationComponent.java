package uk.ac.ebi.arrayexpress.app;

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

abstract public class ApplicationComponent
{
    private String componentName;

    public ApplicationComponent()
    {
        componentName = getClass().getName().replaceFirst("^.+\\.", "");
    }

    public String getName()
    {
        return componentName;
    }

    public Application getApplication()
    {
        return Application.getInstance();
    }

    public ApplicationComponent getComponent( String name )
    {
        return Application.getInstance().getComponent(name);
    }

    public ApplicationPreferences getPreferences()
    {
        return Application.getInstance().getPreferences();
    }

    public abstract void initialize() throws Exception;

    public abstract void terminate() throws Exception;
}
