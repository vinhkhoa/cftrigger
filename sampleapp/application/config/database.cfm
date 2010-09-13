<!---
	Project:	cfTrigger sample app
	Summary:	Configuration settings for site
	Log:

--->

<cfscript>
	databases = structNew();
	
	// Live database settings
	databases["live"]["dbname"] = "sampleapp_production";
	databases["live"]["dbuser"] = "";
	databases["live"]["dbpassword"] = "";
	
	// Development database settings
	databases["dev"]["dbname"] = "sampleapp_dev";
	databases["dev"]["dbuser"] = "";
	databases["dev"]["dbpassword"] = "";
</cfscript>