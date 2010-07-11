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
	
	
	<!--- CONTROLLER VARIABLES --->
	<cfscript>
		this.defaultView = "";
	</cfscript>
	
	
	<!--- Initialize the controller --->
	<cffunction name="init" access="public" output="no">
		
		<cfif StructKeyExists(session, "userId")>
			<cfset variables.userId = val(session.userId)>
		<cfelse>
			<cfset variables.userId = "">
		</cfif>
		
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
		<cfargument name="redirectOnNotFound" type="boolean" required="no" default="true" hint="true: redirect to the list page if the model is not found">
	
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
		<cfinvoke component="#application.load#" method="model" returnvariable="objModel">
			<cfinvokeargument name="template" value="#modelName#">
			<cfinvokeargument name="id" value="#val(form[modelName & 'Id'])#">
			<cfinvokeargument name="getArchived" value="#arguments.getArchived#">
		</cfinvoke>
		
		<!--- Any error in getting the model?--->
		<cfif objModel.error neq "" AND arguments.redirectOnNotFound>
			<cfset application.url.redirectError(lcase(modelName), objModel.error)>
		</cfif>
		
		<cfreturn objModel>
	
	</cffunction>
	
	
	<!--- Get a model by text id --->
	<cffunction name="getByTextId" access="private" returntype="any">
		
		<cfargument name="modelName" type="string" required="no" hint="When passed in: get this model instead of the current one">
		<cfargument name="getArchived" type="boolean" required="no" default="false" hint="true: get archived model">
		<cfargument name="redirectOnNotFound" type="boolean" required="no" default="true" hint="true: redirect to the list page if the model is not found">

		<!--- Get the model name --->
		<cfif StructKeyExists(arguments, "modelName")>
			<cfset modelName = arguments.modelName>
		<cfelse>
			<cfset metaData = getMetaData(this)>
			<cfset modelName = metaData.displayName>
		</cfif>
		
		<!--- Has text id? --->
		<cfif NOT StructKeyExists(form, modelName & "TextId") OR form[modelName & "TextId"] eq "">
			<cfset application.url.redirect(modelName)>
		</cfif>
		
		<!--- Get the model details --->
		<cfinvoke component="#application.load#" method="model" returnvariable="objModel">
			<cfinvokeargument name="template" value="#modelName#" />
			<cfinvokeargument name="textId" value="#form[modelName & 'TextId']#">
			<cfinvokeargument name="getArchived" value="#arguments.getArchived#" />
		</cfinvoke>
		
		<!--- Any error in getting the model? --->
		<cfif objModel.error neq "" AND arguments.redirectOnNotFound>
			<cfset application.url.redirectError(lcase(modelName), objModel.error)>
		</cfif>
		
		<cfreturn objModel>
	
	</cffunction>
	

	<!--- Save a model --->
	<cffunction name="save" access="private" returntype="any">
		<cfargument name="saveButton" type="string" required="no" default="save" hint="The name of the save button">
		<cfargument name="addPage" type="string" required="no" hint="The path of the add page">
		<cfargument name="editPage" type="string" required="no" hint="The path of the edit page">
		<cfargument name="listPage" type="string" required="no" hint="The path of the list page">
		
		<!--- Get the controller name --->
		<cfset metaData = getMetaData(this)>
		<cfset modelName = lcase(metaData.displayName)>
	
		<!--- Get the default values for pages --->
		<cfif NOT StructKeyExists(arguments, "addPage") OR trim(arguments.addPage) eq "">
			<cfset arguments.addPage = "#modelName#/add">
		</cfif>
		<cfif NOT StructKeyExists(arguments, "editPage") OR trim(arguments.editPage) eq "">
			<cfset arguments.editPage = "#modelName#/edit">
		</cfif>
		<cfif NOT StructKeyExists(arguments, "listPage") OR trim(arguments.listPage) eq "">
			<cfset arguments.listPage = "#modelName#/list">
		</cfif>
	
		<!--- User save? --->
		<cfif StructKeyExists(form, arguments.saveButton)>
			<!--- Add new or save existing? --->
			<cfset addNew = NOT val(form.id)>
		
			<!--- Get model --->
			<cfif addNew>
				<cfset objModel = application.load.model(modelName)>
			<cfelse>
				<cfset objModel = getById()>
			</cfif>
			<cfset qModel = objModel.get()>
			
			<cfinvoke component="#objModel#" method="save" fieldCollection="#form#" returnvariable="saveResult">
			
			<!--- Any error? --->
			<cfif arrayLen(saveResult.errorList)>
				<!--- Duplicate this query and change its column types to all be varchar --->
				<cfset qForm = QueryNew(qModel.columnList, repeatString("varchar,", listLen(qModel.columnList) - 1) & "varchar")>
				<cfset QueryAddRow(qForm)>
				<cfloop list="#qModel.columnList#" index="field">
					<cfset QuerySetCell(qForm, field, qModel[field][1], qForm.recordCount)>
				</cfloop>

				<!--- Save the form values into this query --->
				<cfloop array="#objModel.fields#" index="field">
					<cfif StructKeyExists(form, field.name)>
						<cfset QuerySetCell(qForm, field.name, form[field.name], qForm.recordCount)>
					</cfif>
				</cfloop>
				
				<!--- Return this query back to user --->
				<cfset session.qForm = qForm>
				<cfset session.submittedForm = StructCopy(form)>
				<cfset session.errorList = saveResult.errorList>
				
				<!--- Excute a function after save? --->
				<cfif isDefined("this._post_save")>
					<cfset this._post_save(saveResult)>
				</cfif>
			
				<!--- Add new? --->
				<cfif addNew>
					<cfset application.url.redirect("#arguments.addPage#")>
				<cfelse>
					<cfset application.url.redirect("#arguments.editPage#/#val(qModel.id)#")>
				</cfif>
			<cfelse>
				<!--- Excute a function after save? --->
				<cfif isDefined("this._post_save")>
					<cfset this._post_save(saveResult)>
				</cfif>
			
				<!--- Add new? --->
				<cfif addNew>
					<cfset application.url.redirectMessage("#arguments.listPage#", "New #modelName# added.")>
				<cfelse>
					<cfset application.url.redirectMessage("#arguments.editPage#/#val(qModel.id)#", "#application.core.capFirst(modelName)# updated")>
				</cfif>
			</cfif>
		<cfelse>
			<cfset application.url.redirect("#arguments.listPage#")>
		</cfif>
	
	</cffunction>
			

	<!--- Delete --->
	<cffunction name="delete" access="public">
		<cfargument name="deleteButton" type="string" required="no" default="delete" hint="The name of the delete button">
		<cfargument name="cancelButton" type="string" required="no" default="cancel" hint="The name of the cancel button">
		<cfargument name="deletePage" type="string" required="no" hint="The path of the delete page">
		<cfargument name="listPage" type="string" required="no" hint="The path of the list page">
		<cfargument name="titleField" type="string" required="yes" hint="The name of the title field. Used for display">
		<cfargument name="displayView" type="string" required="no" default="yes" hint="Display the delete view">
	
		<!--- Get the controller name --->
		<cfset metaData = getMetaData(this)>
		<cfset modelName = metaData.displayName>
	
		<!--- Get the default values for pages --->
		<cfif NOT StructKeyExists(arguments, "deletePage") OR trim(arguments.deletePage) eq "">
			<cfset arguments.deletePage = "#modelName#/delete">
		</cfif>
		<cfif NOT StructKeyExists(arguments, "listPage") OR trim(arguments.listPage) eq "">
			<cfset arguments.listPage = "#modelName#/list">
		</cfif>
		
		<!--- Get model --->
		<cfset objModel = getById()>
		<cfset qModel = objModel.get()>
		
		<!--- User delete? --->
		<cfif StructKeyExists(form, arguments.deleteButton)>
			<cfinvoke component="#objModel#" method="delete" returnvariable="deleteResult">
			
			<cfif arrayLen(deleteResult.errorList)>
				<cfset session.errorList = deleteResult.errorList>
				<cfset application.url.redirect("#arguments.listPage#")>
			<cfelse>
				<cfset application.url.redirectMessage("#arguments.listPage#", "#application.output.capFirst(modelName)# '#HTMLEditFormat(qModel[arguments.titleField][1])#' deleted")>
			</cfif>
		</cfif>
		
		<!--- User cancel? --->
		<cfif StructKeyExists(form, arguments.cancelButton)>
			<cfset application.url.redirect("#arguments.listPage#")>
		</cfif>
		
		<!--- Display view? --->
		<cfif arguments.displayView>
			<cfset data = StructNew()>
			<cfset data.heading = "Delete #modelName#: #HTMLEditFormat(qModel[arguments.titleField][1])#">
			<cfset data["q#modelName#"] = qModel>
			<cfset application.load.viewInTemplate("#arguments.deletePage#", data, objModel.fields)>
		</cfif>
	
	</cffunction>
	
</cfcomponent>