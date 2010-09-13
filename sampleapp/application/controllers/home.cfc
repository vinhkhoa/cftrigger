<!---
	Project:	cfTrigger sample app
	Summary:	Home controller
	Log:
	
--->

<cfcomponent displayname="Home" extends="appcontroller" output="false">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Default function --->
	<cffunction name="index" access="public">
	
		<!--- Display the view --->
		<cfset data = StructNew()>
		<cfset data.heading = "Welcome to cfTrigger sample app">
		<cfset application.load.viewInTemplate("home", data)>
	
	</cffunction>
	
</cfcomponent>