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

(function($, undefined) {
    if($ == undefined)
        throw "jQuery not loaded";

    function
    gsLoggedIn( gs_username )
    {
        $("#status").html("Logged in as " + gs_username);
        //retrieveGSPersonalDirectory();
    }

    function
    gsLoggedOut()
    {
        $("#status").html("Not logged in");
    }

    function
    checkIfLoggedToGS( onLoggedInFunc, onLoggedOutFunc )
    {
        $.ajax({
            url : "https://identity.genomespace.org/identityServer/usermanagement/utility/token/username"
            , xhrFields: { withCredentials: true }
            , success : onLoggedInFunc
            , error : onLoggedOutFunc
        });
    }

    function
    retrieveGSPersonalDirectory()
    {
        $.ajax({
            url : "https://dm.genomespace.org/datamanager/v1.0/personaldirectory"
            , xhrFields: { withCredentials: true }
            , success : function(json) {
                alert(json.directory.path);
            }
            , dataType: "json"
        });
    }

    function
    upload_sendFileToURL(accession, fileName, url)
    {
        $.ajax({
            url : contextPath + "/gs/upload"
            , data: {action: "upload", accession: accession, filename: fileName, url: url}
            , success : function(ok) {
                alert(ok);
            }
            , error: function() {
                alert("Upload has failed");
            }
        });
    }

    function
    upload_getAmazonURL(accession, fileName, directory, fileInfo, onSuccess)
    {
        $.ajax({
            url : "https://dm.genomespace.org/datamanager/v1.0/uploadurl/" + directory + "/" + fileName
            , data: {"Content-Length": fileInfo.length, "Content-MD5": fileInfo.md5, "Content-Type": fileInfo.mimeType}
            , xhrFields: { withCredentials: true }
            , success : function(url) {
                upload_sendFileToURL(accession, fileName, url);
            }
            //, dataType: "json"
        });
    }

    function
    uploadFile(accession, fileName, destination)
    {
        $.ajax({
            url : contextPath + "/gs/upload"
            , data: {action: "info", accession: accession, filename: fileName}
            , xhrFields: { withCredentials: true }
            , success : function(json) {
                upload_getAmazonURL(accession, fileName, destination, json, upload_sendFileToURL);
            }
            , dataType: "json"
        });
    }

    $.uploadToGS = uploadFile;

    $(function() {
        checkIfLoggedToGS(gsLoggedIn, gsLoggedOut);
    });

})(window.jQuery);