<!---
	Project:	cfTrigger
	Company:	cfTrigger
	Summary:	authentication class. User to handles authentication related functions such as login user, logout, check if user is currently logged in, their role, etc.
	
	Log:
	
		Created:		08/12/2009		
		Modified:

--->

<cfcomponent displayname="Authentication" hint="Handles authentication related functions">

	<cfsetting enablecfoutputonly="yes">


	<!--- Authenticate user. Make sure that user has logged in --->
	<cffunction name="validate" displayname="authenticate" access="public">
		<cfargument name="sysAdmin" type="boolean" required="no" default="false" hint="Limit to a admin role">
		
		<!--- Authenticate user --->
		<cfset authenticated = StructKeyExists(session, "userId") AND val(session.userId)>
		
		<!--- Authenticated? --->
		<cfif NOT authenticated>
			<cfset session.redirectURL = CGI.PATH_INFO>
			<cfset application.url.redirectError("login", "Please login first")>
		</cfif>
	
		<!--- Needs to be admin? --->
		<cfif arguments.sysAdmin AND NOT session.sysAdmin>
			<cfset application.url.redirectError("", "You are not allowed to access this area")>
		</cfif>
		
	</cffunction>


	<!--- Deauthenticate user. Make sure that user has NOT logged in yet --->
	<cffunction name="devalidate" displayname="deauthenticate" access="public">
		
		<cfset authenticated = StructKeyExists(session, "userId") AND val(session.userId)>
		
		<cfif authenticated>
			<cfset application.url.redirect()>
		</cfif>
	
	</cffunction>
		

</cfcomponent>