<!---
	Project:		cfTrigger
	Company:		cfTrigger
	Summary:		Main Controller class
	
	Log:
	
	Created:		05/06/2009
	
	Modified:
	- 

--->

<cfcomponent bindingname="Controller" displayname="Controller" hint="Main Controller class">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Initialize the controller --->
	<cffunction name="init" access="public" output="no">
		
		<cfset variables.userId = val(session.userId)>
		
		<!--- This controller may be referenced later on --->
		<cfset request.controller = this>
		
		<cfreturn this>
		
	</cffunction>
	
	<!--- ================================ COMMON FUNCTIONS ======================================= --->
	
	<!--- Default function --->
	<cffunction name="index" access="public">
	
		<!---
			USE SHOULD NEVER BE ABLE TO GET HERE. IF THEY DO, THE CONTROLLER IS MISSING THE INDEX FUNCTION.
			THIS FUNCTION IS ONLY USED FOR TESTING TO INDICATE THAT THE CONTROLLER HAS BEEN SET UP PROPERLY
		--->
		
		<!--- Get the controller name --->
		<cfset metaData = getMetaData(this)>
		<cfset modelName = metaData.displayName>
		
		<cfset application.error.show_error("Missing index function", "You need to have an index function for controller: #modelName#")>
		
	</cffunction>
	


	<!--- =================================== PRIVATE FUNCTIONS ========================================= --->
	
	
	<!--- Get a model by id --->
	<cffunction name="getById" access="private" returntype="any">
	
		<cfargument name="modelName" type="string" required="no" hint="When passed in: get this model instead of the current one">
		<cfargument name="getArchived" type="boolean" required="no" default="false" hint="true: get archived model">
	
		<!--- Get the model name --->
		<cfif StructKeyExists(arguments, "modelName")>
			<cfset modelName = arguments.modelName>
		<cfelse>
			<cfset metaData = getMetaData(this)>
			<cfset modelName = metaData.displayName>
		</cfif>
		
		<!--- Has id? --->
		<cfif NOT StructKeyExists(form, modelName & "Id") OR form[modelName & "Id"] eq "">
			<cfset application.url.redirect(modelName)>
		</cfif>
	
		<!--- Get the model details --->
		<cfinvoke component="#application.load#" method="model" returnvariable="obj">
			<cfinvokeargument name="template" value="#modelName#">
			<cfinvokeargument name="id" value="#val(form[modelName & 'Id'])#">
			<cfinvokeargument name="getArchived" value="#arguments.getArchived#">
		</cfinvoke>
		
		<!--- Any error in getting the model?--->
		<cfif obj.error neq "">
			<cfset application.url.redirectError(lcase(modelName), obj.error)>
		</cfif>
		
		<cfreturn obj>
	
	</cffunction>
	
	
	<!--- Get a model by text id --->
	<cffunction name="getByTextId" access="private" returntype="any">
		
		<cfargument name="getArchived" type="boolean" required="no" default="false" hint="true: get archived model">

		<!--- Get the controller name --->
		<cfset metaData = getMetaData(this)>
		<cfset modelName = metaData.displayName>
		
		<!--- Has text id? --->
		<cfif NOT StructKeyExists(form, modelName & "TextId") OR form[modelName & "TextId"] eq "">
			<cfset application.url.redirect(modelName)>
		</cfif>
		
		<!--- Get the model details --->
		<cfinvoke component="#application.load#" method="model" returnvariable="obj">
			<cfinvokeargument name="template" value="#modelName#" />
			<cfinvokeargument name="textId" value="#form[modelName & 'TextId']#">
			<cfinvokeargument name="getArchived" value="#arguments.getArchived#" />
		</cfinvoke>
		
		<!--- Any error in getting the model? --->
		<cfif obj.error neq "">
			<cfset application.url.redirectError(lcase(modelName), obj.error)>
		</cfif>
		
		<cfreturn obj>
	
	</cffunction>
	
</cfcomponent>