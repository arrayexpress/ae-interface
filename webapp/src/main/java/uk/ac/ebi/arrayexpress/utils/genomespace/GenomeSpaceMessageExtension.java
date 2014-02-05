package uk.ac.ebi.arrayexpress.utils.genomespace;

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

import org.openid4java.message.MessageExtension;
import org.openid4java.message.ParameterList;

public class GenomeSpaceMessageExtension implements MessageExtension
{
    // These must match what the OpenID Provider definitions.
    public static final String URI = "http://identity.genomespace.org/openid/";
    public static final String TOKEN_ALIAS = "gs-token";
    public static final String USERNAME_ALIAS = "gs-username";
    public static final String EMAIL_ALIAS = "email";
    public static final String TEMP_LOGIN_ALIAS = "temp-pw-login";

    private ParameterList paramList = new ParameterList();

    @Override
    public String getTypeUri()
    {
        return URI;
    }

    @Override
    public ParameterList getParameters()
    {
        return paramList;
    }

    @Override
    public void setParameters(ParameterList params)
    {
        paramList = new ParameterList(params);
    }

    @Override
    public boolean providesIdentifier()
    {
        return false;
    }

    @Override
    public boolean signRequired()
    {
        return false;
    }
}
