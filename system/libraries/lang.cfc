<!---
	Project:		cfTrigger
	Company:		cfTrigger
	Summary:		System language class
	
	Log:
	
	Created:		02/12/2009
	
	Modified:
	- 

--->

<cfcomponent displayname="Lang" output="false">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Get a validation languge --->
	<cffunction name="getValidationLang" displayname="getValidationLang" access="public" returntype="string" hint="Get a validation language" output="false">
		<cfargument name="modelName" type="string" required="yes" hint="The model name">
		<cfargument name="field" type="struct" required="yes" hint="The field details">
		<cfargument name="value" type="string" required="yes" hint="The field value">
		<cfargument name="rule" type="string" required="yes" hint="The rule name">
		<cfargument name="args" type="string" required="no" default="" hint="The rule arguments">
		<cfset var result = "">
		
		<!--- Is there a validation language for this? --->
		<cfif StructKeyExists(application, "validationLang") AND
				StructKeyExists(application.validationLang, arguments.modelName) AND
				StructKeyExists(application.validationLang[arguments.modelName], arguments.field.name) AND
				StructKeyExists(application.validationLang[arguments.modelName][arguments.field.name], arguments.rule)>
			<cfset result = application.validationLang[arguments.modelName][arguments.field.name][arguments.rule]>
		<cfelse>
			<!--- Is there a default one? --->
			<cfif StructKeyExists(application.defaultValidationLang, arguments.rule)>
				<cfset result = application.defaultValidationLang[arguments.rule]>
			</cfif>
		</cfif>

		<!--- Found a value for the language? --->
		<cfif result neq "">
			<cfset result = replace(result, "[modelName]", lcase(arguments.modelName), "ALL")>
			<cfset result = replace(result, "[field]", arguments.field.label, "ALL")>
			<cfset result = replace(result, "[value]", arguments.value, "ALL")>
			<cfset result = replace(result, "[args]", arguments.args, "ALL")>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Get a message --->
	<cffunction name="get" displayname="get" access="public" returntype="string" hint="Get a message" output="false">
		<cfargument name="msgName" type="string" required="yes" hint="The message name">
		<cfset var result = "">
		
		<!--- Is there a message language for this? --->
		<cfif StructKeyExists(application, "messageLang") AND StructKeyExists(application.messageLang, arguments.msgName)>
			<cfset result = application.messageLang[arguments.msgName]>
		<cfelse>
			<!--- Is there a default one? --->
			<cfif StructKeyExists(application.defaultMessageLang, arguments.msgName)>
				<cfset result = application.defaultMessageLang[arguments.msgName]>
			</cfif>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	
</cfcomponent>