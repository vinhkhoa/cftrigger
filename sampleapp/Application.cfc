<!---
	Project:	cfTrigger sample app
	Summary:	Top level Application
	Log:
	
--->

<cfcomponent displayname="Application" extends="cft.libraries.Application">
	<cfsetting enablecfoutputonly="yes">
	
	<cfscript>
		// SET THE NAME FOR THIS APPLICATION - SEEN BY COLDFUSION - HAS TO BE UNIQUE PER SERVER
		This.name = super.getAppNameOnServer("cftSampleApp", "sampleapp.com", "localhost");
		if (findNoCase("sampleapp.com", CGI.SERVER_NAME))
		{
			This.rootFolder = "/";
		}
		else
		{
			This.rootFolder = "/cftrigger/sampleapp/";
		}
		
		// Have to record this in here before going to anywhere else
		This.appComponentFilePath = GetCurrentTemplatePath();
	</cfscript>
	

	<cffunction name="OnApplicationStart">
	
		<!--- Include the application specific configurations --->
		<cfinclude template="application/config/config.cfm" />
		<cfinclude template="application/config/variables.cfm">
		
		<cfset super.OnApplicationStart()>

	</cffunction>
	
	
	<!--- Refresh the session when necessary --->
	<cffunction name="refreshSession" access="private">
	
		<!---
			REFRESH SESSION ON PAGE REQUEST
			
			If you store variables inside the session scope and want to refresh them if
			you perform certain actions, you can put them here.
			
			For example, you store user details such as their first namd and last name
			inside the session scope, you might want to refresh it after user has updated
			their profile. Otherwise, their name stays the same until the next time they login.
			Here is the place for such code. You can write something like:
			
			if (PROFILE_JUST_UPDATED)
			{
				REFRESH THE session.user VARIABLE
			}
		--->
		
	</cffunction>
	
	
	<!--- Preload some libraries and models --->
	<cffunction name="preload">
	
		<!---
			PRE-LOAD APPLICATION LIBRARIES
			
			In addition to the cfTrigger core libraries, sometimes you might want to load certain
			libraries when the application starts. Put them here:
			
			application.load.library("[LIBRARY_NAME]", true)
			
			
			This place can also be used to preload any application variables. This serves a similar
			purpose section APPLICATION SPECIFIC SETTINGS in the application/config.cfm file. The only
			difference is this place is called AT THE END of the OnApplicationStart(). That means more
			application scope variables are available at this stage such as application paths.
			
		--->
	
	</cffunction>
	
</cfcomponent>