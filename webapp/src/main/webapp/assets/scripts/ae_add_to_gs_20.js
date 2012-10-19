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

    $.gsUserInfo = null;
    $.gsPersonalDirectory = null;

    function
    gsLoggedIn( gsUserName )
    {
        $("#status").html("Logged in as " + gsUserName);

        retrieveGSUserInformation();
        retrieveGSPersonalDirectory();
    }

    function
    gsLoggedOut()
    {
        $("#status").html("Not logged in");
        $.gsUserInfo = null;
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
    retrieveGSUserInformation()
    {
        $.ajax({
            url : "https://identity.genomespace.org/identityServer/selfmanagement/user"
            , xhrFields: { withCredentials: true }
            , success : function(json) {
                $.gsUserInfo = json;
            }
            , dataType: "json"
        });
    }

    function
    retrieveGSPersonalDirectory()
    {
        $.ajax({
            url : "https://dm.genomespace.org/datamanager/v1.0/personaldirectory"
            , xhrFields: { withCredentials: true }
            , success : function(json) {
                $.gsPersonalDirectory = json;
            }
            , dataType: "json"
        });
    }

    function
    uploadFile(accession, fileName, target)
    {
        $.ajax({
            url : contextPath + "/gs/upload"
            , data: { action: "uploadFile"
                , accession: accession
                , filename: fileName
                , target: target
                , token: $.gsUserInfo.token
            }
            , xhrFields: { withCredentials: true }
            , success : function(done) {
                alert(done);
            }
        });
    }

    function
    createDirectory(accession)
    {
        $.ajax({
            url : contextPath + "/gs/upload"
            , data: { action: "createDirectory"
                , accession: accession
                , token: $.gsUserInfo.token
            }
            , xhrFields: { withCredentials: true }
            , success : function(done) {
                alert(done);
            }
        });
    }

    $.gsCreateDir = createDirectory;
    $.gsUploadFile = uploadFile;

    $(function() {
        checkIfLoggedToGS(gsLoggedIn, gsLoggedOut);
    });

})(window.jQuery);