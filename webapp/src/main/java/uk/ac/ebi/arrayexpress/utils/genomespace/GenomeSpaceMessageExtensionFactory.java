package uk.ac.ebi.arrayexpress.utils.genomespace;

/*
 * Copyright 2009-2013 European Molecular Biology Laboratory
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

import org.openid4java.message.MessageException;
import org.openid4java.message.MessageExtension;
import org.openid4java.message.MessageExtensionFactory;
import org.openid4java.message.ParameterList;

public class GenomeSpaceMessageExtensionFactory implements MessageExtensionFactory
{
    @Override
    public String getTypeUri()
    {
        return GenomeSpaceMessageExtension.URI;
    }

    @Override
    public MessageExtension getExtension(ParameterList parameterList,
                                         boolean isRequest) throws MessageException
    {
        GenomeSpaceMessageExtension messageExtension = new GenomeSpaceMessageExtension();
        messageExtension.setParameters(parameterList);
        return messageExtension;
    }
}