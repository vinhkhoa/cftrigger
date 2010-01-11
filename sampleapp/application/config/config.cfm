<!---
	Company:	cfTrigger sample app
	Summary:	Configuration settings for site
	Log:

--->

<cfscript>
	/* 
		CORE APPLICATION SETTINGS
		
		These configurations are required for cfTrigger to work properly.
		Change these settings according to your site but make sure
		you leave all the variables there. Deleting any of them might cause errors.
	*/
	application.appName = "cftSampleApp";
	
	// Development environments
	application.servers = ArrayNew(1);
	application.servers[1] = structNew();
	application.servers[1].name = 'localhost';
	application.servers[1].type = 'dev';
	application.servers[1].url = "http://localhost/cftrigger/sampleapp";
	application.servers[2] = structNew();
	application.servers[2].name = 'sampleapp';
	application.servers[2].type = 'live';
	application.servers[2].url = "http://sampleapp.com";	
	application.enableUserAuthentication = false;
	application.fromEmail = "admin <admin@sampleapp.com>";
	application.ErrorEmail = "admin@sampleapp.com";
	application.AdminEmail = "admin@sampleapp.com";
	application.defaultController = 'home';
	application.guestDefaultController = '';
	application.defaultView = 'index';
	application.refreshWhenReset = true;
	application.defaultTemplate = "_global/template";
	application.showLocalFriendlyError = true;
	application.show404OnMissingController = true;
	application.allowedScripts = "index.cfm";
	application.maintenanceMode = true;
	application.maintenancePage = "maintenance";
	application.devAddresses = "127.0.0.1";
	
	
	/* 
		APPLICATION SPECIFIC SETTINGS
		
		You can put your own application configuration here.
		Make sure you put only application scope variables here because this file is loaded only
		once inside the OnApplicationStart() method. Request, session and other scopes variables
		are put inside the variables.cfm file sitting in the same folder as this file
	*/	
	
</cfscript>
