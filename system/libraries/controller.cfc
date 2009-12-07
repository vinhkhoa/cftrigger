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
	
	
	<!---
	
	<!--- Add --->
	<cffunction name="add" access="public">
		
		<cfset metaData = getMetaData(this)>
		<cfset modelName = metaData.displayName>
		
		<!--- Get the model --->
		<cfset request[modelName] = application.load.model(modelName)>

		<!--- Get the new blank model --->
		<cfset q = request[modelName].get()>
		
		<!--- User add the model? --->
		<cfif form.action eq "add">
			<cfinvoke component="#request[modelName]#" method="save" returnvariable="addResult">
				<cfloop array="#request[modelName].fields#" index="field">
					<cfif StructKeyExists(form, field.name)>
						<cfinvokeargument name="#field.name#" value="#form[field.name]#">
					</cfif>
				</cfloop>
			</cfinvoke>
			
			<cfif len(addResult.error)>
				<cfset session.errorList = addResult.error>
				
				<!--- Retain values on the form --->
				<cfset QueryAddRow(q, 1)>
				<cfloop array="#request[modelName].fields#" index="field">
					<cfif StructKeyExists(form, field.name)>
						<cfset QuerySetCell(q, field.name, form[field.name], q.recordCount)>
					</cfif>
				</cfloop>
			<cfelse>
				<cfset application.url.redirectMessage(lcase(modelName), "New #modelName# has been added") />
			</cfif>
		</cfif>
		
		<!--- Display the view --->
		<cfset data = StructNew()>
		<cfset data["q" & modelName] = q>
		
		<!--- Call extra function for this model? --->
		<cfif isDefined("this._add_extra")>
			<cfinvoke method="_add_extra" returnvariable="extraData" />
			<cfset StructAppend(data, extraData)>
		</cfif>
		
		<cfset data.heading = "Add new #modelName#">		
		<cfset application.load.viewInTemplate("#lcase(modelName)#/add", data)>
	</cffunction>
	

	<!--- Edit --->
	<cffunction name="edit" access="public">
		
		<cfset metaData = getMetaData(this)>
		<cfset modelName = metaData.displayName>
		<cfset modelId = val(form[modelName & "Id"])>
		
		<!--- Get the model details --->
		<cfset request[modelName] = application.load.model(modelName, modelId)>
		
		<!--- Any error in getting the model?--->
		<cfif request[modelName].error eq "">
			<cfset q = request[modelName].get()>
			
			<!--- User updates the model? --->
			<cfif form.action eq "save">
				<cfinvoke component="#request[modelName]#" method="save" returnvariable="updateResult">
					<cfinvokeargument name="id" value="#modelId#">
					<cfloop array="#request[modelName].fields#" index="field">
						<cfif StructKeyExists(form, field.name)>
							<cfinvokeargument name="#field.name#" value="#form[field.name]#">
						</cfif>
					</cfloop>
				</cfinvoke>
				
				<cfif len(updateResult.error)>
					<cfset session.errorList = updateResult.error>
					
					<!--- Retain values on the form --->
					<cfloop array="#request[modelName].fields#" index="field">
						<cfif StructKeyExists(form, field.name)>
							<cfset value = form[field.name]>
						<cfelse>
							<cfset value = "">
						</cfif>
						<cfset QuerySetCell(q, field.name, value, q.recordCount)>
					</cfloop>
				<cfelse>
					<cfset application.url.redirectMessage("#lcase(modelName)#/edit/#modelId#", "#modelName# has been updated") />
				</cfif>
			</cfif>
			
			<!--- Display the view --->
			<cfset data = StructNew()>
			<cfset data["q" & modelName] = q>

			<!--- Call extra function for this model? --->
			<cfif isDefined("this._edit_extra")>
				<cfinvoke method="_add_extra" returnvariable="extraData" />
				<cfset StructAppend(data, extraData)>
			</cfif>
			
			<cfset data.heading = "Edit #modelName#">		
			<cfset application.load.viewInTemplate("#lcase(modelName)#/edit", data)>
		<cfelse>
			<cfset application.url.redirectError(lcase(modelName), request[modelName].error)>
		</cfif>
		
	</cffunction>
	

	<!--- Delete the model --->
	<cffunction name="delete" access="public">
	
		<cfset metaData = getMetaData(this)>
		<cfset modelName = metaData.displayName>
		<cfset modelId = val(form[modelName & "Id"])>
		
		<!--- Get the model details --->
		<cfset request[modelName] = application.load.model(modelName, modelId)>
		
		<!--- Any error in getting the model?--->
		<cfif request[modelName].error eq "">
			<cfset q = request[modelName].get()>
			
			<!--- User cancels the delete --->
			<cfif form.action eq "cancel">
				<cflocation url="#application.baseURL#/#modelName#" addtoken="no" />
			</cfif>
		
			<!--- User deletes the model? --->
			<cfif form.action eq "delete">
				<cfinvoke component="#request[modelName]#" method="delete" returnvariable="deleteResult">
					<cfinvokeargument name="id" value="#val(modelId)#">
				</cfinvoke>
				
				<cfif len(deleteResult.error)>
					<cfset application.url.redirectError("#lcase(modelName)#/delete/#modelId#", deleteResult.error) />
				<cfelse>
					<cfset application.url.redirectMessage(lcase(modelName), "#modelName# has been deleted") />
				</cfif>
			</cfif>
			
			<!--- Display the view --->
			<cfset data = StructNew()>
			<cfset data["q" & modelName] = q>

			<!--- Call extra function for this model? --->
			<cfif isDefined("this._delete_extra")>
				<cfinvoke method="_delete_extra" returnvariable="extraData" />
				<cfset StructAppend(data, extraData)>
			</cfif>
			
			<cfset data.heading = "Delete #modelName#">		
			<cfset application.load.viewInTemplate("#lcase(modelName)#/delete", data)>
		<cfelse>
			<cfset application.url.redirectError(lcase(modelName), request[modelName].error)>
		</cfif>
		
	</cffunction>
		

	<!--- List models --->
	<cffunction name="list" access="public">
	
		<cfset metaData = getMetaData(this)>
		<cfset modelName = metaData.displayName>
		<cfset plural = application.utils.plural(modelName)>
		
		<!--- Get the model --->
		<cfset request[modelName] = application.load.model(modelName)>
		
		<cfset data = StructNew()>
		<cfset data["q" & plural] = request[modelName].getAll()>
		
		<!--- Call extra function for this model? --->
		<cfif isDefined("this._list_extra")>
			<cfset extraData = this._list_extra(data)>
			<cfset StructAppend(data, extraData)>
		</cfif>

		<!--- Display the view --->
		<cfset data.heading = "#uCase(left(plural, 1)) & right(plural, len(plural) - 1)#">		
		<cfset application.load.viewInTemplate("#lcase(modelName)#/list", data)>
		
	</cffunction>
	

	<!--- View --->
	<cffunction name="view" access="public">
	
		<cfset metaData = getMetaData(this)>
		<cfset modelName = metaData.displayName>
		<cfset modelId = val(form[modelName & "Id"])>
		<cfset modelTextId = form[modelName & "TextId"]>
		
		<!--- Get the model details --->
		<cfset request[modelName] = application.load.model(modelName, modelId, modelTextId)>
		
		<!--- Any error in getting the model?--->
		<cfif request[modelName].error eq "">
			<cfset q = request[modelName].get()>
			
			<!--- Display the view --->
			<cfset data = StructNew()>
			<cfset data["q" & modelName] = q>

			<!--- Call extra function for this model? --->
			<cfif isDefined("this._view_extra")>
				<cfinvoke method="_view_extra" returnvariable="extraData" />
				<cfset StructAppend(data, extraData)>
			</cfif>
			
			<cfset data.heading = "View #modelName#">		
			<cfset application.load.viewInTemplate("#lcase(modelName)#/view", data)>
		<cfelse>
			<cfset application.url.redirectError(lcase(modelName), request[modelName].error)>
		</cfif>
		
	</cffunction>
	--->
		
</cfcomponent>