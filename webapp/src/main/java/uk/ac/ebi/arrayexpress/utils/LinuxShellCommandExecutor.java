package uk.ac.ebi.arrayexpress.utils;

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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class LinuxShellCommandExecutor {

    private final static String EOL = System.getProperty("line.separator");

    private String output;
    private String errors;

    public LinuxShellCommandExecutor()
    {
        output = "";
        errors = "";
    }

    public boolean execute( String command, boolean waitForResult ) throws IOException, InterruptedException
    {
        List<String> commandParams = new ArrayList<String>();
        commandParams.add("/bin/sh");
        commandParams.add("-c");
        commandParams.add(command);

        ProcessBuilder pb = new ProcessBuilder(commandParams);
        Map<String, String> env = pb.environment();
        env.put("LC_ALL", "en_US.UTF-8");
        env.put("LANG", "en_US.UTF-8");
        env.put("LANGUAGE", "en_US.UTF-8");

        Process process = pb.start();

        if (waitForResult) {
            InputStream stdOut = process.getInputStream();
            InputStream stdErr = process.getErrorStream();

            output = streamToString(stdOut, "UTF-8");
            errors = streamToString(stdErr, "UTF-8");

            int returnCode = process.waitFor();

            return 0 == returnCode;
        } else {
            return true;
        }
    }

    public String getOutput() {
        return output;
    }

    public String getErrors() {
        return errors;
    }

    private String streamToString(InputStream is, String encoding) throws IOException {
        if (null != is) {
            StringBuilder sb = new StringBuilder();
            String line;
            try {
                BufferedReader reader = new BufferedReader(new InputStreamReader(is, encoding));
                while (null != (line = reader.readLine())) {
                    sb.append(line).append(EOL);
                }
            } finally {
                is.close();
            }
            return sb.toString();
        } else {
            return "";
        }
    }
}