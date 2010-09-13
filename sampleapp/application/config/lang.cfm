<!---
	Project:	cfTrigger sample app
	Summary:	Language settings for site
	Log:

--->

<cfscript>
	/*
		VALIDATION LANGUAGES
		
		If you want to have custom error messages when validation error happens, put them here
		after the application.validationLang declaration line below. Write them in the format:
		
		application.validationLang.[MODEL_NAME].[FIELD_NAME].[ERROR_TYPE] = "[CUSTOM_ERROR_MESSAGE]";
	*/
	
	application.validationLang = StructNew();
</cfscript>
