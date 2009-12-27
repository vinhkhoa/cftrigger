<!---
	Project:	cfTrigger
	Company:	cfTrigger
	Summary:	System url library, used to handle functions related to urls
	
	Log:
	
		Created:		05/08/2009		
		Modified:

--->

<cfcomponent displayname="Url" hint="Handles user funtions">

	<cfsetting enablecfoutputonly="yes">

	<!--- Redirect the page with a message --->
	<cffunction name="redirectMessage" access="public" output="no">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="message" type="string" required="yes" hint="The message to be displayed">
	
		<cfset session.message = arguments.message>
		<cfset this.redirect(arguments.location)>
	
	</cffunction>


	<!--- Redirect the page with an error --->
	<cffunction name="redirectError" access="public" output="no">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="error" type="string" required="yes" hint="The error to be displayed">
	
		<cfset session.error = arguments.error>
		<cfset this.redirect(arguments.location)>
	
	</cffunction>
	
	
	<!--- Redirect user to a page --->
	<cffunction name="redirect" access="public" output="no">

		<cfargument name="location" type="string" required="no" default="" hint="The location to redirect to">
		
		<!--- Remove multi-slash and ending index.cfm to make the url looks nicer --->
		<cfif isValid("url", arguments.location)>
			<cfset location = arguments.location>
		<cfelse>
			<cfset location = reReplace(reReplace("#application.baseURL#/#arguments.location#", "([^:])/{2,}", "\1/", "ALL"), "index.cfm/$", "")>
		</cfif>
		
		<cflocation url="#location#" addtoken="no">
		
	</cffunction>
	

	<!--- Redirect user to a page --->
	<cffunction name="redirectBack" access="public" output="no">

		<cfargument name="message" type="string" required="no" hint="The message to be displayed">
		<cfargument name="error" type="string" required="no" hint="The error to be displayed">
		
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
	<cffunction name="getPathInfoVariables" access="public" returntype="struct" output="no">

		<cfset var result = StructNew()>
		
		<!--- Maintenance mode? --->
		<cfif application.maintenanceMode>
			<!--- This client is a development computer? --->
			<cfif NOT listFind(application.devAddresses, CGI.REMOTE_ADDR)>
				<cfset result.controller = application.maintenancePage>
				<cfreturn result>
			</cfif>
		</cfif>
		
		<cfset pathInfoStr = this.getPathInfoStr()>
		<cfset foundController = false>
		<cfset continueSearching = true>
		<cfset counter = 1>
		<cfset path = "">
		<cfset logicalPath = "">
		
		<!--- Root? Load the default controller --->
		<cfif listLen(pathInfoStr, '/') eq 0>
			<cfset pathInfoStr = "/" & application.defaultController>
		</cfif>
		
		<!---
			Check if the controller is found and what is the correct controller 
			This is needed to search for controllers inside folders
		--->
		<cfloop condition="continueSearching AND counter le listLen(pathInfoStr, '/')">
			<cfset path = listAppend(path, listGetAt(pathInfoStr, counter, "/"), application.separator)>
			<cfset logicalPath = replace(path, application.separator, ".", "ALL")>
			<cfset result.controller = replace(path, application.separator, "/", "ALL")>
			<cfset controllerPath = application.controllerFilePath & path>

			<cfset foundController = fileExists(controllerPath & ".cfc")>
			<cfset continueSearching = (NOT foundController) AND directoryExists(controllerPath)>

			<cfset counter = counter + 1>
		</cfloop>
		
		<!--- Found the controller? --->
		<cfif NOT foundController>
			<!--- Anything to route? --->
			<!---<cfif StructKeyExists(application, "routes") AND StructKeyExists(application.routes, path)>
				<cfset vals = ArrayNew(1)>
				<cfset vars = reMatch("{([^}]+)}", application.routes[path])>
				
				<!--- Replace each variable with its value --->
				<cfloop from="1" to="#arrayLen(vars)#" index="i">
					<cftry>
						<cfset vals[i] = evaluate(replaceList(vars[i], "{,}", ""))>
						
						<cfcatch type="any">
							<cfset vals[i] = "">
						</cfcatch>
					</cftry>
				</cfloop>
				
				<!--- Get the final redirect url --->
				<cfset redirectURL = replaceList(application.routes[path], arrayToList(vars), arrayToList(vals))>
				
				<!---<cfset application.url.redirect(redirectURL)>--->
				<cfset getPageContext().forward(redirectURL)>
			</cfif>--->
		
			<!--- Show friendy error? --->
			<cfif application.showFriendlyError>
				<cfif application.show404OnMissingController>
					<cfset application.error.show_404()>
				<cfelse>
					<cfset application.error.show_error("Controller not found", "The system could not find the controller: #controllerPath#.cfc")>
				</cfif>
			<cfelse>
				<!--- Load the controller to throw error --->
				<cfset controller = CreateObject("component", application.controllerRoot & "." & logicalPath)>
			</cfif>
		</cfif>

		<!--- Already found the controller, remove it from the path info --->		
		<cfset pathInfoStr = replace(pathInfoStr, result.controller, "")>

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
					<cfset result[result.controller & "Id"] = pathInfo[2]>
					<cfset result[result.controller & "TextId"] = pathInfo[2]>
				<cfelse>
					<!--- Text? => This is the text id, eg. short title, short name, etc. --->
					<cfset result[result.controller & "Id"] = 0>
					<cfset result[result.controller & "TextId"] = pathInfo[2]>
				</cfif>
				
				<!--- Get the sub controller --->
				<cfif pathInfoLength ge 3>
					<cfset result.subController = pathInfo[3]>
					
					<!--- Get the sub Id value --->
					<cfif pathInfoLength ge 4>
						<!--- Number or text? --->
						<cfif isNumeric(pathInfo[4])>
							<!--- Number? => This is the id --->
							<cfset result[result.subController & "Id"] = pathInfo[4]>
							<cfset result[result.subController & "TextId"] = "">
						<cfelse>
							<!--- Text? => This is the text id, eg. short title, short name, etc. --->
							<cfset result[result.subController & "Id"] = 0>
							<cfset result[result.subController & "TextId"] = pathInfo[4]>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		
		<!--- Has a view? --->
		<cfif NOT StructKeyExists(result, "view")>
			<cfset result.view = application.defaultView>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	


	<!--- Get the actual path info string --->
	<cffunction name="getPathInfoStr" access="public" returntype="string" output="no">
	
		<!--- At the root level address (just index.cfm), sometimes CGI.PATH_INFO returns the full path to the file
		instead of what is appended after the index.cfm. So we need to remove that before continuing --->
		<cfset var result = CGI.PATH_INFO>
		<cfif findNoCase("index.cfm", result)>
			<cfset result = reReplace(result, "[^.]*.cfm", "")>
		</cfif>

		<cfreturn result>
		
	</cffunction>


	<!--- Get the actual path info string --->
	<cffunction name="currentPage" access="public" returntype="string" output="no">
		<cfargument name="includeQueryString" type="boolean" default="true" hint="true: include the query string in the result">
	
		<cfset var result = application.baseURL & getPathInfoStr()>
		
		<cfif arguments.includeQueryString AND CGI.QUERY_STRING neq "">
			<cfset result = result & "?" & CGI.QUERY_STRING>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>

	<!--- Redirect the parent page with a message. Used when inside an iframe popup --->
	<cffunction name="redirectParentMessage" access="public" output="no">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="message" type="string" required="yes" hint="The message to be displayed">
	
		<cfset session.message = arguments.message>
		<cfset this.redirectParent(arguments.location)>
	
	</cffunction>


	<!--- Redirect the parent page with an error. Used when inside an iframe popup --->
	<cffunction name="redirectParentError" access="public" output="no">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="error" type="string" required="yes" hint="The error to be displayed">
	
		<cfset session.error = arguments.error>
		<cfset this.redirectParent(arguments.location)>
	
	</cffunction>
	
	
	<!--- Redirect the parent page to a new page. Used when inside an iframe popup --->
	<cffunction name="redirectParent" access="public" output="no">

		<cfargument name="location" type="string" required="no" default="" hint="The location to redirect to">
		
		<!--- Remove multi-slash and ending index.cfm to make the url looks nicer --->
		<cfif isValid("url", arguments.location)>
			<cfset location = arguments.location>
		<cfelse>
			<cfset location = reReplace(reReplace("#application.baseURL#/#arguments.location#", "([^:])/{2,}", "\1/", "ALL"), "index.cfm/$", "")>
		</cfif>
		
		<cfset this.redirect("redirectParent?parentRedirectURL=#location#")>
		
	</cffunction>
	

</cfcomponent>