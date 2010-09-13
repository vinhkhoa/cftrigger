<!--- 
	Project:	cfTrigger
	Summary:	Install cftrigger
	Log:
	
 --->

<cfcomponent displayname="Install" extends="cft.libraries.controller" output="false">

	<cfsetting enablecfoutputonly="yes">
	
	<!--- DEFAULT --->
	<cffunction name="index" access="public">
		
		<!--- Default application variables --->
		<cfparam name="application.appName" default="">
		<cfparam name="application.servers" default="#ArrayNew(1)#">
		<cfparam name="application.enableUserAuthentication" default="false">
		<cfparam name="application.fromEmail" default="">
		<cfparam name="application.errorEmail" default="">
		<cfparam name="application.adminEmail" default="">
		<cfparam name="application.defaultController" default="">
		<cfparam name="application.defaultView" default="index">
		<cfparam name="application.guestDefaultController" default="">
		<cfparam name="application.refreshWhenReset" default="true">
		<cfparam name="application.defaultTemplate" default="">
		<cfparam name="application.showLocalFriendlyError" default="true">
		<cfparam name="application.show404OnMissingController" default="true">
		<cfparam name="application.allowedScripts" default="index.cfm">
		<cfparam name="application.maintenanceMode" default="false">
		<cfparam name="application.maintenancePage" default="true">
		<cfparam name="application.canSendEmail" default="false">
		<cfparam name="application.maintenancePage" default="true">
		<cfparam name="application.directView" default="">
		<cfparam name="application.directViewVariables" default="">
		
		<!--- Default form variables --->
		<cfparam name="form.appName" default="#application.appName#">
		<cfparam name="form.servers" default="#application.servers#">
		<cfparam name="form.enableUserAuthentication" default="#application.enableUserAuthentication#">
		<cfparam name="form.fromEmail" default="#application.fromEmail#">
		<cfparam name="form.errorEmail" default="#application.errorEmail#">
		<cfparam name="form.adminEmail" default="#application.adminEmail#">
		<cfparam name="form.defaultController" default="#application.defaultController#">
		<cfparam name="form.defaultView" default="#application.defaultView#">
		<cfparam name="form.guestDefaultController" default="#application.guestDefaultController#">
		<cfparam name="form.refreshWhenReset" default="#application.refreshWhenReset#">
		<cfparam name="form.defaultTemplate" default="#application.defaultTemplate#">
		<cfparam name="form.showLocalFriendlyError" default="#application.showLocalFriendlyError#">
		<cfparam name="form.show404OnMissingController" default="#application.show404OnMissingController#">
		<cfparam name="form.allowedScripts" default="#application.allowedScripts#">
		<cfparam name="form.maintenanceMode" default="#application.maintenanceMode#">
		<cfparam name="form.maintenancePage" default="#application.maintenancePage#">
		<cfparam name="form.canSendEmail" default="#application.canSendEmail#">
		<cfparam name="form.maintenancePage" default="#application.maintenancePage#">
		<cfparam name="form.directView" default="#application.directView#">
		<cfparam name="form.directViewVariables" default="#application.directViewVariables#">
		
		<!--- User saves? --->
		<cfif StructKeyExists(form, "save")>
			<!--- Validation rules --->
			<cfscript>
				fields = ArrayNew(1);
				
				f = StructNew();
				f.name = "appName";
				f.label = "Application name";
				f.type = "varchar";
				f.rules = "required,limitChars(a-zA-Z0-9_)";
				arrayAppend(fields, f);

				f = StructNew();
				f.name = "defaultController";
				f.label = "Default controller";
				f.type = "varchar";
				f.rules = "limitChars(a-zA-Z0-9_\-/)";
				arrayAppend(fields, f);

				f = StructNew();
				f.name = "defaultController";
				f.label = "Default controller";
				f.type = "varchar";
				f.rules = "required,limitChars(a-zA-Z0-9_\-/)";
				arrayAppend(fields, f);

				f = StructNew();
				f.name = "defaultTemplate";
				f.label = "Default template";
				f.type = "varchar";
				f.rules = "limitChars(a-zA-Z0-9_\-/)";
				arrayAppend(fields, f);

				f = StructNew();
				f.name = "defaultView";
				f.label = "Default view";
				f.type = "varchar";
				f.rules = "required,limitChars(a-zA-Z0-9)";
				arrayAppend(fields, f);

				f = StructNew();
				f.name = "allowedScripts";
				f.label = "Allowed scripts";
				f.type = "varchar";
				f.rules = "required";
				arrayAppend(fields, f);
			</cfscript>
			
			<!--- Validate --->
			<cfset objValidation = application.load.library("validation").init()>
			<cfset validateResult = objValidation.run(form, fields)>
			
			<cfif NOT arrayLen(validateResult.errorList)>
				<!--- Get the config file content --->
				<cfset configFile = application.CFT_viewFilePath & "install#application.separator#config_cft.cfm">
				
				<cfif fileExists(configFile)>
					<!--- Construct the file content --->
					<cffile action="read" file="#configFile#" variable="content">

					<cfloop collection="#form#" item="field">
						<cfif isSimpleValue(form[field])>
							<cfset content = reReplaceNoCase(content, "{#field#}", trim(form[field]), "ALL")>
						</cfif>
					</cfloop>
					
					<!--- Get server settings --->
					<cfset liveRootDomain = lcase(listFirst(application.core.trimChar(CGI.SCRIPT_NAME, "/"), "/"))>
					<cfsavecontent variable="servers">
						<cfoutput>
						// Dev
						s = StructNew();
						s.name = "#CGI.SERVER_NAME#";
						s.type = "dev";
						s.url = "#replaceNoCase(CGI.HTTP_REFERER, "/index.cfm/install", "", "ALL")#";
						s.appNameSuffix = "#CGI.SERVER_NAME#";
						arrayAppend(application.servers, s);
						
						// Live
						s = StructNew();
						s.name = "#liveRootDomain#.com";
						s.type = "live";
						s.url = "http://#liveRootDomain#.com";
						s.appNameSuffix = 'live';
						arrayAppend(application.servers, s);
						</cfoutput>
					</cfsavecontent>
					<cfset content = reReplaceNoCase(content, "{servers}", trim(servers), "ALL")>
					
					<!--- Write out the config file --->
					<cfset newConfigFile = application.configFilePath & "config_cft.cfm">
					<cffile action="write" file="#newConfigFile#" output="#content#">
					
					<cfset application.url.redirectMessage("install", "Application settings saved")>
				<cfelse>
					<cfset session.error = "Config file template is not found">
				</cfif>
			<cfelse>
				<cfset session.errorList = validateResult.errorList>
			</cfif>
		</cfif>

		<!--- Display the view --->
		<cfinclude template="/cft/views/install/index.cfm">
	
	</cffunction>

</cfcomponent>