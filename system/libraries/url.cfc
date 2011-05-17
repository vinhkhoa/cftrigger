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
		<cfset redirect(arguments.location)>
	
	</cffunction>


	<!--- Redirect the page with an error --->
	<cffunction name="redirectError" access="public" output="false">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="error" type="string" required="yes" hint="The error to be displayed">
		
		<cfset session.error = arguments.error>
		<cfset redirect(arguments.location)>
	
	</cffunction>
	
	
	<!--- Redirect the page with a list of error --->
	<cffunction name="redirectErrorList" access="public" output="false">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="errorList" type="array" required="yes" hint="The error list to be displayed">
	
		<cfset session.errorList = arguments.errorList>
		<cfset redirect(arguments.location)>
	
	</cffunction>
	
	
	<!--- Redirect user to a page --->
	<cffunction name="redirect" access="public" output="false">

		<cfargument name="location" type="string" required="no" default="" hint="The location to redirect to">
		<cfset var finalLocation = "">
		<cfset var processedLocation = "">
		
		<!--- Remove multi-slash and ending index.cfm to make the url looks nicer --->
		<cfif isValid("url", arguments.location)>
			<cfset finalLocation = arguments.location>
		<cfelse>
			<!--- Does this application have redirection set up --->
			<cfif StructKeyExists(application, "hasRedirects") AND application.hasRedirects>
				<cfset processedLocation = arguments.location>
			<cfelse>
				<!--- 1 parts in URL --->
				<cfif listLen(arguments.location, "/")>
					<cfset processedLocation = processedLocation & "?controller=#listFirst(arguments.location, '/')#&">
					
					<!--- 2 parts in URL --->
					<cfif listLen(arguments.location, "/") gt 1>
						<cfset processedLocation = processedLocation & "view=#listGetAt(arguments.location, 2, '/')#&">
	
						<!--- 3 parts in URL --->
						<cfif listLen(arguments.location, "/") gt 3>
							<cfset processedLocation = processedLocation & "id=#listGetAt(arguments.location, 3, '/')#&">
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		
			<cfset finalLocation = reReplace(reReplace("#application.baseURL#/#processedLocation#", "([^:])/{2,}", "\1/", "ALL"), "index.cfm/$", "")>
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
	

	<!--- Redirect the parent page with a message. Used when inside an iframe popup --->
	<cffunction name="redirectParentMessage" access="public" output="false">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="message" type="string" required="yes" hint="The message to be displayed">
	
		<cfset session.message = arguments.message>
		<cfset redirectParent(arguments.location)>
	
	</cffunction>


	<!--- Redirect the parent page with an error. Used when inside an iframe popup --->
	<cffunction name="redirectParentError" access="public" output="false">
	
		<cfargument name="location" type="string" required="yes" hint="The location to redirect to">
		<cfargument name="error" type="string" required="yes" hint="The error to be displayed">
	
		<cfset session.error = arguments.error>
		<cfset redirectParent(arguments.location)>
	
	</cffunction>
	
	
	<!--- Redirect the parent page to a new page. Used when inside an iframe popup --->
	<cffunction name="redirectParent" access="public" output="false">

		<cfargument name="location" type="string" required="no" default="" hint="The location to redirect to">
		<cfset var finalLocation = "">
		
		<!--- Remove multi-slash and ending index.cfm to make the url looks nicer --->
		<cfif isValid("url", arguments.location)>
			<cfset finalLocation = arguments.location>
		<cfelse>
			<cfset finalLocation = reReplace(reReplace("#application.baseURL#/#arguments.location#", "([^:])/{2,}", "\1/", "ALL"), "index.cfm/$", "")>
		</cfif>
		
		<cfset redirect("redirectparent?parentRedirectURL=#finalLocation#")>
		
	</cffunction>
	

	<!--- Validate the request referer against a particular page/pattern --->
	<cffunction name="validateReferer" access="public" returntype="struct" output="false" hint="Validate the request referer against a particular page/pattern">

		<cfargument name="pagePattern" type="string" required="yes" hint="The pattern to validate against">
		<cfset var result = StructNew()>
		<cfset result.valid = true>
		
		<!--- Is this a full page url? --->
		<cfif NOT reFindNoCase("^#application.rootURL#", arguments.pagePattern)>
			<cfset arguments.pagePattern = "#application.baseURL#/" & arguments.pagePattern>
		</cfif>
		
		<!--- Validate 2 things: CGI.HTTP_REFERER starts with the expected url and that is the only url it contains --->
		<cfif NOT isValid("url", CGI.HTTP_REFERER) OR NOT reFindNoCase("^" & arguments.pagePattern, CGI.HTTP_REFERER)>
			<cfset result.valid = false>
		</cfif>
		
		<cfreturn result>

	</cffunction>
	
</cfcomponent>