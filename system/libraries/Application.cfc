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
	
		<!--- Logical Paths --->
		<cfset application.appLogicalPath = This.rootFolder>
		<cfinclude template="#application.appLogicalPath#application/config/database.cfm">
		<cfinclude template="#application.appLogicalPath#application/config/route.cfm">
		<cfinclude template="#application.appLogicalPath#application/config/lang.cfm">
		<cfinclude template="/cft/config/config.cfm">
		<cfinclude template="/cft/config/lang.cfm">

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
					application.rootURL = application.servers[i].url;
					application.rootURLPath = replace(application.rootURL, listFirst(application.rootURL, '/') & '//' & listGetAt(application.rootURL, 2, '/'), '');
					
					// Allow other configs to be overwritten per server
					if (StructKeyExists(application.servers[i], "enableUserAuthentication"))
					{
						application.enableUserAuthentication = application.servers[i].enableUserAuthentication;
					}
					
					if (StructKeyExists(application.servers[i], "adminAuthentication"))
					{
						application.adminAuthentication = application.servers[i].adminAuthentication;
					}
				}
			}
		</cfscript>
		
		<!--- Not found the server on the list? terminate the application. This should not happen
				unless the server settings are not included on the server list inside the application config.cfm file --->
		<cfif (application.serverType eq '')>
			<cfoutput>INVALID SERVER. THE APPLICATION IS NOT ALLOWED TO RUN ON THIS SERVER</cfoutput>
			<cfabort>
		</cfif>
		
		<cfscript>
			application.onLiveServer = false;
		
			// SPECIFIC SERVER SETTINGS
			switch(application.serverType) {
				case "LIVE":
					application.name = application.appName;
					application.showFriendlyError = true;
					application.show404OnMissingController = true;
					application.applicationDBType = "live";
					application.alwaysRefreshSettings = false;
					application.onLiveServer = true;
					break;						
		
				case "STAGING":
					application.name = application.appName & " (staging)";
					application.showFriendlyError = true;
					application.show404OnMissingController = true;
					application.applicationDBType = "staging";
					application.alwaysRefreshSettings = false;
					break;						
		
				case "DEV":
					application.name = application.appName & " (dev)";
					
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
			application.dbname = databases[application.applicationDBType]["dbname"];
			application.dbuser = databases[application.applicationDBType]["dbuser"];
			application.dbpassword = databases[application.applicationDBType]["dbpassword"];
			
			application.separator = createObject("java", "java.io.File").separator;
			application.baseURL = application.rootURL & "/index.cfm";
			application.baseURLPath = application.rootURLPath & "/index.cfm";
			application.FilePath = ReplaceNoCase(This.appComponentFilePath, application.separator & "Application.cfc", "") & application.separator;
			appFile = replace(replace(This.rootFolder, "/", application.separator, "ALL") & "Application.cfc", application.separator, "");
			
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
		
			//Get coldfusion admin mappings for cft and makes sure the path ends with a / or \ --->
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
			
			<cfset application.url.redirectMessage(application.guestDefaultController, "You have been logged out")>
		</cfif>
		
		<!--- Get the current page and the path info string --->
		<cfset request.currentPage = application.url.currentPage()>
		
		<!--- Get the form, url controller, view and other values from the path info string --->
		<cfset pathInfoStr = application.url.getPathInfoStr()>		
		<cfset getVarsResult = application.url.getPathInfoVariables()>
		<cfset url.controller = getVarsResult.controller>
		<cfset form.controller = getVarsResult.controller>
		<cfset url.view = getVarsResult.view>
		<cfset form.view = getVarsResult.view>
		<cfif StructKeyExists(getVarsResult, "id")>
			<cfset url[controller & "Id"] = getVarsResult.id>
			<cfset form[controller & "Id"] = getVarsResult.id>
		</cfif>
		<cfif StructKeyExists(getVarsResult, "textId")>
			<cfset url[controller & "TextId"] = getVarsResult.textId>
			<cfset form[controller & "TextId"] = getVarsResult.textId>
		</cfif>

		<!--- Check if user is authenticated and allowed to use the system --->
		<cfset isGuestController = form.controller eq "login" OR
								   (StructKeyExists(application, "guestControllers") AND
								   	listFindNoCase(application.guestControllers, form.controller))>
		<cfset hasAuthentication = StructKeyExists(application, "enableUserAuthentication") AND application.enableUserAuthentication>
		<cfif NOT isGuestController AND hasAuthentication>
			<cfset application.authentication.validate()>
			
			<!--- Passed the normal user authentication. Now go on authenticate as admin --->
			<cfif StructKeyExists(application, "adminAuthentication") AND application.adminAuthentication>
				<!--- Not admin login? --->
				<cfif NOT session.sysAdmin>
					<!--- Logout user --->
					<cfinvoke method="onSessionEnd" sessionScope="#session#">
					<cfset StructClear(session)>
					<cfset session.UserId = "">
					
					<cfset application.url.redirectError("login", "You are not allowed to access this area")>
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
	</cffunction>


	<cffunction name="onRequestEnd">
		<cfargument name="targetPage" type="string" required="true">
		
		<!--- Clear flash variables --->
		<cfif StructKeyExists(session, "flash")>
			<cfset StructClear(session.flash)>
		</cfif>
		
	</cffunction>
	
			
	<!--- ================================ OTHER METHODS ================================= --->

	<!--- Get the application server-specific name --->
	<cffunction name="getAppNameOnServer" displayname="getAppNameOnServer" output="no" hint="Get the application server-specific name">
		<cfargument name="genericName" type="string" required="yes" hint="The generic name of the application">
		<cfargument name="liveServer" type="string" required="yes" hint="The live server of the application">
		<cfargument name="devServer" type="string" required="yes" hint="The development server of the application">
		<cfset var result = "">
		
		<!--- What server? --->
		<cfif findNoCase(arguments.liveServer, CGI.SERVER_NAME)>
			<cfset result = arguments.genericName & "Live">
		<cfelse>
			<cfset result = arguments.genericName & "Dev">
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Handle exceptions --->
	<!--- <cffunction name="onError">
		<cfargument name="Exception" required="yes" />
		<cfargument name="EventName" type="string" required="yes" />
		
		<cfif application.showFriendlyError>
			<cfif application.serverType eq "LIVE">
				<cfset application.error.show_production_error()>
			<cfelse>
				<cfset application.error.show_error("Coldfusion Error", arguments.Exception.cause.message)>
			</cfif>
		<cfelse>
			<cfthrow object="#arguments.exception#">
		</cfif>

	</cffunction> --->
	

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