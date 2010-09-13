<!---
	Project:	cfTrigger
	Summary:	Language settings for site. Language: English
	Log:
	
--->
 
<!--- Validation languages --->
<cfset application.defaultValidationLang = StructNew()>
<cfset application.defaultValidationLang.required = "The [field] cannot be empty">
<cfset application.defaultValidationLang.unique = "A [modelName] with the [field] '[value]' already exists">
<cfset application.defaultValidationLang.email = "The [field] is not valid">
<cfset application.defaultValidationLang.minLen = "The [field] is too short, minimum [args] characters">
<cfset application.defaultValidationLang.maxLen = "The [field] is too long, maximum [args] characters">
<cfset application.defaultValidationLang.numeric = "The [field] has to be a number">
<cfset application.defaultValidationLang.minVal = "The [field] is too small, minimum [args]">
<cfset application.defaultValidationLang.maxVal = "The [field] is too big, maximum [args]">
<cfset application.defaultValidationLang.username = "The [field] is invalid. It can contain only letters, numbers or underscores">
<cfset application.defaultValidationLang.letters = "The [field] is invalid. It can contain only letters">
<cfset application.defaultValidationLang.digits = "The [field] is invalid. It can contain only numbers">
<cfset application.defaultValidationLang.url = "The [field] is not a valid url">
<cfset application.defaultValidationLang.limitChars = "The [field] is invalid. It can only contain: [args]">
<cfset application.defaultValidationLang.localDirectory = "The [field] does not exist. It has to be a valid directory path.">
<cfset application.defaultValidationLang.phoneNumber = "The [field] is not valid. If you use home number, make sure you include the area code.">
<cfset application.defaultValidationLang.validURLChars = "The [field] is invalid. It can contain only letters, numbers, underscores or hyphens">