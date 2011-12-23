<!---
	Project:	cfTrigger sample app
	Summary:	Top level Application
	Log:
	
--->

<cfcomponent displayname="Application" extends="cft.libraries.Application" output="false">
	<cfsetting enablecfoutputonly="yes">	
	
	<!--- Have to record this in here before going to anywhere else --->
	<cfset This.appComponentFilePath = GetCurrentTemplatePath()>
	<cfset This.name = "sampleapp">
	
	<cffunction name="OnApplicationStart">
	
		<!--- Include the application specific configurations --->
		<cfinclude template="application/config/config_cft.cfm" />
		<cfinclude template="application/config/config.cfm" />

		<cfset super.OnApplicationStart()>
		
	</cffunction>
	

	<!--- Refresh the session when necessary --->
	<cffunction name="refreshSession" access="private">
	
	</cffunction>
	
	
	<!--- Autoload on application start --->
	<cffunction name="autoload_application">
	
	</cffunction>
	
	
	<!--- Autoload on request start --->
	<cffunction name="autoload_request">
	
	</cffunction>
	
</cfcomponent>