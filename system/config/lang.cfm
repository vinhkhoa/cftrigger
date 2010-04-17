<!---
	Company:	cfTrigger
	Summary:	Language settings for site
	Log:
	
	Created:
		- 27/11/2009

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
<cfset application.defaultValidationLang.username = "The [field] is invalid. It can contain only letters, numbers or underscore">
<cfset application.defaultValidationLang.letters = "The [field] is invalid. It can contain only letters">
<cfset application.defaultValidationLang.digits = "The [field] is invalid. It can contain only numbers">
<cfset application.defaultValidationLang.url = "The [field] is not a valid url">
<cfset application.defaultValidationLang.limitChars = "The [field] contains invalid characters. Only these charactesr are allowed: [args]">
<cfset application.defaultValidationLang.localDirectory = "The [field] does not exist. It has to be a valid directory path.">
<cfset application.defaultValidationLang.phoneNumber = "The [field] is not valid. If you use home number, make sure you include the area code.">

<!--- General messages --->
<cfset application.defaultMessageLang = StructNew()>
<cfset application.defaultMessageLang.loginRequired = "Please login first">
<cfset application.defaultMessageLang.adminRequired = "You are not allowed to access this area">
<cfset application.defaultMessageLang.loggedOut = "You have been logged out">

