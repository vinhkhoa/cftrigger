<!---
	Project:	cfTrigger
	Summary:	Error library, used to handle errors that occur such as 404, 500...	
	
	Log:
	
		Created:		02/06/2009		
		Modified:

--->

<cfcomponent displayname="Error" hint="Handles application errors" output="false">

	<cfsetting enablecfoutputonly="yes">
	

	<!--- Show 404 error --->
	<cffunction name="show_404" access="public" returntype="string">
	
		<cfargument name="heading" type="string" required="no" default="Whoops! Looks like we've lost that page!" hint="The error heading to be displayed">
		<cfargument name="message" type="string" required="no" default="The page you are looking for is not found or has been deleted." hint="The error message to be displayed">
		<cfset var data = "">
		<cfset var errorDetails = "">
		
		<!--- Has an error page inside the application? Load it inside the application template --->
		<cfif fileExists(application.errorFilePath & "404.cfm")>
			<!--- Display the error --->
			<cfset data = StructNew()>
			<cfset data.heading = arguments.heading>		
			<cfset data.message = arguments.message>		
			<cfset application.load.errorInTemplate("404", data)>
		<cfelse>
			<!--- Display the FI error page --->
			<cfset errorDetails = StructNew()>
			<cfset errorDetails.heading = arguments.heading>
			<cfset errorDetails.message = arguments.message>
			<cfoutput><cfinclude template="/cft/errors/404.cfm"></cfoutput>
			<cfabort>
		</cfif>
		
	</cffunction>
	
	
	<!--- Show general error --->
	<cffunction name="show_error" access="public">
	
		<cfargument name="heading" type="string" required="yes" hint="The error heading to be displayed">
		<cfargument name="message" type="string" required="yes" hint="The error message to be displayed">
		<cfset var data = "">
		<cfset var errorDetails = "">
		
		<!--- Has an error page inside the application? Load it inside the application template --->
		<cfif fileExists(application.errorFilePath & "error_general.cfm")>
			<!--- Display the error --->
			<cfset data = StructNew()>
			<cfset data.heading = arguments.heading>		
			<cfset data.message = arguments.message>		
			<cfset application.load.errorInTemplate("error_general", data)>
		<cfelse>
			<!--- Display the FI error page --->
			<cfset errorDetails = StructNew()>
			<cfset errorDetails.heading = arguments.heading>
			<cfset errorDetails.message = arguments.message>
			<cfoutput><cfinclude template="/cft/errors/error_general.cfm"></cfoutput>
			<cfabort>
		</cfif>
		
	</cffunction>

	
	<!--- Show production error --->
	<cffunction name="show_production_error" access="public">
	
		<cfset var errorData = "">
	
		<!--- Has an error page inside the application? Load it inside the application template --->
		<cfif fileExists(application.errorFilePath & "production_error.cfm")>
			<cfset errorData = StructNew()>
			<cfset errorData.heading = "Error">
			<cfset application.load.errorInTemplate("production_error", errorData)>
		<cfelse>
			<!--- Display the FI error page --->
			<cfoutput><cfinclude template="/cft/errors/production_error.cfm"></cfoutput>
		</cfif>
		
		<cfabort>
		
	</cffunction>

</cfcomponent>