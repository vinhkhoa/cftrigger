<!---
	Project:	cfTrigger sample app
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
	application.appName = "sampleApp";
	application.name = "CFT Sample App";
	
	
	// =========================== Start of Server settings ===========================
	application.servers = ArrayNew(1);
	
	// Localhost for Apache
	s = StructNew();
	s.name = "localhost";
	s.type = "dev";
	s.url = "http://localhost/sampleapp";
	s.appNameSuffix = 'localhost_apache';
	arrayAppend(application.servers, s);
	
	// Localhost for Adobe Coldfusion
	s = StructNew();
	s.name = "localhost";
	s.type = "dev";
	s.url = "http://localhost:8500/sampleapp";
	s.appNameSuffix = 'localhost_adobe';
	arrayAppend(application.servers, s);
	
	// Localhost for Railo
	s = StructNew();
	s.name = "localhost";
	s.type = "dev";
	s.url = "http://localhost:8600/sampleapp";
	s.appNameSuffix = 'localhost_railo';
	arrayAppend(application.servers, s);
	
	// Live
	s = StructNew();
	s.name = "sampleapp.com";
	s.type = "live";
	s.url = "http://sampleapp.com";
	s.appNameSuffix = 'live';
	arrayAppend(application.servers, s);
	
	// =========================== End of Server settings ===========================
	
	
	application.enableUserAuthentication = false;
	application.fromEmail = "CFT Sample App <hello@sampleapp.com>";
	application.ErrorEmail = "error@sampleapp.com";
	application.AdminEmail = "admin@sampleapp.com";
	application.defaultController = 'home';
	application.defaultView = 'index';
	application.guestDefaultController = "";
	application.guestControllers = "";
	application.defaultTemplate = "_global/template";
	application.showLocalFriendlyError = true;
	application.show404OnMissingController = true;
	application.allowedScripts = "index.cfm";
	application.maintenanceMode = false;
	application.maintenancePage = "";
	application.canSendEmail = false;
</cfscript>
