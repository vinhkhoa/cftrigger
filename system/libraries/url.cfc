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