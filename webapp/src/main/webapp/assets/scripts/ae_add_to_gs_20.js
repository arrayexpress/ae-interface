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
    $.accession = null;
    $.gsTargetDir = null;

    function
    gsLoggedIn( gsUserName )
    {
        $("#gs_auth_username").html(gsUserName);
        $("#gs_login_section").hide();
        $("#gs_upload_section").show();

        $.when(retrieveGSUserInformation()).then( function(json) {
            $.gsUserInfo = json;
            checkGSTargetDirectory();
        });
    }

    function
    gsLoggedOut()
    {
        $.gsUserInfo = null;

        $("#gs_auth_status").html("");
        $("#gs_login_section").show();
        $("#gs_upload_section").hide();
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
    checkGSMessage()
    {
        var message = $.cookie("gs-auth-message");
        if (null != message) {
            $("#gs_auth_message").html(message.replace(/^"?(.+[^"])"?$/g, "$1")).show();
            $.cookie("gs-auth-message", null, {path: contextPath});
        }
    }

    function
    retrieveGSUserInformation()
    {
        var dfr = $.Deferred();

        $.ajax({
            url : "https://identity.genomespace.org/identityServer/selfmanagement/user"
            , xhrFields: { withCredentials: true }
            , success : dfr.resolve
            , error: dfr.reject
            , dataType: "json"
        });

        return dfr.promise();
    }

    function
    checkGSTargetDirectory()
    {
        $.ajax({
            url : contextPath + "/gs/upload"
            , data: { action: "checkDirectory"
                , accession: $.accession
                , token: $.gsUserInfo.token
            }
            , dataType: "json"
            , success : function(json) {
                if (null != json) {
                    if ("exists" == json.status ) {
                        $.gsTargetDir = json.target;
                        $("#gs_target_dir").html("ArrayExpress/" + $.accession);
                        $("#gs_warning").show();
                    }
                }
            }
        });
    }

    function
    gsUploadFile(fileName)
    {
        var dfr = $.Deferred();

        $.ajax({
            url : contextPath + "/gs/upload"
            , data: { action: "uploadFile"
                , accession: $.accession
                , filename: fileName
                , target:  $.gsTargetDir
                , token: $.gsUserInfo.token
            }
            , dataType: "json"
            , success : dfr.resolve
            , error: dfr.reject

        });

        return dfr.promise();
    }

    function
    gsCreateTargetDirectory()
    {
        var dfr = $.Deferred();

        $.ajax({
            url : contextPath + "/gs/upload"
            , data: { action: "createDirectory"
                , accession: $.accession
                , token: $.gsUserInfo.token
            }
            , dataType: "json"
            , success : dfr.resolve
            , error: dfr.reject
        });

        return dfr.promise();
    }

    function
    uploadFile(counter)
    {
        var $check = $("#file_" + counter + "_check");
        if (0 != $check.length) {
            if ($check.prop("checked")) {
                var fileName = $("#file_" + counter + "_name").val();
                $.progressStatus.html("Sending " + fileName + " to GenomeSpace...");
                $check.prop("disabled", true);
                $("#file_" + counter + "_progress").addClass("in_progress");
                $.when(gsUploadFile(fileName)).then(function() {
                    $("#file_" + counter + "_progress").removeClass("in_progress").addClass("ok");
                    uploadFile(counter + 1);
                }, function() {
                    $("#file_" + counter + "_progress").removeClass("in_progress").addClass("failed");
                    $.progressStatus.html("There was an error uploading " + fileName + " to GenomeSpace.");
                    reEnableForm();
                })
            } else {
                uploadFile(counter + 1);
            }
        } else {
            if (counter > 1) {
                $.progressStatus.html("Upload completed. Please <a href='https://gsui.genomespace.org/jsui/gsui.html'>follow this link to open GenomeSpace UI</a>.");
            } else {
                $.progressStatus.html("&#160;");
            }
            reEnableForm();
        }
    }

    function
    uploadFiles()
    {
        // first - disable submit button to prevent second event call
        var $this = $(this);
        $this.prop("disabled", true);
        $(".file_div > span").removeClass();

        if (null == $.gsTargetDir) {
            $.progressStatus.html("Creating target directory in GenomeSpace...");

            $.when(gsCreateTargetDirectory()).then(function(json) {
                $.gsTargetDir = json.target;
                uploadFile(1);
            }, function() {
                // directory creation went wrong?
                $.progressStatus.html("There was an error creating target directory in GenomeSpace.");
                $this.removeProp("disabled");
            });
        } else {
            uploadFile(1);
        }
    }

    function
    reEnableForm()
    {
        $("#gs_upload_submit").removeProp("disabled");
        $(".file_check").removeProp("disabled");
    }

    $(function() {
        $.accession = $("#ae_accession").val();
        $.progressStatus = $("#gs_progress_status");
        checkGSMessage();
        checkIfLoggedToGS(gsLoggedIn, gsLoggedOut);
        $("#gs_upload_submit").click(uploadFiles);
    });

})(window.jQuery);