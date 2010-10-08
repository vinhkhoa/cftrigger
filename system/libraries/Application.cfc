<!---
	Project:		cfTrigger
	Summary:		Main Controller class
	
	Log:
	Created:		05/06/2009
	Modified:
	- 

--->

<cfcomponent displayname="Application" output="false">
	<cfsetting enablecfoutputonly="yes">

	<cfscript>
		// GENERAL SETTINGS
		This.Sessionmanagement = "True";
		This.loginstorage = "session";
		This.scriptProtect = "none";
	</cfscript>
	

	<!--- ================================ APPLICATION METHODS ================================= --->

	<cffunction name="OnApplicationStart">
	
		<cfset var tempCurrentPage = "">
		<cfset var i = "">
		<cfset var k = "">
		
	
		<cfset setLocale("English (Australian)")>
	
		<cfscript>
			/* =========================================== SERVER SETTINGS =========================================== */
			
			// Get the current page from CGI to check for server
			// HTTPS?
			if (CGI.HTTPS neq 'ON' AND CGI.HTTPS neq 1)
			{
				tempCurrentPage = 'http://' & CGI.SERVER_NAME;
			}
			else
			{
				tempCurrentPage = 'https://' & CGI.SERVER_NAME;
			}
			
			// Has a port number?
			if (CGI.SERVER_PORT neq '' AND CGI.SERVER_PORT neq 80)
			{
				tempCurrentPage = tempCurrentPage & ":" & CGI.SERVER_PORT;
			}
			
			tempCurrentPage = tempCurrentPage & CGI.SCRIPT_NAME;
		
			// GET CURRENT SERVER
			application.serverType = '';
			if (StructKeyExists(application, "servers"))
			{
				for (i = 1; i le arrayLen(application.servers); i++)
				{
					if (application.servers[i].name eq CGI.SERVER_NAME AND findNoCase(application.servers[i].url, tempCurrentPage))
					{
						application.serverType = application.servers[i].type;
						application.serverName = application.serverType & "_" & application.servers[i].name;
						application.appNameSuffix = application.servers[i].appNameSuffix;
						application.rootURL = application.servers[i].url;
						application.rootPath = replace(application.rootURL, listFirst(application.rootURL, '/') & '//' & listGetAt(application.rootURL, 2, '/'), '');
						application.appLogicalPath = replace(application.rootURL, listFirst(application.rootURL, '/') & '//' & listGetAt(application.rootURL, 2, '/'), '');
						
						// Allow other configs to be overwritten per server
						if (StructKeyExists(application.servers[i], "specificSettings"))
						{
							for (k in application.servers[i].specificSettings)
							{
								application[k] = application.servers[i].specificSettings[k];
							}
						}
					}
				}
			}
			else
			{
				application.serverType = "";
			}
		</cfscript>
		
		<!--- Not found the server on the list? terminate the application. This should not happen
				unless the server settings are not included on the server list inside the application config.cfm file --->
		<cfif (application.serverType eq '')>
			<cfoutput><p style="color: ##f00;">INVALID SERVER. THE APPLICATION IS NOT ALLOWED TO RUN ON THIS SERVER. PLEASE DOUBLE CHECK YOUR SERVER SETTINGS.</p></cfoutput>
			<cfabort>
		</cfif>
		
		<!--- Include config files --->
		<cfif fileExists(expandPath("#application.appLogicalPath#/application/config/database.cfm"))>
			<cfinclude template="#application.appLogicalPath#/application/config/database.cfm">
		</cfif>
		<cfif fileExists(expandPath("#application.appLogicalPath#/application/config/route.cfm"))>
			<cfinclude template="#application.appLogicalPath#/application/config/route.cfm">
		</cfif>
		<cfif fileExists(expandPath("#application.appLogicalPath#/application/config/lang.cfm"))>
			<cfinclude template="#application.appLogicalPath#/application/config/lang.cfm">
		</cfif>
		<cfinclude template="/cft/config/config.cfm">
		
		<!--- Include language files --->
		<cfif NOT StructKeyExists(application, "language")>
			<cfset application.language = "en">
		</cfif>
		
		<cfif directoryExists(expandPath("/cft/lang/#lcase(application.language)#"))>
			<cfinclude template="/cft/lang/#lcase(application.language)#/validation.cfm">
			<cfinclude template="/cft/lang/#lcase(application.language)#/message.cfm">
		</cfif>
		
		<cfscript>
			application.onLiveServer = false;
			application.name = application.appName & "_" & application.appNameSuffix;
			
			// SPECIFIC SERVER SETTINGS
			switch(application.serverType) {
				case "LIVE":
					application.showFriendlyError = true;
					application.show404OnMissingController = true;
					application.applicationDBType = "live";
					application.alwaysRefreshSettings = false;
					application.onLiveServer = true;
					
					// Allow hideColdfusionError to be overwritten per application
					if (StructKeyExists(application, "hideColdfusionError"))
					{					
						application.hideColdfusionError = application.hideColdfusionError;
					}
					else
					{
						application.hideColdfusionError = true;
					}

					break;						
		
				case "DEV":
					// Allow showLocalFriendlyError to be overwritten per application
					if (StructKeyExists(application, "showLocalFriendlyError"))
					{					
						application.showFriendlyError = application.showLocalFriendlyError;
					}
					else
					{
						application.showFriendlyError = false;
					}

					// Allow show404OnMissingController to be overwritten per application
					if (NOT StructKeyExists(application, "show404OnMissingController"))
					{
						application.show404OnMissingController = false;
					}

					application.applicationDBType = "dev";
					application.alwaysRefreshSettings = true;
					break;
			}
			
			
			/* =========================================== APPLICATION SETTINGS =========================================== */
			
			// Get the application DB settings
			if (isDefined("databases"))
			{
				application.dbname = databases[application.applicationDBType]["dbname"];
				application.dbuser = databases[application.applicationDBType]["dbuser"];
				application.dbpassword = databases[application.applicationDBType]["dbpassword"];
			}
			else
			{
				application.dbname = "";
				application.dbuser = "";
				application.dbpassword = "";
			}
		</cfscript>
		
		<!--- Get database driver info --->	
		<cfset application.dbDriver = "">
		<cfset application.dbIsMSSQL = false>
		<cfset application.dbIsOracle = false>
		<cfset application.dbIsMySQL = false>
		<cfif application.dbname neq "">
			<cftry>
				<cfdbinfo type="version" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#" name="dbInfo">
				<cfset application.dbDriver = dbInfo.driver_name>
				<cfset application.dbIsMSSQL = findNoCase("SQLServer", application.dbDriver)>
				<cfset application.dbIsOracle = findNoCase("Oracle", application.dbDriver)>
				<cfset application.dbIsMySQL = findNoCase("MySQL", application.dbDriver)>
				
				<cfcatch type="any">
					<!--- Cannot get version from database? Don't worry, just move on --->
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfscript>
			// Get the separator & opposite separator
			application.separator = createObject("java", "java.io.File").separator;
			
			if (application.separator eq "/")
			{
				application.oppSeparator = "\";
			}
			else
			{
				application.oppSeparator = "/";
			}
		
			// Keep or remove the index.cfm page
			if (StructKeyExists(application, "removeIndexPage") AND application.removeIndexPage)
			{
				application.baseURL = application.rootURL;
			}
			else
			{
				application.baseURL = application.rootURL & "/index.cfm";
			}
			application.basePath = application.rootPath & "/index.cfm";
			application.FilePath = ReplaceNoCase(This.appComponentFilePath, application.separator & "Application.cfc", "") & application.separator;
			
			// Paths
			application.appPath = application.appLogicalPath & "/application";
			application.modelPath = application.appPath & "/models";
			application.viewPath = application.appPath & "/views";
			application.controllerPath = application.appPath & "/controllers";
			application.libraryPath = application.appPath & "/libraries";
			application.errorPath = application.appPath & "/errors";
			
			// File paths
			application.appFilePath = application.FilePath & "application" & application.separator;
			application.modelFilePath = application.appFilePath & "models" & application.separator;
			application.viewFilePath = application.appFilePath & "views" & application.separator;
			application.controllerFilePath = application.appFilePath & "controllers" & application.separator;
			application.libraryFilePath = application.appFilePath & "libraries" & application.separator;
			application.errorFilePath = application.appFilePath & "errors" & application.separator;
			application.configFilePath = application.appFilePath & "config" & application.separator;
		
			// Get coldfusion admin mappings for cft and makes sure the path ends with a / or \ --->
			mappings = this.getMappings();
			cftMapping = trim(mappings['/cft']);
			if (right(cftMapping, 1) neq application.separator)
			{
				cftMapping = cftMapping & application.separator;
			}
			
			// CFT file path
			application.CFT_libraryFilePath = cftMapping & "libraries" & application.separator;
			application.CFT_viewFilePath = cftMapping & "views" & application.separator;
			
			// Package paths (roots)
			application.modelRoot = Replace(Replace(application.appLogicalPath & "/application/models", "/", ""), "/", ".", "all");
			application.controllerRoot = Replace(Replace(application.appLogicalPath & "/application/controllers", "/", ""), "/", ".", "all");
			application.libraryRoot = Replace(Replace(application.appLogicalPath & "/application/libraries", "/", ""), "/", ".", "all");
			
			// Preload system library
			application.load = createObject("component", "cft.libraries.load");
			application.load.library("error", true);
			application.load.library("utils", true);
			application.load.library("url", true);
			application.load.library("image", true);
			application.load.library("file", true);
			application.load.library("directory", true);
			application.load.library("output", true);
			application.load.library("lang", true);
			application.load.library("authentication", true);
			application.load.library("core", true);
			application.load.library("debug", true);
			application.load.library("text", true);
			
			// Record that the application has started
			application.started = true;
		</cfscript>
		
		<!--- Autoload at application level? --->
		<cfif StructKeyExists(this, "autoload_application")>
			<cfset this.autoload_application()>
		</cfif>
		
	</cffunction>
	
	
	<!--- ================================ SESSION METHODS ================================= --->
	
	<cffunction name="OnSessionStart" output="false">	

	</cffunction>
	
	
	<cffunction name="OnSessionEnd" output="false">		
		<cfargument name="SessionScope" required="yes"/>
		<cfargument name="ApplicationScope" required="no"/>

	</cffunction>
	
	
	<!--- ================================ REQUEST METHODS ================================= --->

	<cffunction name="OnRequestStart">
		<cfargument name="targetPage" type="string" required="true">
		<cfset var getControllerViewResult = "">
		<cfset var vals = "">
		<cfset var vars = "">
		<cfset var i = "">
		<cfset var forwardURL = "">
		<cfset var isGuestController = "">
		<cfset var isAdminController = "">
		<cfset var requireAuthentication = "">
		<cfset var error404 = false>
		
		<!--- Include CFT variables --->
		<cfinclude template="/cft/config/variables.cfm">		
		
		<!--- Check to reset the application --->
		<cfif NOT StructKeyExists(application, "started") OR NOT application.started OR
			  StructKeyExists(url,"reset") OR application.alwaysRefreshSettings>
			<cfset OnApplicationStart()>
		</cfif>

		<!--- Ensure that user can only access the scripts that they are allowed to --->
		<cfset forwarded = findNoCase(replace(application.rootURL, "://", ":/") & "/", CGI.SCRIPT_NAME) ge 1>
		<cfset logicalScriptName = replaceNoCase(CGI.SCRIPT_NAME, application.appLogicalPath & "/", "", "ALL")>
		<cfif NOT forwarded AND NOT listFindNoCase(application.allowedScripts, logicalScriptName)>
			<cfset application.url.redirect()>
		</cfif>
	
		<!--- User logout? --->
		<cfif StructKeyExists(url,"logout")>
			<cfinvoke method="onSessionEnd" sessionScope="#session#">
			<cfset StructClear(session)>
			<cfset session.UserId = "">
			<cflogout>
			
			<cfset application.url.redirectMessage(application.guestDefaultController, application.lang.get("loggedOut"))>
		</cfif>
		
		<!--- Get the current page and the path info string --->
		<cfset request.currentPage = currentPage()>
		
		<!--- Get the form, url controller, view and other values from the path info string --->
		<cfset getControllerViewResult = getControllerAndView()>
		<cfset url.controller = getControllerViewResult.controller>
		<cfset form.controller = getControllerViewResult.controller>
		<cfset url.rootController = getControllerViewResult.rootController>
		<cfset form.rootController = getControllerViewResult.rootController>
		<cfset url.view = getControllerViewResult.view>
		<cfset form.view = getControllerViewResult.view>
		<cfif StructKeyExists(getControllerViewResult, "id")>
			<cfset url[url.rootController & "Id"] = getControllerViewResult.id>
			<cfset form[form.rootController & "Id"] = getControllerViewResult.id>
		</cfif>
		<cfif StructKeyExists(getControllerViewResult, "textId")>
			<cfset url[url.rootController & "TextId"] = getControllerViewResult.textId>
			<cfset form[form.rootController & "TextId"] = getControllerViewResult.textId>
		</cfif>
		
		<!--- Anything to route? --->
		<cfif StructKeyExists(application, "routes") AND StructKeyExists(application.routes, form.controller)>
			<cfset vals = ArrayNew(1)>
			<cfset vars = reMatch("{([^}]+)}", application.routes[form.controller])>
			
			<!--- Replace each variable with its value --->
			<cfloop from="1" to="#arrayLen(vars)#" index="i">
				<cftry>
					<cfset vals[i] = evaluate(replaceList(vars[i], "{,}", ""))>
					
					<cfcatch type="any">
						<cfset vals[i] = "">
					</cfcatch>
				</cftry>
			</cfloop>
			
			<!--- Get the final forward url --->
			<cfset forwardURL = application.basePath & "/" & replaceList(application.routes[form.controller], arrayToList(vars), arrayToList(vals))>
			
			<!--- Forward/route user to this url and stop --->
			<cfset getPageContext().forward(forwardURL)>
		<cfelse>
			<!--- Check if this is a guest controller --->
			<cfset isGuestController = form.controller eq "login" OR
									   (StructKeyExists(application, "adminLoginController") AND form.controller eq application.adminLoginController) OR
									   (StructKeyExists(application, "guestControllers") AND listFindNoCase(application.guestControllers, form.controller))>
										
			<!--- Check if this is an admin controller --->
			<cfset isAdminController = StructKeyExists(application, "adminControllerPattern") AND reFindNoCase(application.adminControllerPattern, form.controller)>
										
			<cfset requireAuthentication = StructKeyExists(application, "enableUserAuthentication") AND application.enableUserAuthentication>
			<cfif NOT isGuestController AND (requireAuthentication OR isAdminController)>
				<cfinvoke component="#application.authentication#" method="validate">
					<!--- Get the login controller --->
					<cfif isAdminController>
						<cfinvokeargument name="loginController" value="#application.adminLoginController#">
					</cfif>
				</cfinvoke>
				
				<!--- Passed the normal user authentication. Now go on authenticate as admin --->
				<cfif StructKeyExists(application, "adminAuthentication") AND application.adminAuthentication>
					<!--- Not admin login? --->
					<cfif NOT session.sysAdmin>
						<!--- Logout user --->
						<cfinvoke method="onSessionEnd" sessionScope="#session#">
						<cfset StructClear(session)>
						<cfset session.UserId = "">
						
						<cfset application.url.redirectError("login", application.lang.get("adminRequired"))>
					</cfif>
				</cfif>
			</cfif>
			
			<!--- Allow the application to dynamically refresh session when necessary --->
			<cfif StructKeyExists(this, "refreshSession")>
				<cfset this.refreshSession()>
			</cfif>
			
			<!--- Autoload at request level? --->
			<cfif StructKeyExists(this, "autoload_request")>
				<cfset this.autoload_request()>
			</cfif>
			
			
			<!---
				FIRST TRY: LOAD THE CONTROLLER AND THEN LOAD THE VIEW
			--->

			<!--- Found controller? --->
			<cfif getControllerViewResult.foundController>
				<!--- Found view? --->
				<cfif getControllerViewResult.foundView>
					<cfinvoke component="#getControllerViewResult.objController#" method="#form.view#" />
					<cfset this.onRequestEnd("")>
					<cfabort>
				<cfelse>
					<cfset errorHeading = "Method not found">
					<cfset errorMessage = "The system could not find the method '#form.view#' inside the controller '#form.controller#.cfc'">
					<cfset error404 = true>
				</cfif>
			<cfelse>
				<cfset errorHeading = "Controller not found">
				<cfset errorMessage = "The system could not find the controller '#form.controller#.cfc'">
				<cfset error404 = true>
			</cfif>
			
			
			<!---
				IF THE REQUEST REACHES HERE, WE KNOW THAT WE DIDN'T HAVE A MATCH FOR CONTROLLER & VIEW
				
				SECOND TRY: LOOK FOR A MATCH IN THE DIRECT VIEW TO SEE IF THERE IS ANY FOR THIS REQUEST
			--->
	
			<cfif StructKeyExists(application, "directView") AND trim(application.directView) neq "">
				<cfset directViewPath = replace(getPathInfoStr(), '/', '')>
				<cfif right(directViewPath, 1) eq "/">
					<cfset directViewPath = left(directViewPath, len(directViewPath) - 1)>
				</cfif>
				
				<cfif reFindNoCase(application.directView, directViewPath)>
					<!--- Validate this view --->
					<cfset validateResult = application.load.validateView(directViewPath)>
				
					<!--- Does the view exist? If yes, load it --->
					<cfif validateResult.exists>
						<cfset error404 = false>
						
						<cfset directData = StructNew()>
	
						<!--- Load the direct view variables --->
						<cfif StructKeyExists(application, "directViewVariables") AND
							  StructKeyExists(application.directViewVariables, directViewPath)>
							<cfloop collection="#application.directViewVariables[directViewPath]#" item="varName">
								<cfset directData[varName] = application.directViewVariables[directViewPath][varName]>
							</cfloop>
						</cfif>
						
						<cfset application.load.viewInTemplate(directViewPath, directData)>
					</cfif>
				</cfif>
			</cfif>
			
			
			<!---
				IF THE REQUEST REACHES HERE, THE DIRECT VIEW SEARCH FOUND NO MATCH
				AND THIS SHOULD BE A 404 ERROR. BUT STILL PUT THE CHECKING HERE JUST IN CASE ANYWAY
			--->
			
			<cfif error404>
				<!--- Show friendy error? --->
				<cfif application.showFriendlyError>
					<cfif application.show404OnMissingController>
						<cfset application.error.show_404()>
					<cfelse>
						<cfset application.error.show_error(errorHeading, errorMessage)>
					</cfif>
				<cfelse>
					<!--- Load the controller to throw error --->
					<cfinvoke component="#getControllerViewResult.objController#" method="#form.view#" />
				</cfif>
			</cfif>
		</cfif>
	</cffunction>


	<cffunction name="onRequestEnd" output="false">
		<cfargument name="targetPage" type="string" required="true">
		
		<!--- Clear flash variables --->
		<cfif StructKeyExists(session, "flash")>
			<cfset StructClear(session.flash)>
		</cfif>
		
	</cffunction>
	
			
	<!--- ================================ ERROR METHODS ================================= --->

	<!--- Handle exceptions --->
	<cffunction name="onError">
		<cfargument name="Exception" required="yes" />
		<cfargument name="EventName" type="string" required="yes" />
		<cfset var errorMsg = "">
		<cfset var errorMsgDetails = "">
		<cfset var appTitle = "">
		<cfset var css_td = "">
		<cfset var css_th = "">
		<cfset var css_minimized = "">
		<cfset var css_heading_th = "">
		<cfset var css_lineNumber = "">
		<cfset var css_mainErrorMsg = "">
		<cfset var  = "">
		<cfset var  = "">
		<cfset var  = "">
		<cfset var  = "">
		<cfset var  = "">
		
		<!--- Get the application title --->
		<cfif StructKeyExists(application, "title")>
			<cfset appTitle = application.title>
		<cfelse>
			<cfset appTitle = application.name>
		</cfif>
		
		<!--- Get error css styles --->
		<cfset css_td = "vertical-align: top;">
		<cfset css_th = "vertical-align: top; text-align: left;">
		<cfset css_minimized = "width: 1%; white-space: nowrap;">
		<cfset css_heading_th = "background: ##CFCFCF; color: ##000;">
		<cfset css_lineNumber = "display: block; width: 2.5em; font-size: 0.9em; float: left; text-align: right; font-family: 'Courier New'; background: ##eee; padding-right: 10px; margin-right: 10px;">
		<cfset css_mainErrorMsg = "font-size: 1.2em;">

		<!--- Get error message --->
		<cfif StructKeyExists(arguments.Exception, "cause")>
			<cfif StructKeyExists(arguments.Exception.cause, "message")>
				<cfset errorMsg = arguments.Exception.cause.message>
			</cfif>
		
			<cfif StructKeyExists(arguments.Exception.cause, "detail")>
				<cfset errorMsgDetails = arguments.Exception.cause.detail>
			</cfif>
		</cfif>
		
		<!--- Get stack trace --->
		<cfsavecontent variable="stackTrace">
			<cfoutput>
				<cfif ArrayLen(arguments.Exception.TagContext)>
					 The error occurred in <strong>#arguments.Exception.TagContext[1]["template"]#: line #arguments.Exception.TagContext[1]["line"]#</strong><br />
					<cfloop from="2" to="#ArrayLen(arguments.Exception.TagContext)#" index="i">
						<strong>Called from</strong> #arguments.Exception.TagContext[i]["template"]#: line #arguments.Exception.TagContext[i]["line"]#<br />
					</cfloop>
				<cfelse>
					No stack trace available
				</cfif>
			</cfoutput>
		</cfsavecontent>
		
		<!--- Get content of the file where the error occurs --->
		<cfset errorFilePath = arguments.Exception.TagContext[1]["template"]>
		<cfset errorLineNumber = arguments.Exception.TagContext[1]["line"]>
		<cffile action="read" file="#errorFilePath#" variable="errorContent">
		<cfset codeLines = listToArray(errorContent, "#chr(10)#")>
		
		<!--- Display code from this line --->
		<cfset codeFromLine = max(errorLineNumber - application.linesBeforeError, 1)>

		<!--- Display code up to this line --->
		<cfset codeToLine = min(codeFromLine + application.totalErrorLines - 1, arrayLen(codeLines))>
		
		<!--- Get code display --->
		<cfsavecontent variable="codeContent">
			<cfoutput>
				<cfloop from="#codeFromLine#" to="#codeToLine#" index="lineNumber">
					<cfset thisLine = '<span style="#css_lineNumber#">#lineNumber#</span>' & application.output.pre(codeLines[lineNumber])>
					
					<!--- The actual line that caused error? --->
					<cfif lineNumber eq errorLineNumber>
						<strong>#thisLine#</strong><br />
					<cfelse>
						#thisLine#<br />
					</cfif>
				</cfloop>
			</cfoutput>
		</cfsavecontent>
		
		<!--- Cosntruct the email content --->
		<cfsavecontent variable="emailContent">
			<cfoutput>
			<!--- ERROR DETAILS --->
			<p>An error has occurred in the <strong>#application.name#</strong> application.</p>
			
			<div id="errorMsg">
				<p style="#css_mainErrorMsg#"><strong>#errorMsg#</strong></p>
				<cfif trim(errorMsgDetails) neq ""><p>#errorMsgDetails#</p></cfif>
			</div>
			<p>#stackTrace#</p>
			<p>#trim(codeContent)#</p>
			
			<table id="errorTable">
			
			<!--- CLIENT DETAILS --->
			<tr class="heading">
				<th colspan="2" style="#css_th# #css_heading_th#">CLIENT:</th>
			</tr>
			<tr>
				<th style="#css_th# #css_minimized#">Page:</th>
				<td style="#css_td#"><cfif StructKeyExists(request, "currentPage")>#request.currentPage#</cfif></td>
			</tr>
			<tr>
				<th style="#css_th# #css_minimized#">Date/Time:</th>
				<td style="#css_td#">#DateFormat(now(), "d mmmm, yyyy")# #TimeFormat(now(), "h:mm tt")#</td>
			</tr>
			<tr>
				<th style="#css_th# #css_minimized#">IP address:</th>
				<td style="#css_td#">#CGI.REMOTE_ADDR#</td>
			</tr>
			<tr>
				<th style="#css_th# #css_minimized#">Browser:</th>
				<td style="#css_td#">#CGI.HTTP_USER_AGENT#</td>
			</tr>
			
			<!--- SCOPE VARIABLES DETAILS --->
			<tr class="heading">
				<th colspan="2" style="#css_th# #css_heading_th#">SCOPE VARIABLES:</th>
			</tr>
			<tr>
				<th style="#css_th# #css_minimized#">Form:</th>
				<td style="#css_td#"><cfdump var="#form#" label="Form"></td>
			</tr>
			<tr>
				<th style="#css_th# #css_minimized#">URL:</th>
				<td style="#css_td#"><cfdump var="#url#" label="URL"></td>
			</tr>
			<tr>
				<th style="#css_th# #css_minimized#">Session</th>
				<td style="#css_td#"><cfset application.debug.simpleSessionVariables()></td>
			</tr>
			<tr>
				<th style="#css_th# #css_minimized#">Application</th>
				<td style="#css_td#"><cfset application.debug.simpleAppVariables()></td>
			</tr>
			<tr>
				<th style="#css_th# #css_minimized#">CGI:</th>
				<td style="#css_td#"><cfdump var="#CGI#" label="CGI"></td>
			</tr>
			</table>
			</cfoutput>
		</cfsavecontent>
		
		<!--- Send error email to admin? --->
		<cfif StructKeyExists(application, "sendEmailOnError") AND application.sendEmailOnError>
			<cfmail from="#application.fromEmail#" to="#application.errorEmail#" subject="[#appTitle# Error] An error has occurred" type="html">
				#emailContent#
			</cfmail>
		</cfif>
		
		<!--- Display error message --->
		<cfif StructKeyExists(application, "hideColdfusionError") AND application.hideColdfusionError>
			<cfset application.error.show_production_error()>
		<cfelse>
			<cfthrow object="#arguments.exception#">
		</cfif>

	</cffunction>
	

	<!--- Handles errors when user goes to a non-existing coldfusion file --->
	<cffunction name="onMissingTemplate">
		<cfargument name="targetPage" type="string" required="yes" />
		<cfparam name="form.controller" default="">
		<cfparam name="form.view" default="">

		<cfset application.error.show_404()>
		
	</cffunction>
	
	
	<!--- ================================ OTHER METHODS ================================= --->

	<!--- Get the mappings from coldfusion admin --->
	<cffunction name="getMappings" access="public" returntype="struct" output="false">

		<cfset var mappings = StructNew()>

		<!--- Try the adobe coldfusion way --->
		<cfset ServiceFactory = createObject("java","coldfusion.server.ServiceFactory")>
		
		<!--- Is this Adobe coldfusion server? --->
		<cfif isDefined("ServiceFactory.runtimeService")>
			<cfset mappings = ServiceFactory.runtimeService.getMappings()>
		<cfelse>
			<!--- Get mappings in the Railo way --->
			<cfinclude template="railo/admin.cfm">

			<!--- Get mappings in the Railo way --->
			<cfset mappings = StructNew()>
			<cfloop query="qMappings">
				<cfset mappings[qMappings.virtual] = qMappings.strPhysical>
			</cfloop>
		</cfif>
		
		<cfreturn mappings>
		
	</cffunction>
	

	<!--- ================================ METHODS ABOUT PAGE URL, CONTROLLER, VIEW, ETC. ================================= --->

	<!--- Get the controller, view and other data from the pathinfo --->
	<cffunction name="getControllerAndView" access="private" returntype="struct" output="false">

		<cfset var fromDevComputer = "">
		<cfset var underMaintenaince = "">
		<cfset var pathInfoStr = "">
		<cfset var pathInfo = "">
		<cfset var pathInfoLength = "">
		<cfset var continueSearching = "">
		<cfset var counter = "">
		<cfset var path = "">
		<cfset var nextPath = "">
		<cfset var logicalPath = "">
		<cfset var controllerPath = "">
		<cfset var result = StructNew()>
		<cfset var controller = "">
		<cfset result.foundController = false>
		<cfset result.foundView = false>
		<cfset result.controller = "">
		<cfset result.rootController = "">
		<cfset result.view = "">
		<cfset result.objController = "">
		
		<!--- Is this a development computer? --->
		<cfset fromDevComputer = StructKeyExists(application, "devIPAddresses") AND
										 listFind(application.devIPAddresses, CGI.REMOTE_ADDR) gt 0>
		<cfset underMaintenaince = application.maintenanceMode AND NOT fromDevComputer>
		
		<!--- Maintenance mode on live server? Redirect user to the maintenance page --->
		<cfif application.serverType eq 'LIVE' AND underMaintenaince>
			<cfset result = validateControllerAndView(application.maintenancePage)>
		<cfelse>
			<!--- Get the path info string --->
			<cfset pathInfoStr = getPathInfoStr()>
					
			<!--- Root? Grab the default controller and view --->
			<cfif listLen(pathInfoStr, '/') eq 0>
				<cfset result = validateControllerAndView(application.defaultController)>
			<cfelse>
				<cfset continueSearching = true>
				<cfset counter = 1>
				
				<!--- Search through the path info string to extract the controller and view --->
				<cfloop condition="continueSearching AND counter le listLen(pathInfoStr, '/')">
					<cfset path = listAppend(path, listGetAt(pathInfoStr, counter, "/"), application.separator)>
		
					<!--- Get the next part of the path info string --->
					<cfif counter lt listLen(pathInfoStr, '/')>
						<cfset nextPath = listGetAt(pathInfoStr, counter + 1, "/")>
					<cfelse>
						<cfset nextPath = "">
					</cfif>
					
					<cfset controllerPath = lcase(application.controllerFilePath & path)>
					<cfset result = validateControllerAndView(replace(path, application.separator, "/", "ALL"), nextPath)>
					<cfset continueSearching = (NOT result.foundController) AND directoryExists(controllerPath)>
		
					<cfset counter = counter + 1>
				</cfloop>
				
				<!--- Not found the controller? --->
				<cfif NOT result.foundController>
					<!--- Is there a hidden controller that we always use? --->
					<cfif StructKeyExists(application, "hiddenController") AND trim(application.hiddenController) neq "">
						<cfset result = validateControllerAndView(application.hiddenController)>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		
		<cfset result.rootController = listLast(result.controller, "/")>
		
		<!--- Not maintenance mode and user attempts to visit the maintenance page on LIVE? Disable it --->
		<cfif application.serverType eq 'LIVE' AND NOT underMaintenaince
				AND result.controller eq application.maintenancePage>
			<cfset application.url.redirect()>
		</cfif>
		
		<!--- Found controller and view? Go on and extract other details --->
		<cfif result.foundController AND result.foundView>
			<!--- Remove controller --->
			<cfset pathInfoStr = application.core.trimChar(pathInfoStr, "/")>
			<cfset pathInfoStr = reReplaceNoCase(pathInfoStr, "^#result.controller#", "")>
			<cfset pathInfoStr = application.core.trimChar(pathInfoStr, "/")>
			
			<!--- Remove view --->
			<cfset pathInfoStr = reReplaceNoCase(pathInfoStr, "^#result.view#", "")>
			<cfset pathInfoStr = application.core.trimChar(pathInfoStr, "/")>

			<!--- Get the controller, view and resource id--->
			<cfset pathInfo = listToArray(pathInfoStr, "/")>
			<cfset pathInfoLength = arrayLen(pathInfo)>
			
			<cfif pathInfoLength ge 1>
				<!--- Number or text? --->
				<cfif isNumeric(pathInfo[1])>
					<!--- Number? => This is the id --->
					<cfset result.id = pathInfo[1]>
					<cfset result.textId = pathInfo[1]>
				<cfelse>
					<!--- Text? => This is the text id, eg. short title, short name, etc. --->
					<cfset result.id = 0>
					<cfset result.textId = pathInfo[1]>
				</cfif>
	
				<!--- Get the sub controller --->
				<cfif pathInfoLength ge 2>
					<cfset result.subController = pathInfo[2]>
					
					<!--- Get the sub Id value --->
					<cfif pathInfoLength ge 3>
						<!--- Number or text? --->
						<cfif isNumeric(pathInfo[3])>
							<!--- Number? => This is the id --->
							<cfset result.subId = pathInfo[3]>
							<cfset result.subTextId = "">
						<cfelse>
							<!--- Text? => This is the text id, eg. short title, short name, etc. --->
							<cfset result.subId = 0>
							<cfset result.subTextId = pathInfo[3]>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn result>

	</cffunction>


	<!--- Get the actual path info string --->
	<cffunction name="getPathInfoStr" access="private" returntype="string" output="false">
	
		<!--- At the root level address (just index.cfm), sometimes CGI.PATH_INFO returns the full path to the file
			instead of what is appended after the index.cfm. So we need to remove that before continuing --->
		<cfset var result = CGI.PATH_INFO>
		<cfif findNoCase("index.cfm", result)>
			<cfset result = reReplace(result, "[^.]*.cfm", "")>
		</cfif>
		
		<!--- Also at the root level, sometimes it returns the actual application logical path,
			so we need to remove this as well before continuing --->
		<cfif result eq application.appLogicalPath & "/">
			<cfset result = "">
		</cfif>

		<cfreturn result>
		
	</cffunction>


	<!--- Get the actual path info string --->
	<cffunction name="currentPage" access="private" returntype="string" output="false">
		<cfargument name="includeQueryString" type="boolean" default="true" hint="true: include the query string in the result">
	
		<cfset var result = application.baseURL & getPathInfoStr()>
		
		<cfif arguments.includeQueryString AND CGI.QUERY_STRING neq "">
			<cfset result = result & "?" & CGI.QUERY_STRING>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>


	<!--- Get and validate the controller and view --->
	<cffunction name="validateControllerAndView" displayname="validateControllerAndView" access="private" returntype="struct" hint="Get and validate the controller and view">

		<cfargument name="controller" type="string" required="yes" hint="The controller path to validate">
		<cfargument name="view" type="string" required="no" hint="The view to validate">
		<cfset var result = StructNew()>
		<cfset var logicalPath = "">
		<cfset var controllerPath = "">
		
		<!--- No view passed in? --->
		<cfif NOT StructKeyExists(arguments, "view") OR trim(arguments.view) eq "">
			<cfset arguments.view = application.defaultView>
		</cfif>
		
		<cfset result.controller = arguments.controller>
		<cfset result.view = arguments.view>
		<cfset result.foundController = false>
		<cfset result.foundView = false>
		<cfset result.objController = "">

		<cfset logicalPath = replace(arguments.controller, application.separator, "/", "ALL")>
		<cfset controllerPath = lcase(application.controllerFilePath & arguments.controller)>

		<!--- Does this controller exist? --->
		<cfif fileExists(controllerPath & ".cfc")>
			<cfset result.objController = application.load.controller(logicalPath)>
			<cfset result.foundController = true>

			<!--- Does the view exist? --->
			<cfif StructKeyExists(result.objController, result.view)>
				<cfset result.foundView = true>
			<cfelse>
				<!--- Does this controller have a default view? --->
				<cfif StructKeyExists(result.objController, "defaultView") AND trim(result.objController.defaultView) neq "">
					<cfset result.foundView = true>
					<cfset result.view = result.objController.defaultView>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn result>

	</cffunction>
	
	
</cfcomponent>