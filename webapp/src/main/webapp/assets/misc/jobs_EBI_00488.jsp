<%--
 * Copyright 2009-2015 European Molecular Biology Laboratory
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
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- for more info please see http://stackoverflow.com/questions/1296235/jsp-tricks-to-make-templating-easier/3257426#3257426 -->
<!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->
<!--[if lt IE 7]> <html class="no-js ie6 oldie" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js ie7 oldie" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js ie8 oldie" lang="en"> <![endif]-->
<!-- Consider adding an manifest.appcache: h5bp.com/d/Offline -->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta charset="utf-8">
    <title>EBI_00488 &lt; Jobs &lt; ArrayExpress &lt; EMBL-EBI</title>
    <meta name="description" content="EMBL-EBI">
    <meta name="keywords" content="bioinformatics, europe, institute">
    <meta name="author" content="EMBL-EBI">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <link rel="stylesheet" href="//www.ebi.ac.uk/web_guidelines/css/compliance/mini/ebi-fluid-embl.css" type="text/css">
    <link rel="stylesheet" href="/arrayexpress/assets/stylesheets/font-awesome.css" type="text/css">
    <link rel="stylesheet" href="/arrayexpress/assets/stylesheets/ae-common-1.0.150312.css" type="text/css">
    <script src="//www.ebi.ac.uk/web_guidelines/js/libs/modernizr.custom.49274.js"></script>
</head>
<body class="level2">
<div id="skip-to">
    <ul><li><a href="#content" title="">Skip to main content</a></li>
        <li><a href="#local-nav" title="">Skip to local navigation</a></li>
        <li><a href="#global-nav" title="">Skip to EBI global navigation menu</a></li>
        <li><a href="#global-nav-expanded" title="">Skip to expanded EBI global navigation menu (includes all sub-sections)</a></li></ul>
