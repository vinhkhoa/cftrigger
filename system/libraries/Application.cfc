<!---
	Project:		cfTrigger
	Company:		cfTrigger
	Summary:		Main Controller class
	
	Log:
	
	Created:		05/06/2009
	
	Modified:
	- 

--->

<cfcomponent displayname="Application">
	<cfsetting enablecfoutputonly="yes">

	<cfscript>
		// GENERAL SETTINGS
		This.Sessionmanagement = "True";
		This.loginstorage = "session";
		This.scriptProtect = "none";
	</cfscript>
	

	<!--- ================================ APPLICATION METHODS ================================= --->

	<cffunction name="OnApplicationStart">
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
			for (i = 1; i le arrayLen(application.servers); i++)
			{
				if (application.servers[i].name eq CGI.SERVER_NAME AND findNoCase(application.servers[i].url, tempCurrentPage))
				{
					application.serverType = application.servers[i].type;
					application.serverName = application.serverType & "_" & application.servers[i].name;
					application.appNameSuffix = application.servers[i].appNameSuffix;
					application.rootURL = application.servers[i].url;
					application.rootURLPath = replace(application.rootURL, listFirst(application.rootURL, '/') & '//' & listGetAt(application.rootURL, 2, '/'), '');
					application.appLogicalPath = replace(application.rootURL, listFirst(application.rootURL, '/') & '//' & listGetAt(application.rootURL, 2, '/'), '') & '/';
					
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
		</cfscript>
		
		<!--- Not found the server on the list? terminate the application. This should not happen
				unless the server settings are not included on the server list inside the application config.cfm file --->
		<cfif (application.serverType eq '')>
			<cfoutput>INVALID SERVER. THE APPLICATION IS NOT ALLOWED TO RUN ON THIS SERVER. PLEASE DOUBLE CHECK YOUR SERVER SETTINGS.</cfoutput>
			<cfabort>
		</cfif>
		
		<!--- Include config files --->
		<cfif fileExists(expandPath("#application.appLogicalPath#application/config/database.cfm"))>
			<cfinclude template="#application.appLogicalPath#application/config/database.cfm">
		</cfif>
		<cfif fileExists(expandPath("#application.appLogicalPath#application/config/route.cfm"))>
			<cfinclude template="#application.appLogicalPath#application/config/route.cfm">
		</cfif>
		<cfif fileExists(expandPath("#application.appLogicalPath#application/config/lang.cfm"))>
			<cfinclude template="#application.appLogicalPath#application/config/lang.cfm">
		</cfif>
		<cfinclude template="/cft/config/config.cfm">
		<cfinclude template="/cft/config/lang.cfm">
		
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
		
				case "STAGING":
					application.showFriendlyError = true;
					application.show404OnMissingController = true;
					application.applicationDBType = "staging";
					application.alwaysRefreshSettings = false;
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
					if (StructKeyExists(application, "show404OnMissingController"))
					{					
						application.show404OnMissingController = application.show404OnMissingController;
					}
					else
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
					<!--- Cannot get version from database? Don't worry, keep move on --->
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
			application.baseURLPath = application.rootURLPath & "/index.cfm";
			application.FilePath = ReplaceNoCase(This.appComponentFilePath, application.separator & "Application.cfc", "") & application.separator;
			appFile = replace(replace(application.appLogicalPath, "/", application.separator, "ALL") & "Application.cfc", application.separator, "");
			
			// Paths
			application.appPath = application.appLogicalPath & "application";
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
		
			// Get coldfusion admin mappings for cft and makes sure the path ends with a / or \ --->
			mappings = this.getMappings();
			cftMapping = trim(mappings['/cft']);
			if (right(cftMapping, 1) neq application.separator)
			{
				cftMapping = cftMapping & application.separator;
			}
			
			// CFT file path
			application.CFT_LibraryFilePath = cftMapping & "libraries" & application.separator;
			
			// Package paths (roots)
			application.modelRoot = Replace(Replace(application.appLogicalPath & "application/models", "/", ""), "/", ".", "all");
			application.controllerRoot = Replace(Replace(application.appLogicalPath & "application/controllers", "/", ""), "/", ".", "all");
			application.libraryRoot = Replace(Replace(application.appLogicalPath & "application/libraries", "/", ""), "/", ".", "all");
			
			// System library
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
		</cfscript>
		
		<!--- Autoload at application level? --->
		<cfif isDefined("this.autoload_application")>
			<cfset this.autoload_application()>
		</cfif>
		
	</cffunction>
	
	
	<!--- ================================ SESSION METHODS ================================= --->
	
	<cffunction name="OnSessionStart">	

	</cffunction>
	
	
	<cffunction name="OnSessionEnd">		
		<cfargument name="SessionScope" required="yes"/>
		<cfargument name="ApplicationScope" required="no"/>

	</cffunction>
	
	
	<!--- ================================ REQUEST METHODS ================================= --->

	<cffunction name="OnRequestStart">
		<cfargument name="targetPage" type="string" required="true">
		
		<!--- Include FI variables --->
		<cfinclude template="/cft/config/variables.cfm">		
		
		<cfset doReset = StructKeyExists(url,"reset") OR NOT StructKeyExists(application, "alwaysRefreshSettings")>
		
		<!--- Reset the application --->
		<cfif doReset OR application.alwaysRefreshSettings>
			<cfset OnApplicationStart()>

			<!--- Also refresh the session --->
			<cfif application.refreshWhenReset>
				<cfset url.refresh = true>
			</cfif>
		</cfif>

		<!--- Ensure that user can only access the scripts that they are allowed to --->
		<cfset forwarded = findNoCase(replace(application.rootURL, "://", ":/") & "/", CGI.SCRIPT_NAME) ge 1>
		<cfset logicalScriptName = replaceNoCase(CGI.SCRIPT_NAME, application.appLogicalPath, "", "ALL")>
		<cfif NOT forwarded AND NOT listFindNoCase(application.allowedScripts, logicalScriptName)>
			<cfset application.url.redirect()>
		</cfif>
	
		<!--- User logout --->
		<cfif StructKeyExists(url,"logout")>
			<cfinvoke method="onSessionEnd" sessionScope="#session#">
			<cfset StructClear(session)>
			<cfset session.UserId = "">
			<cflogout>
			
			<cfset application.url.redirectMessage(application.guestDefaultController, application.lang.get("loggedOut"))>
		</cfif>
		
		<!--- Get the current page and the path info string --->
		<cfset request.currentPage = application.url.currentPage()>
		
		<!--- Get the form, url controller, view and other values from the path info string --->
		<cfset pathInfoStr = application.url.getPathInfoStr()>		
		<cfset getVarsResult = application.url.getPathInfoVariables()>
		<cfset url.controller = getVarsResult.controller>
		<cfset form.controller = getVarsResult.controller>
		<cfset url.rootController = getVarsResult.rootController>
		<cfset form.rootController = getVarsResult.rootController>
		<cfset url.view = getVarsResult.view>
		<cfset form.view = getVarsResult.view>
		<cfif StructKeyExists(getVarsResult, "id")>
			<cfset url[url.rootController & "Id"] = getVarsResult.id>
			<cfset form[form.rootController & "Id"] = getVarsResult.id>
		</cfif>
		<cfif StructKeyExists(getVarsResult, "textId")>
			<cfset url[url.rootController & "TextId"] = getVarsResult.textId>
			<cfset form[form.rootController & "TextId"] = getVarsResult.textId>
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
			<cfset forwardURL = application.baseURLPath & "/" & replaceList(application.routes[form.controller], arrayToList(vars), arrayToList(vals))>
			
			<!--- Forward/route user to this url and stop --->
			<cfset getPageContext().forward(forwardURL)>
		<cfelse>
			<!--- Check if this is a guest controller --->
			<cfset isGuestController = form.controller eq "login" OR
									   (StructKeyExists(application, "adminLoginController") AND form.controller eq application.adminLoginController) OR
									   (StructKeyExists(application, "guestControllers") AND listFindNoCase(application.guestControllers, form.controller))>
										
			<!--- Check if this is an admin controller --->
			<cfset isAdminController = StructKeyExists(application, "adminControllerPattern") AND reFindNoCase(application.adminControllerPattern, form.controller)>
										
			<cfset hasAuthentication = StructKeyExists(application, "enableUserAuthentication") AND application.enableUserAuthentication>
			<cfif NOT isGuestController AND (hasAuthentication OR isAdminController)>
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
			<cfif isDefined("this.refreshSession")>
				<cfset this.refreshSession()>
			</cfif>
			
			<!--- Autoload at request level? --->
			<cfif isDefined("this.autoload_request")>
				<cfset this.autoload_request()>
			</cfif>
			
			<cfset error404 = false>
			
			
			<!---
				FIRST TRY: LOAD THE CONTROLLER AND THEN LOAD THE VIEW
			--->
			
			<cfif getVarsResult.foundController>
				<cfset controller = application.load.controller(form.controller)>
				
				<!--- Not found view in controller? Check if the controller has default view specified --->
				<cfif NOT StructKeyExists(controller, form.view) AND controller.defaultView neq ""
					  AND StructKeyExists(controller, controller.defaultView)>
					<!--- We now call the default view/function and set the current view to be the id/textId --->
					<cfset url[form.controller & "Id"] = val(form.view)>
					<cfset form[form.controller & "Id"] = val(form.view)>
					<cfset url[form.controller & "TextId"] = form.view>
					<cfset form[form.controller & "TextId"] = form.view>				
					<cfset form.view = controller.defaultView>
				</cfif>
				
				<!--- Load the view --->
				<cfif StructKeyExists(controller, form.view)>
					<cfinvoke component="#controller#" method="#form.view#" />
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
				<cfset directViewPath = replace(pathInfoStr, '/', '')>
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
					<cfinvoke component="#controller#" method="#form.view#" />
				</cfif>
			</cfif>
		</cfif>
	</cffunction>


	<cffunction name="onRequestEnd">
		<cfargument name="targetPage" type="string" required="true">
		
		<!--- Clear flash variables --->
		<cfif StructKeyExists(session, "flash")>
			<cfset StructClear(session.flash)>
		</cfif>
		
	</cffunction>
	
			
	<!--- ================================ OTHER METHODS ================================= --->

	<!--- Handle exceptions --->
	<cffunction name="onError">
		<cfargument name="Exception" required="yes" />
		<cfargument name="EventName" type="string" required="yes" />
		
		<!--- Get the application title --->
		<cfif StructKeyExists(application, "title")>
			<cfset appTitle = application.title>
		<cfelse>
			<cfset appTitle = application.name>
		</cfif>
		
		<!--- Get error message --->
		<cfset errorMsg = arguments.Exception.cause.message>
		<cfset errorMsgDetails = arguments.Exception.cause.detail>
		
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
					<cfset thisLine = '<span class="lineNumber">#lineNumber#</span>' & application.output.pre(codeLines[lineNumber])>
					
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
			<!--- ERROR STYLES --->
			<style>
				##errorTable td
				{
					vertical-align: top;
				}
				##errorTable th
				{
					vertical-align: top;
					text-align: left;
				}
				##errorTable .minimized
				{
					width: 1%;
					white-space: nowrap;
				}
				
				.heading th
				{
					background: ##CFCFCF;
					color: ##000;
				}
				
				.lineNumber
				{
					display: block;
					width: 2.5em;
					font-size: 0.9em;
					float: left;
					text-align: right;
					font-family: "Courier New", Courier, monospace;
					background: ##eee;
				}
				
				##mainErrorMsg
				{
					font-size: 1.2em;
				}
			</style>
			
			<!--- ERROR DETAILS --->
			<p>An error has occurred in the <strong>#application.name#</strong> application.</p>
			
			<div id="errorMsg">
				<p id="mainErrorMsg"><strong>#errorMsg#</strong></p>
				<cfif trim(errorMsgDetails) neq ""><p>#errorMsgDetails#</p></cfif>
			</div>
			<p>#stackTrace#</p>
			<p>#trim(codeContent)#</p>
			
			<table id="errorTable">
			
			<!--- CLIENT DETAILS --->
			<tr class="heading">
				<th colspan="2">CLIENT:</th>
			</tr>
			<tr>
				<th class="minimized">Page:</th>
				<td>#request.currentPage#</td>
			</tr>
			<tr>
				<th class="minimized">Date/Time:</th>
				<td>#DateFormat(now(), "d mmmm, yyyy")# #TimeFormat(now(), "h:mm tt")#</td>
			</tr>
			<tr>
				<th class="minimized">IP address:</th>
				<td>#CGI.REMOTE_ADDR#</td>
			</tr>
			<tr>
				<th class="minimized">Browser:</th>
				<td>#CGI.HTTP_USER_AGENT#</td>
			</tr>
			
			<!--- SCOPE VARIABLES DETAILS --->
			<tr class="heading">
				<th colspan="2">SCOPE VARIABLES:</th>
			</tr>
			<tr>
				<th class="minimized">Form:</th>
				<td><cfdump var="#form#" label="Form"></td>
			</tr>
			<tr>
				<th class="minimized">URL:</th>
				<td><cfdump var="#url#" label="URL"></td>
			</tr>
			<tr>
				<th class="minimized">Session</th>
				<td><cfset application.debug.simpleSessionVariables()></td>
			</tr>
			<tr>
				<th class="minimized">Application</th>
				<td><cfset application.debug.simpleAppVariables()></td>
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
			<!--- <cfif application.showFriendlyError>
				<cfset application.error.show_error("Coldfusion Error", arguments.Exception.cause.message)>
			<cfelse>
				<cfthrow object="#arguments.exception#">
			</cfif> --->
			
			<cfthrow object="#arguments.exception#">
		</cfif>

	</cffunction>
	

	<!--- Get the mappings from coldfusion admin --->
	<cffunction name="getMappings" access="public" returntype="struct">

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
	
</cfcomponent>