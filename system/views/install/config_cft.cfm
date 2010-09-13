<!---
	Project:	cfTrigger
	Summary:	Configuration settings for application
	Log:

--->

<cfscript>
	/* 
		CORE APPLICATION SETTINGS
		
		These configurations are required for cfTrigger to work properly.
		Change these settings according to your site but make sure
		you leave all the variables there. Deleting any of them might cause errors.
	*/
	application.appName = "{appName}";
	
	// Server settings
	application.servers = ArrayNew(1);
	
	{servers}
	
	application.enableUserAuthentication = {enableUserAuthentication};
	application.fromEmail = "{fromEmail}";
	application.ErrorEmail = "{ErrorEmail}";
	application.AdminEmail = "{AdminEmail}";
	application.defaultController = "{defaultController}";
	application.defaultView = "{defaultView}";
	application.guestDefaultController = "{guestDefaultController}";
	application.defaultTemplate = "{defaultTemplate}";
	application.showLocalFriendlyError = {showLocalFriendlyError};
	application.show404OnMissingController = {show404OnMissingController};
	application.allowedScripts = "{allowedScripts}";
	application.maintenanceMode = {maintenanceMode};
	application.maintenancePage = "{maintenancePage}";
	application.canSendEmail = {canSendEmail};
</cfscript>
