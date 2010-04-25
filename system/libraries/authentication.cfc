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

			<!--- Do not show error on the first page open --->
			<cfif session.redirectURL eq "" OR session.redirectURL eq "/" OR session.redirectURL eq application.appLogicalPath>
				<cfset application.url.redirect("login")>
			<cfelse>
				<cfset application.url.redirectError("login", application.lang.get("loginRequired"))>
			</cfif>
		</cfif>
	
		<!--- Needs to be admin? --->
		<cfif arguments.sysAdmin AND NOT session.sysAdmin>
			<cfset application.url.redirectError("", application.lang.get("adminRequired"))>
		</cfif>
		
	</cffunction>


	<!--- Validate user as guiest. Make sure that user has NOT logged in yet --->
	<cffunction name="validateAsGuest" displayname="deauthenticate" access="public">
		
		<cfset authenticated = StructKeyExists(session, "userId") AND val(session.userId)>
		
		<cfif authenticated>
			<cfset application.url.redirect()>
		</cfif>
	
	</cffunction>
		

	<!--- Generate an encrypted password and its salt --->
	<cffunction name="encryptPassword" displayname="encryptPassword" returntype="struct" hint="Generate the encrypted password">
		<cfargument name="password" type="string" required="yes" hint="The password that user wants">
		<cfargument name="salt" type="string" required="no" hint="The salt that user wants. Pass this in to keep the old salt. Don't pass in to generate a new salt as well">
		<cfset var result = StructNew()>
		<cfset result.salt = "">
		<cfset result.password = "">
		
		<!--- Keep old salt? --->
		<cfif StructKeyExists(arguments, "salt")>
			<cfset result.salt = arguments.salt>
		<cfelse>
			<cfset result.salt = lcase(createUUID())>
		</cfif>
		
		<cfif trim(arguments.password) neq "">
			<cfset result.password = hash(result.salt & arguments.password, "SHA")>
		<cfelse>
			<cfset result.password = "">
		</cfif>
		
		<cfreturn result>
	
	</cffunction>


</cfcomponent>