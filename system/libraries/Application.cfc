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
		This.sessiontimeout = createtimespan(0,2,0,0);
		This.loginstorage = "session";
		This.FI_Folder = "cftrigger/system";
		This.scriptProtect = "none";
	</cfscript>

	<!--- ================================ APPLICATION METHODS ================================= --->

	<cffunction name="OnApplicationStart">
		<cfset setLocale("English (Australian)")>
	
		<!--- Logical Paths --->
		<cfset application.appLogicalPath = This.rootFolder>
		<cfset application.FI_LogicalPath = "/" & This.FI_Folder>
		<cfinclude template="#application.appLogicalPath#application/config/database.cfm">
		<cfinclude template="#application.appLogicalPath#application/config/route.cfm">
		<cfinclude template="#application.appLogicalPath#application/config/lang.cfm">
		<cfinclude template="#application.FI_LogicalPath#/config/config.cfm">
		<cfinclude template="#application.FI_LogicalPath#/config/variables.cfm">
		<cfinclude template="#application.FI_LogicalPath#/config/lang.cfm">
		
		<cfscript>
			/* =========================================== SERVER SETTINGS =========================================== */
		
			// GET CURRENT SERVER
			if (findNoCase(application.liveServer, CGI.SERVER_NAME))
			{
				application.serverType = "LIVE";
			}
			else
			{
				application.serverType = "DEV";	
			}
			
			
			// SPECIFIC SERVER SETTINGS
			switch(application.serverType) {
				case "LIVE":
					application.name = application.appName;
					application.showFriendlyError = true;
					application.show404OnMissingController = true;
					application.applicationDBType = "live";
					application.userDBType = "live";
					application.alwaysRefreshSettings = false;
					application.rootURL = application.liveURL;
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
					application.userDBType = "dev";
					application.alwaysRefreshSettings = true;
					application.rootURL = application.devURL;
					break;
			}
			
			
			/* =========================================== APPLICATION SETTINGS =========================================== */
			
			// Get the application DB settings
			application.dbname = databases[application.applicationDBType]["dbname"];
			application.dbuser = databases[application.applicationDBType]["dbuser"];
			application.dbpassword = databases[application.applicationDBType]["dbpassword"];
			
			application.separator = createObject("java", "java.io.File").separator;
			application.BaseURL = application.rootURL & "/index.cfm";
			application.FilePath = ReplaceNoCase(This.appComponentFilePath, application.separator & "Application.cfc", "") & application.separator;
			/*if (This.rootFolder eq "")
			{
				appFile = "Application.cfc";
			}
			else
			{
				appFile = replace(This.rootFolder, "/", application.separator, "ALL") & application.separator & "Application.cfc";
			}*/
			appFile = replace(replace(This.rootFolder, "/", application.separator, "ALL") & "Application.cfc", application.separator, "");
			application.FI_FilePath = ReplaceNoCase(This.appComponentFilePath, appFile, replace(This.FI_Folder, "/", application.separator, "ALL")) & application.separator;
			
			application.FI_ErrorPath = application.FI_LogicalPath & "/errors";
			
			
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
			application.FI_LibraryFilePath = application.FI_FilePath & "libraries" & application.separator;
			
			// Package paths (roots)
			application.modelRoot = Replace(Replace(application.appLogicalPath & "application/models", "/", ""), "/", ".", "all");
			application.controllerRoot = Replace(Replace(application.appLogicalPath & "application/controllers", "/", ""), "/", ".", "all");
			application.libraryRoot = Replace(Replace(application.appLogicalPath & "application/libraries", "/", ""), "/", ".", "all");
			application.FI_LibraryRoot = Replace(This.FI_Folder, "/", ".", "ALL") & ".libraries";
			
			// System library
			application.load = createObject("component", "#application.FI_LibraryRoot#.load");
			application.load.library("error", true);
			application.load.library("utils", true);
			application.load.library("url", true);
			application.load.library("image", true);
			application.load.library("file", true);
			application.load.library("output", true);
			application.load.library("lang", true);
			application.load.library("authentication", true);
			application.load.library("core", true);
		</cfscript>
		
		<!--- Preload? --->
		<cfif isDefined("this.preload")>
			<cfset this.preload()>
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
		<cfargument name="targetPage" required="true">
		
		<!--- Include FI variables --->
		<cfinclude template="/#This.FI_Folder#/config/variables.cfm">		
		
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
		
		<!--- Include application variables --->
		<cfinclude template="#application.appLogicalPath#application/config/variables.cfm">
		
		<!--- Get the current page --->
		<cfset request.currentPage = application.url.currentPage()>
		
		<!--- Get the form, url controller and view values --->
		<cfset pathInfoStr = application.url.getPathInfoStr()>		
		<cfset vars = application.url.getPathInfoVariables()>
		<cfloop collection="#vars#" item="item">
			<cfset url[item] = vars[item]>
			<cfset form[item] = vars[item]>
		</cfloop>
		
		<!--- User logout --->
		<cfif StructKeyExists(url,"logout")>
			<cfinvoke method="onSessionEnd" sessionScope="#session#">
			<cfset StructClear(session)>
			<cfset session.UserId = "">
			
			<cfset application.url.redirectMessage(application.guestDefaultController, "You have been logged out")>
		</cfif>
		
		<!--- Check if user is authenticated and allowed to use the system --->
		<cfif form.controller neq "login" AND application.enableUserAuthentication>
			<cfinvoke component="#application.authentication#" method="validate">
		</cfif>
		
		<!--- Allow the application to dynamically refresh session when necessary --->
		<cfif isDefined("this.refreshSession")>
			<cfset this.refreshSession()>
		</cfif>
		
		<!--- Load the controller --->
		<cfset controller = application.load.controller(form.controller)>
		
		<!--- Load the view --->
		<cfif StructKeyExists(controller, form.view)>
			<cfinvoke component="#controller#" method="#form.view#" />
		<cfelse>
			<!--- Show friendy error? --->
			<cfif application.showFriendlyError>
				<cfif application.show404OnMissingController>
					<cfset application.error.show_404()>
				<cfelse>
					<cfset application.error.show_error("Method not found", "The system could not find the method '#form.view#' inside the controller '#form.controller#.cfc'")>
				</cfif>
			<cfelse>
				<!--- Load the controller to throw error --->
				<cfset controller = CreateObject("component", application.controllerRoot & "." & logicalPath)>
			</cfif>
		</cfif>
	</cffunction>


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
	

</cfcomponent>