</div>
<div id="wrapper" class="container_24">
    <header>
        <div id="global-masthead" class="masthead grid_24"><a href="//www.ebi.ac.uk/" title="Go to the EMBL-EBI homepage"><img src="//www.ebi.ac.uk/web_guidelines/images/logos/EMBL-EBI/EMBL_EBI_Logo_white.png" alt="EMBL European Bioinformatics Institute"></a><nav><ul id="global-nav"><li class="first active" id="services"><a href="//www.ebi.ac.uk/services">Services</a></li><li id="research"><a href="//www.ebi.ac.uk/research">Research</a></li><li id="training"><a href="//www.ebi.ac.uk/training">Training</a></li><li id="industry"><a href="//www.ebi.ac.uk/industry">Industry</a></li><li id="about" class="last"><a href="//www.ebi.ac.uk/about">About us</a></li></ul></nav></div>
        <div id="local-masthead" class="masthead grid_24 nomenu"><div id="local-title" class="logo-title grid_12 alpha"><img class="svg" src="/arrayexpress/assets/images/ae-logo-64.svg" width="64" height="64" alt="AE"><span><h1><a href="/arrayexpress/" title="Back to ArrayExpress homepage">ArrayExpress</a></h1></span></div><div class="grid_12 omega"><form id="local-search" name="local-search" action="/arrayexpress/search" method="get"><fieldset><div class="left"><label><input type="text" name="query" id="local-searchbox"></label>
            <span class="examples">Examples: <a href="/arrayexpress/search?query=E-MEXP-31">E-MEXP-31</a>, <a href="/arrayexpress/search?query=cancer">cancer</a>, <a href="/arrayexpress/search?query=p53">p53</a>, <a href="/arrayexpress/search?query=Geuvadis">Geuvadis</a></span></div>
            <div class="right"><input type="submit" value="Search" class="submit"><span class="adv"><a href="/arrayexpress/help/how_to_search.html#AdvancedSearchExperiment" id="adv-search" title="Advanced">Advanced</a></span></div></fieldset></form></div>
            <nav><ul class="grid_24" id="local-nav"><li class="first"><a href="/arrayexpress/" title="ArrayExpress 2.0">Home</a></li><li><a href="/arrayexpress/experiments/browse.html" title="Experiments">Experiments</a></li><li><a href="/arrayexpress/arrays/browse.html?directsub=on" title="Arrays">Arrays</a></li><li><a href="/arrayexpress/submit/overview.html" title="Submit">Submit</a></li><li><a href="/arrayexpress/help/index.html" title="Help">Help</a></li><li><a href="/arrayexpress/about.html">About ArrayExpress</a></li><li class="functional last"><a href="#" class="icon icon-functional login" data-icon="l">Login</a></li><li class="functional"><a href="#" class="icon icon-static feedback" data-icon="\">Feedback</a></li></ul></nav></div></header><div id="content" role="main" class="grid_24 clearfix"><section id="ae-login" style="display:none"><h3>ArrayExpress submitter/reviewer login<a id="ae-login-close" href="#" class="icon icon-functional" data-icon="x"></a></h3><form id="ae-login-form" method="post" action="/arrayexpress/auth"><fieldset><label for="ae-user-field">User name</label><input id="ae-user-field" name="u" maxlength="50"></fieldset><fieldset><label for="ae-pass-field">Password</label><input id="ae-pass-field" type="password" name="p" maxlength="50"></fieldset><span id="ae-login-remember-option"><input id="ae-login-remember" name="r" type="checkbox"><label for="ae-login-remember">Remember me</label></span><input class="submit" type="submit" value="Login"><div class="ae-login-status" style="display:none"></div><div id="ae-login-forgot"><a href="#">Forgot user name or password?</a></div></form><form id="ae-forgot-form" method="post" action="/arrayexpress/auth"><fieldset><label for="ae-name-email-field">User name or email address</label><input id="ae-name-email-field" name="e" maxlength="50"></fieldset><fieldset><label for="ae-accession-field">Experiment accession associated with the account</label><input id="ae-accession-field" name="a" maxlength="14"></fieldset><div>We will send you a reminder with your account information</div><div class="ae-login-status" style="display:none"></div><input class="submit" type="submit" value="Send"></form></section><section id="ae-feedback" style="display:none"><h3>Have your say<a id="ae-feedback-close" href="#" class="icon icon-functional" data-icon="x"></a></h3><form method="post" action="#" onsubmit="return false"><fieldset><label for="ae-feedback-message">We value your feedback. Please leave your comment below.</label><textarea id="ae-feedback-message" name="m"></textarea></fieldset><fieldset><label for="ae-email-field">Optionally please enter your email address if you wish to get a response.<br>We will never share this address with anyone else.</label><input id="ae-email-field" name="e" maxlength="50"></fieldset><input type="hidden" name="p" value="/arrayexpress/jobs/EBI_00488/"><input type="hidden" name="r" value="/arrayexpress/"><input class="submit" type="submit" value="Send"></form></section>
    <section class="grid_24">
        <h2>Test Assignment for EBI_00488</h2>
        <%
            String code = request.getParameter("code");
            if (null == code || code.trim().isEmpty()) {
        %>
        <h3>Please enter the code below:</h3>
        <form method="get" action=".">
            <input type="text" name="code" maxlength="11" style="font-size:300%;font-family:monospace;width:7em;text-align:center">
        </form>
        <%
        } else {
        %>
        <h3>Instructions</h3>
        <p>The assignment describes several problems - please provide us snippets of code (in a language of your choice) via email to arrayexpress@ebi.ac.uk. We’d expect you to spend around 2 hours in total writing solutions for these.</p>
        <p><strong>Please note - time spent between downloading the assignment and sending us the results will be measured; please proceed only when you're ready to complete the assignment</strong>.</p>
        <p>In you have any questions please don't hesitate to email us at arrayexpress@ebi.ac.uk. Thanks and good luck!</p>
        <form id="accept" method="get" action="${pageContext.request.contextPath}/send-assignment/EBI_00488/EBI_00488_assignment.pdf">
            <input type="hidden" name="code" value="${param.code}">
            <input type="submit" value="I understand - please provide me with the assignment">
        </form>
        <%
            }
        %>
    </section></div><footer><div id="global-footer" class="grid_24"><nav id="global-nav-expanded"><div class="grid_4 alpha"><h3 class="embl-ebi"><a href="//www.ebi.ac.uk/" title="EMBL-EBI">EMBL-EBI</a></h3></div><div class="grid_4"><h3 class="services"><a href="//www.ebi.ac.uk/services">Services</a></h3></div><div class="grid_4"><h3 class="research"><a href="//www.ebi.ac.uk/research">Research</a></h3></div><div class="grid_4"><h3 class="training"><a href="//www.ebi.ac.uk/training">Training</a></h3></div><div class="grid_4"><h3 class="industry"><a href="//www.ebi.ac.uk/industry">Industry</a></h3></div><div class="grid_4 omega"><h3 class="about"><a href="//www.ebi.ac.uk/about">About us</a></h3></div></nav><section id="ebi-footer-meta"><p class="address">EMBL-EBI, Wellcome Trust Genome Campus, Hinxton, Cambridgeshire, CB10 1SD, UK &nbsp; &nbsp; +44 (0)1223 49 44 44</p><p class="legal">Copyright © EMBL-EBI 2013 | EBI is an Outstation of the
    <a href="http://www.embl.org">European Molecular Biology Laboratory</a> | <a href="/about/privacy">Privacy</a> | <a
            href="/about/cookies">Cookies</a> | <a href="/about/terms-of-use">Terms of
        use</a></p></section></div></footer></div><script defer src="//www.ebi.ac.uk/web_guidelines/js/cookiebanner.js"></script><script defer src="//www.ebi.ac.uk/web_guidelines/js/foot.js"></script><script type="text/javascript">var contextPath = "/arrayexpress";</script><script src="/arrayexpress/assets/scripts/jquery-1.8.2.min.js"></script><script src="/arrayexpress/assets/scripts/jquery.cookie-1.0.js"></script><script src="/arrayexpress/assets/scripts/jquery.caret-range-1.0.js"></script><script src="/arrayexpress/assets/scripts/jquery.autocomplete-1.1.0.150319.js"></script><script src="/arrayexpress/assets/scripts/jquery.ae-common-1.0.150304.js"></script></body></html>