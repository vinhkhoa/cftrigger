<!---
	Project:		cfTrigger
	Summary:		Main Controller class
	
	Log:
	
	Created:		05/06/2009
	
	Modified:
	- 

--->

<cfcomponent bindingname="Controller" displayname="Controller" hint="Main Controller class" output="false">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- CONTROLLER VARIABLES --->
	<cfscript>
		this.defaultView = "";
	</cfscript>
	
	
	<!--- Initialize the controller --->
	<cffunction name="init" access="public" output="false">
	
		<cfset var metaData = "">
		
		<cfif StructKeyExists(session, "userId")>
			<cfset variables.userId = val(session.userId)>
		<cfelse>
			<cfset variables.userId = "">
		</cfif>
		
		<!--- This controller may be referenced later on --->
		<cfset request.controller = this>
		<cfset metaData = getMetaData(this)>
		<cfset variables.modelName = lcase(listLast(metaData.name, '.'))>
		<cfset variables.modelNames = application.utils.plural(variables.modelName)>
		<cfset variables.displayName = metaData.displayName>
		
		<cfreturn this>
		
	</cffunction>
	
	
	<!--- ================================ COMMON FUNCTIONS ======================================= --->
	
	<!--- Default function --->
	<cffunction name="index" access="public" output="false">
	
		<!---
			USE SHOULD NEVER BE ABLE TO GET HERE. IF THEY DO, THE CONTROLLER IS MISSING THE INDEX FUNCTION.
			THIS FUNCTION IS ONLY USED FOR TESTING TO INDICATE THAT THE CONTROLLER HAS BEEN SET UP PROPERLY
		--->
		
		<cfset application.error.show_error("Missing index function", "You need to have an index function for controller: #variables.modelName#")>
		
	</cffunction>
	


	<!--- =================================== PRIVATE FUNCTIONS ========================================= --->
	
	
	<!--- Get a model by id --->
	<cffunction name="getById" access="private" returntype="any" output="false">
	
		<cfargument name="modelName" type="string" required="no" hint="When passed in: get this model instead of the current one">
		<cfargument name="getArchived" type="boolean" required="no" default="false" hint="true: get archived model">
		<cfargument name="redirectOnNotFound" type="boolean" required="no" default="true" hint="true: redirect to the list page if the model is not found">
		<cfargument name="listPage" type="string" required="no" hint="The list view page">
		<cfset var thisModelName = "">
		<cfset var objModel = "">
	
		<!--- Get the model name --->
		<cfif StructKeyExists(arguments, "modelName")>
			<cfset thisModelName = arguments.modelName>
		<cfelse>
			<cfset thisModelName = variables.modelName>
		</cfif>
		
		<!--- Set form model ID --->
		<cfif NOT StructKeyExists(form, thisModelName & "Id") AND StructKeyExists(url, thisModelName & "Id")>
			<cfset form[thisModelName & "Id"] = url[thisModelName & "Id"]>
		</cfif>
		
		<!--- Is there a list view specified? --->
		<cfif NOT StructKeyExists(arguments, "listPage")>
			<cfset arguments.listPage = lcase(thisModelName)>
		</cfif>
		
		<!--- Has id? --->
		<cfif NOT StructKeyExists(form, thisModelName & "Id") OR form[thisModelName & "Id"] eq "">
			<cfset application.url.redirect(arguments.listPage)>
		</cfif>
	
		<!--- Get the model details --->
		<cfinvoke component="#application.load#" method="model" returnvariable="objModel">
			<cfinvokeargument name="template" value="#thisModelName#">
			<cfinvokeargument name="id" value="#val(form[thisModelName & 'Id'])#">
			<cfinvokeargument name="getArchived" value="#arguments.getArchived#">
		</cfinvoke>
		
		<!--- Any error in getting the model?--->
		<cfif objModel.error neq "" AND arguments.redirectOnNotFound>
			<cfset application.url.redirectError(arguments.listPage, objModel.error)>
		</cfif>
		
		<cfreturn objModel>
	
	</cffunction>
	
	
	<!--- Get a model by text id --->
	<cffunction name="getByTextId" access="private" returntype="any" output="false">
		
		<cfargument name="modelName" type="string" required="no" hint="When passed in: get this model instead of the current one">
		<cfargument name="getArchived" type="boolean" required="no" default="false" hint="true: get archived model">
		<cfargument name="redirectOnNotFound" type="boolean" required="no" default="true" hint="true: redirect to the list page if the model is not found">
		<cfargument name="listPage" type="string" required="no" hint="The list view page">
		<cfset var thisModelName = "">
		<cfset var objModel = "">
		
		<!--- Get the model name --->
		<cfif StructKeyExists(arguments, "modelName")>
			<cfset thisModelName = arguments.modelName>
		<cfelse>
			<cfset thisModelName = variables.modelName>
		</cfif>
		
		<!--- Set form model text ID --->
		<cfif NOT StructKeyExists(form, thisModelName & "TextId") AND StructKeyExists(url, thisModelName & "TextId")>
			<cfset form[thisModelName & "TextId"] = url[thisModelName & "TextId"]>
		</cfif>
		
		<!--- Is there a list view specified? --->
		<cfif NOT StructKeyExists(arguments, "listPage")>
			<cfset arguments.listPage = lcase(thisModelName)>
		</cfif>

		<!--- Has text id? --->
		<cfif NOT StructKeyExists(form, thisModelName & "TextId") OR form[thisModelName & "TextId"] eq "">
			<cfset application.url.redirect(arguments.listPage)>
		</cfif>
		
		<!--- Get the model details --->
		<cfinvoke component="#application.load#" method="model" returnvariable="objModel">
			<cfinvokeargument name="template" value="#thisModelName#" />
			<cfinvokeargument name="textId" value="#form[thisModelName & 'TextId']#">
			<cfinvokeargument name="getArchived" value="#arguments.getArchived#" />
		</cfinvoke>
		
		<!--- Any error in getting the model? --->
		<cfif objModel.error neq "" AND arguments.redirectOnNotFound>
			<cfset application.url.redirectError(arguments.listPage, objModel.error)>
		</cfif>
		
		<cfreturn objModel>
	
	</cffunction>
	

	<!--- Save a model --->
	<cffunction name="save" access="private">
		<cfargument name="saveButton" type="string" required="no" default="save" hint="The name of the save button">
		<cfargument name="addPage" type="string" required="no" hint="The path of the add page">
		<cfargument name="editPage" type="string" required="no" hint="The path of the edit page">
		<cfargument name="listPage" type="string" required="no" hint="The path of the list page">
		<cfset var addNew = "">
		<cfset var objModel = "">
		<cfset var qModel = "">
		<cfset var qForm = "">
		<cfset var field = "">
		<cfset var saveResult = "">
		
		<!--- Get the default values for pages --->
		<cfif NOT StructKeyExists(arguments, "addPage") OR trim(arguments.addPage) eq "">
			<cfset arguments.addPage = "#variables.modelName#/add">
		</cfif>
		<cfif NOT StructKeyExists(arguments, "editPage") OR trim(arguments.editPage) eq "">
			<cfset arguments.editPage = "#variables.modelName#/edit">
		</cfif>
		<cfif NOT StructKeyExists(arguments, "listPage") OR trim(arguments.listPage) eq "">
			<cfset arguments.listPage = "#variables.modelName#/list">
		</cfif>
	
		<!--- User save? --->
		<cfif StructKeyExists(form, arguments.saveButton)>
			<!--- Add new or save existing? --->
			<cfset addNew = NOT val(form.id)>
		
			<!--- Get model --->
			<cfif addNew>
				<cfset objModel = application.load.model(variables.modelName)>
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
				<cfif isDefined("variables._post_save")>
					<cfset variables._post_save(saveResult)>
				</cfif>
			
				<!--- Add new? --->
				<cfif addNew>
					<cfset application.url.redirect("#arguments.addPage#")>
				<cfelse>
					<cfset application.url.redirect("#arguments.editPage#/#val(qModel.id)#")>
				</cfif>
			<cfelse>
				<!--- Excute a function after save? --->
				<cfif isDefined("variables._post_save")>
					<cfset variables._post_save(saveResult)>
				</cfif>
			
				<!--- Add new? --->
				<cfif addNew>
					<cfset application.url.redirectMessage("#arguments.listPage#", "New #variables.displayName# added.")>
				<cfelse>
					<cfset application.url.redirectMessage("#arguments.editPage#/#val(qModel.id)#", "#application.core.capFirst(variables.displayName)# updated")>
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
		<cfset var objModel = "">
		<cfset var qModel = "">
		<cfset var data = "">
		<cfset var deleteResult = "">
	
		<!--- Get the default values for pages --->
		<cfif NOT StructKeyExists(arguments, "deletePage") OR trim(arguments.deletePage) eq "">
			<cfset arguments.deletePage = "#variables.modelName#/delete">
		</cfif>
		<cfif NOT StructKeyExists(arguments, "listPage") OR trim(arguments.listPage) eq "">
			<cfset arguments.listPage = "#variables.modelName#/list">
		</cfif>
		
		<!--- Is there a list view specified? --->
		<cfif NOT StructKeyExists(arguments, "listPage")>
			<cfset arguments.listPage = lcase(thisModelName)>
		</cfif>

		<!--- Get model --->
		<cfset objModel = getById(listPage=arguments.listPage)>
		<cfset qModel = objModel.get()>
		
		<!--- User delete? --->
		<cfif StructKeyExists(form, arguments.deleteButton)>
			<cfinvoke component="#objModel#" method="delete" returnvariable="deleteResult">
			
			<!--- Excute a function after delete? --->
			<cfif isDefined("variables._post_delete")>
				<cfset variables._post_delete(deleteResult)>
			</cfif>
			
			<cfif arrayLen(deleteResult.errorList)>
				<cfset session.errorList = deleteResult.errorList>
				<cfset application.url.redirect("#arguments.listPage#")>
			<cfelse>
				<cfset application.url.redirectMessage("#arguments.listPage#", "#application.output.capFirst(variables.displayName)# '#qModel[arguments.titleField][1]#' deleted")>
			</cfif>
		</cfif>
		
		<!--- User cancel? --->
		<cfif StructKeyExists(form, arguments.cancelButton)>
			<cfset application.url.redirect("#arguments.listPage#")>
		</cfif>
		
		<!--- Display view? --->
		<cfif arguments.displayView>
			<cfset data = StructNew()>
			<cfset data.heading = "Delete #variables.displayName#: #qModel[arguments.titleField][1]#">
			<cfset data["q#variables.modelName#"] = qModel>
			<cfset application.load.viewInTemplate("#arguments.deletePage#", data, objModel.fields)>
		</cfif>
	
	</cffunction>
	
</cfcomponent>