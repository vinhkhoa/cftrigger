<!---
	Project:	cfTrigger
	Summary:	System url library, used to handle functions related to urls
	
	Log:
	
		Created:		05/08/2009		
		Modified:

--->

<cfcomponent displayname="Url" hint="Handles user funtions" output="false">

	<cfsetting enablecfoutputonly="yes">
	

	<!--- Redirect the page with a message --->
	<cffunction name="redirectMessage" access="public" output="false">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="message" type="string" required="yes" hint="The message to be displayed">
	
		<cfset session.message = arguments.message>
		<cfset variables.redirect(arguments.location)>
	
	</cffunction>


	<!--- Redirect the page with an error --->
	<cffunction name="redirectError" access="public" output="false">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="error" type="string" required="yes" hint="The error to be displayed">
		
		<cfset session.error = arguments.error>
		<cfset variables.redirect(arguments.location)>
	
	</cffunction>
	
	
	<!--- Redirect the page with a list of error --->
	<cffunction name="redirectErrorList" access="public" output="false">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="errorList" type="array" required="yes" hint="The error list to be displayed">
	
		<cfset session.errorList = arguments.errorList>
		<cfset variables.redirect(arguments.location)>
	
	</cffunction>
	
	
	<!--- Redirect user to a page --->
	<cffunction name="redirect" access="public" output="false">

		<cfargument name="location" type="string" required="no" default="" hint="The location to redirect to">
		<cfset var finalLocation = "">
		
		<!--- Remove multi-slash and ending index.cfm to make the url looks nicer --->
		<cfif isValid("url", arguments.location)>
			<cfset finalLocation = arguments.location>
		<cfelse>
			<cfset finalLocation = reReplace(reReplace("#application.baseURL#/#arguments.location#", "([^:])/{2,}", "\1/", "ALL"), "index.cfm/$", "")>
		</cfif>
		
		<cflocation url="#finalLocation#" addtoken="no">
		
	</cffunction>
	

	<!--- Redirect user to a page --->
	<cffunction name="redirectBack" access="public" output="false">

		<cfargument name="message" type="string" required="no" hint="The message to be displayed">
		<cfargument name="error" type="string" required="no" hint="The error to be displayed">
		<cfset var backURL = "">
		
		<cfif StructKeyExists(arguments, "message")>
			<cfset session.message = arguments.message>
		</cfif>
		
		<cfif StructKeyExists(arguments, "error")>
			<cfset session.error = arguments.error>
		</cfif>
		
		<!--- Is there a specific page set for redirecting page? --->
		<cfif StructKeyExists(session, "redirectBackURL") AND session.redirectBackURL neq "">
			<cfset backURL = session.redirectBackURL>
			<cfset session.redirectBackURL = "">
		<cfelse>
			<!--- User comes here form another page? --->
			<cfif trim(CGI.HTTP_REFERER) neq "">
				<cfset backURL = CGI.HTTP_REFERER>
			<cfelse>
				<cfset backURL = "#application.rootURL#/">
			</cfif>
		</cfif>
		
		<cflocation url="#backURL#" addtoken="no">
		
	</cffunction>
	

	<!--- Get variables out of page path info --->
	<cffunction name="getPathInfoVariables" access="public" returntype="struct" output="false">

		<cfset var result = StructNew()>
		<cfset var fromDevComputer = "">
		<cfset var underMaintenaince = "">
		<cfset var pathInfoStr = "">
		<cfset var continueSearching = "">
		<cfset var counter = "">
		<cfset var path = "">
		<cfset var nextPath = "">
		<cfset var logicalPath = "">
		<cfset var controllerPath = "">
		<cfset var pathInfo = "">
		<cfset var pathInfoLength = "">
		<cfset var arrPathInfo = "">
		<cfset var totalPathInfo = "">
		<cfset result.foundController = false>
		<cfset result.controller = "">
		<cfset result.rootController = "">
		<cfset result.view = "">
		
		<!--- Is this a development computer? --->
		<cfset fromDevComputer = StructKeyExists(application, "devIPAddresses") AND
										 listFind(application.devIPAddresses, CGI.REMOTE_ADDR) gt 0>
		<cfset underMaintenaince = application.maintenanceMode AND NOT fromDevComputer>
		
		<!--- Maintenance mode? Redirect user to the maintenance page on LIVE except for the development computers --->
		<cfif application.serverType eq 'LIVE' AND underMaintenaince>
			<cfset result.foundController = true>
			<cfset result.controller = application.maintenancePage>
			<cfset result.view = application.defaultView>
			<cfset result.rootController = listLast(result.controller, "/")>
			<cfreturn result>
		</cfif>
		
		<cfset pathInfoStr = variables.getPathInfoStr()>
		<cfset continueSearching = true>
		<cfset counter = 1>
				
		<!--- Root? Load the default controller --->
		<cfif listLen(pathInfoStr, '/') eq 0>
			<cfset pathInfoStr = "/" & application.defaultController>
		</cfif>
		
		<!--- Search through the path info string to extract the controller and view --->
		<cfloop condition="continueSearching AND counter le listLen(pathInfoStr, '/')">
			<cfset path = listAppend(path, listGetAt(pathInfoStr, counter, "/"), application.separator)>

			<!--- Get the next part of the path info string --->
			<cfif counter lt listLen(pathInfoStr, '/')>
				<cfset nextPath = listGetAt(pathInfoStr, counter + 1, "/")>
			<cfelse>
				<cfset nextPath = application.defaultView>
			</cfif>
			
			<cfset logicalPath = replace(path, application.separator, ".", "ALL")>
			<cfset result.controller = replace(path, application.separator, "/", "ALL")>
			<cfset controllerPath = lcase(application.controllerFilePath & path)>

			<!--- Found controller? --->
			<cfif fileExists(controllerPath & ".cfc")>
				<cfset result.objController = createObject("component", application.controllerRoot & "." & logicalPath)>
				
				<!--- View exists inside this controller? --->
				<cfif StructKeyExists(result.objController, nextPath)>
					<cfset result.foundController = true>
					<cfset result.view = nextPath>
				<cfelse>
					<!--- Does this controller have a default view? --->
					<cfif StructKeyExists(result.objController, "defaultView") AND trim(result.objController.defaultView) neq "">
						<cfset result.foundController = true>
						<cfset result.view = result.objController.defaultView>
					</cfif>
				</cfif>
			</cfif>
			<cfset continueSearching = (NOT result.foundController) AND directoryExists(controllerPath)>

			<cfset counter = counter + 1>
		</cfloop>
		
		<!--- Found the controller? --->
		<cfif result.foundController>
			<!--- Already found the controller, remove it from the path info --->		
			<cfset pathInfoStr = replace(pathInfoStr, result.controller, "")>
		<cfelse>		
			<!--- Is there a hidden controller that is always used? --->
			<cfif StructKeyExists(application, "hiddenController")>
				<cfset result.foundController = true>
				<cfset result.view = application.defaultView>
				<cfset result.controller = application.hiddenController>
				<cfset result.rootController = listLast(result.controller, "/")>
			<cfelse>
				<cfreturn result>
			</cfif>
		</cfif>
		
		<!--- Get the controller, view and resource id--->
		<cfset pathInfo = listToArray(pathInfoStr, "/")>
		<cfset pathInfoLength = arrayLen(pathInfo)>

		<!--- Get the view --->
		<cfif pathInfoLength ge 1>			
			<cfset result.view = pathInfo[1]>
			
			<!--- Get the Id value --->
			<cfif pathInfoLength ge 2>
				<!--- Number or text? --->
				<cfif isNumeric(pathInfo[2])>
					<!--- Number? => This is the id --->
					<cfset result.id = pathInfo[2]>
					<cfset result.textId = pathInfo[2]>
				<cfelse>
					<!--- Text? => This is the text id, eg. short title, short name, etc. --->
					<cfset result.id = 0>
					<cfset result.textId = pathInfo[2]>
				</cfif>
				
				<!--- Get the sub controller --->
				<cfif pathInfoLength ge 3>
					<cfset result.subController = pathInfo[3]>
					
					<!--- Get the sub Id value --->
					<cfif pathInfoLength ge 4>
						<!--- Number or text? --->
						<cfif isNumeric(pathInfo[4])>
							<!--- Number? => This is the id --->
							<cfset result.subId = pathInfo[4]>
							<cfset result.subTextId = "">
						<cfelse>
							<!--- Text? => This is the text id, eg. short title, short name, etc. --->
							<cfset result.subId = 0>
							<cfset result.subTextId = pathInfo[4]>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		
		<!--- NOT has a view? Set it to the default one --->
		<cfif NOT StructKeyExists(result, "view") OR result.view eq "">
			<cfset result.view = application.defaultView>
		</cfif>
		
		<!--- Not maintenance mode and user attempts to visit the maintenance page on LIVE? Disable it --->
		<cfif application.serverType eq 'LIVE' AND underMaintenaince
				AND result.controller eq application.maintenancePage>
			<cfset application.url.redirect()>
		</cfif>
		
		<cfset result.rootController = listLast(result.controller, "/")>
		
		<cfreturn result>
		
	</cffunction>
	


	<!--- Get the actual path info string --->
	<cffunction name="getPathInfoStr" access="public" returntype="string" output="false">
	
		<!--- At the root level address (just index.cfm), sometimes CGI.PATH_INFO returns the full path to the file
			instead of what is appended after the index.cfm. So we need to remove that before continuing --->
		<cfset var result = CGI.PATH_INFO>
		<cfif findNoCase("index.cfm", result)>
			<cfset result = reReplace(result, "[^.]*.cfm", "")>
		</cfif>
		
		<!--- Also at the root level, sometimes it returns the actual application logical path,
			so we need to remove this as well before continuing --->
		<cfif result eq application.appLogicalPath>
			<cfset result = "">
		</cfif>

		<cfreturn result>
		
	</cffunction>


	<!--- Get the actual path info string --->
	<cffunction name="currentPage" access="public" returntype="string" output="false">
		<cfargument name="includeQueryString" type="boolean" default="true" hint="true: include the query string in the result">
	
		<cfset var result = application.baseURL & getPathInfoStr()>
		
		<cfif arguments.includeQueryString AND CGI.QUERY_STRING neq "">
			<cfset result = result & "?" & CGI.QUERY_STRING>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>

	<!--- Redirect the parent page with a message. Used when inside an iframe popup --->
	<cffunction name="redirectParentMessage" access="public" output="false">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="message" type="string" required="yes" hint="The message to be displayed">
	
		<cfset session.message = arguments.message>
		<cfset variables.redirectParent(arguments.location)>
	
	</cffunction>


	<!--- Redirect the parent page with an error. Used when inside an iframe popup --->
	<cffunction name="redirectParentError" access="public" output="false">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="error" type="string" required="yes" hint="The error to be displayed">
	
		<cfset session.error = arguments.error>
		<cfset variables.redirectParent(arguments.location)>
	
	</cffunction>
	
	
	<!--- Redirect the parent page to a new page. Used when inside an iframe popup --->
	<cffunction name="redirectParent" access="public" output="false">

		<cfargument name="location" type="string" required="no" default="" hint="The location to redirect to">
		<cfset var finalLocation = "">
		
		<!--- Remove multi-slash and ending index.cfm to make the url looks nicer --->
		<cfif isValid("url", arguments.location)>
			<cfset finalLocation = arguments.location>
		<cfelse>
			<cfset finalLocation = reReplace(reReplace("#application.baseURL#/#arguments.finalLocation#", "([^:])/{2,}", "\1/", "ALL"), "index.cfm/$", "")>
		</cfif>
		
		<cfset variables.redirect("redirectparent?parentRedirectURL=#finalLocation#")>
		
	</cffunction>
	

</cfcomponent>