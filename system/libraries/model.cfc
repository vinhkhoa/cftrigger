<!---
	Project:		cfTrigger
	Company:		cfTrigger
	Summary:		Main Model class
	
	Log:
	
	Created:		05/06/2009
	
	Modified:
	- 

--->

<cfcomponent displayname="Model" hint="Main Model class">

	<cfsetting enablecfoutputonly="yes">


	<!--- MODEL VARIABLES --->
	<cfscript>
		This.wheres = StructNew();
		This.where_list = StructNew();
		This.recordUpdatorId = true;
		This.ranValidation = false;
		This.validationResult = "";
		This.properties = StructNew();
		
		// Fields
		This.createdField = "created";
		This.creatorIdField = "creatorId";
		This.modifiedField = "modified";
		This.modifierIdField = "modifierId";
		This.archivedField = "archived";
		This.archiverIdField = "archiverId";
		This.orderby = "id DESC";
		This.textIdField = "textId";
		This.hasOnes = "";
		This.hasManys = "";
		This.tableName = "";
		This.error = "";
	</cfscript>
	
	
	<!--- Initialize model --->
	<cffunction name="init" access="public">
		
		<cfargument name="userId" type="numeric" required="no" default="0" hint="ID of the user">
		<cfargument name="id" type="numeric" required="no" hint="ID of the model object">
		<cfargument name="textId" type="string" required="no" hint="text ID of the model object">
		<cfargument name="getArchived" type="boolean" required="no" default="false" hint="true: get archived model">
		<cfargument name="properties" type="struct" required="no" default="#StructNew()#" hint="Pass in some extra properties for this model">
		
		<cfset variables.userId = val(arguments.userId)>
		<cfset variables.getArchived = arguments.getArchived>
		
		<!--- Record this id --->
		<cfif StructKeyExists(arguments, "id")>
			<cfset variables.id = val(arguments.id)>
			<cfset this.id = val(arguments.id)>
		</cfif>
		
		<!--- Record this text id --->
		<cfif StructKeyExists(arguments, "textId")>
			<cfset variables.textId = arguments.textId>
		</cfif>
		
		<!--- Model metadata --->
		<cfset this.metaData = getMetaData(this)>
		<cfset this.modelName = lcase(listLast(this.metaData.name, '.'))>
				
		<!--- Table name for this model --->
		<cfif NOT len(trim(this.tableName))>
			<cfset This.tableName = application.utils.plural(this.modelName)>
		</cfif>
		
		<!--- Some extra properties for this model --->
		<cfloop collection="#arguments.properties#" item="i">
			<cfset this.properties[i] = arguments.properties[i]>
		</cfloop>

		<cfif (StructKeyExists(arguments, "id") OR StructKeyExists(arguments, "textId"))>
			<!--- Get the model details and force it to refresh as user initializes the model --->
			<cfset this.query = this.get(true)>
			
			<cfif this.query.recordCount>
				<!--- A record is found, update this model id --->
				<cfset variables.id = this.query.id>
				<cfset this.id = this.query.id>
			<cfelse>
				<cfset this.error = "The #lcase(this.modelName)# is not found">
			</cfif>
		</cfif>
		
		<cfreturn This>
		
	</cffunction>
	
	
	<!--- Add/update model --->
	<cffunction name="save" displayname="save" access="public" returntype="struct" hint="Add/update model">
	
		<cfargument name="fieldCollection" type="struct" required="no" hint="Collection of fields">		
		<cfargument name="ignoreMissingFields" type="boolean" required="no" default="false" hint="true: ignore fields that are not passed in. Only validate those that were passed.">		
		<cfset var result = StructNew()>
		<cfset result.errorList = ArrayNew(1)>
		<cfset result.newId = "">
		<cfset result.newTextId = "">
		
		<!--- Passing a whole field collection or individual fields? --->
		<cfif StructKeyExists(arguments, "fieldCollection")>
			<cfset fieldValues = arguments.fieldCollection>
		<cfelse>
			<cfset fieldValues = arguments>
		</cfif>
		
		<cfif arguments.ignoreMissingFields>
			<!--- As missing fields are ignored, get the new list of fields that are actually affected this time --->
			<cfset fieldList = ArrayNew(1)>
			<cfloop array="#this.fields#" index="field">
				<cfif StructKeyExists(fieldValues, field.name)>
					<cfset arrayAppend(fieldList, field)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset fieldList = this.fields>
		</cfif>
				
		<!--- Validate the values --->
		<cfif This.ranValidation>
			<cfset validateResult.errorList = this.validationResult.errorList>
		<cfelse>
			<cfset objValidation = application.load.library('validation').init(this)>
			<cfset validateResult = objValidation.run(fieldValues, fieldList)>
		</cfif>
		
		<cfif ArrayLen(validateResult.errorList)>
			<cfset result.errorList = validateResult.errorList>
		<cfelse>
			<cfif StructKeyExists(variables, "id")>
				<!--- Update the model --->
				<cfquery name="qUpdate" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
					UPDATE #this.tableName#
					SET
						<cfloop array="#fieldList#" index="field">
							<cfif StructKeyExists(fieldValues, field.name)>
								<cfif listFindNoCase("bigint,bit,decimal,double,float,integer,numeric,real,smallint", field.type)>
									#field.name# = <cfqueryparam value="#val(fieldValues[field.name])#" cfsqltype="cf_sql_#field.type#">, 
								<cfelse>
									#field.name# = <cfqueryparam value="#fieldValues[field.name]#" cfsqltype="cf_sql_#field.type#">, 
								</cfif>
							</cfif>
						</cfloop>
						#This.modifiedField# = <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP">
						
						<!--- Record the person who makes this change? --->
						<cfif This.recordUpdatorId>
							, #This.modifierIdField# = <cfqueryparam value="#val(variables.userId)#" cfsqltype="CF_SQL_INTEGER">
						</cfif>
					WHERE
						id = <cfqueryparam value="#val(variables.id)#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				
				<cfset result.newId = variables.id>
				<cfif StructKeyExists(variables, "textId")>
					<cfset result.newTextId = variables.textId>
				</cfif>
			<cfelse>
				<!--- Add the model --->
				<cfquery name="qAdd" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
					INSERT INTO #this.tableName# (
						<cfloop array="#fieldList#" index="field">
							<cfif StructKeyExists(fieldValues, field.name)>
								#field.name#, 
							</cfif>
						</cfloop>
						#This.createdField#

						<!--- Record the person who makes this change? --->
						<cfif This.recordUpdatorId>
							, #This.creatorIdField#
						</cfif>
						)
					VALUES
					(
						<cfloop array="#fieldList#" index="field">
							<cfif StructKeyExists(fieldValues, field.name)>
								<cfif listFindNoCase("bigint,bit,decimal,double,float,integer,numeric,real,smallint", field.type)>
									<cfqueryparam value="#val(fieldValues[field.name])#" cfsqltype="cf_sql_#field.type#">, 
								<cfelse>
									<cfqueryparam value="#fieldValues[field.name]#" cfsqltype="cf_sql_#field.type#">, 
								</cfif>
							</cfif>
						</cfloop>
						<cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP">

						<!--- Record the person who makes this change? --->
						<cfif This.recordUpdatorId>
							, <cfqueryparam value="#val(variables.userId)#" cfsqltype="CF_SQL_INTEGER">
						</cfif>
					)
					
					<!--- Get the latest insert id for MS SQL --->
					<cfif application.dbIsMSSQL>
						SELECT @@IDENTITY AS 'newId'
					</cfif>
				</cfquery>
				
				<!--- GET THE LAST INSERTED ID FOR MY SQL AND ORACLE --->
				<cfif application.dbIsMySQL OR application.dbIsOracle>
					<cfquery name="qAdd" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
						SELECT LAST_INSERT_ID() AS 'newId'
					</cfquery>
				</cfif>
				
				<cfset result.newId = qAdd.newId>
				<cfif StructKeyExists(fieldValues, This.textIdField)>
					<cfset result.newTextId = fieldValues[This.textIdField]>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Delete a model --->
	<cffunction name="delete" displayname="delete" access="public" returntype="struct" hint="Delete a model">
		
		<cfset var result = StructNew()>
		<cfset result.errorList = ArrayNew(1)>

		<!--- Is there any model to delete? --->
		<cfif StructKeyExists(variables, "id")>
			<cfquery name="qDelete" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
				UPDATE #this.tableName#
				SET
					#this.archivedField# = <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP">

					<!--- Record the person who makes this change? --->
					<cfif This.recordUpdatorId>
						, #this.archiverIdField# = <cfqueryparam value="#val(variables.userId)#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
				WHERE id = <cfqueryparam value="#val(variables.id)#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfset ArrayAppend(result.errorList, "There is no #this.modelName# to delete")>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Get a model details --->
	<cffunction name="get" displayname="get" access="public" returntype="query" hint="Get a model details">
		
		<cfargument name="refresh" type="boolean" required="no" default="false" hint="true: force refresh the query">
		
		<cfif NOT isDefined("this.query") OR arguments.refresh>
			<!--- Get this record details --->
			<cfinvoke method="getAll" returnvariable="qDetails">
				<!--- No id or text id passed in? => Get a blank record --->
				<cfif NOT StructKeyExists(variables, "id") AND NOT StructKeyExists(variables, "textId")>
					<cfinvokeargument name="id" value="-9999">
				<cfelse>
					<!--- Limit by id? --->
					<cfif StructKeyExists(variables, "id")>
						<cfinvokeargument name="id" value="#val(variables.id)#">
					</cfif>
					
					<!--- Limit by text id? --->
					<cfif StructKeyExists(variables, "textId")>
						<cfinvokeargument name="textId" value="#variables.textId#">
					</cfif>

					<cfinvokeargument name="getArchived" value="#variables.getArchived#">
				</cfif>
			</cfinvoke>
			
			<cfreturn qDetails>		
		<cfelse>
			<cfreturn this.query>
		</cfif>
		
	</cffunction>
	

	<!--- Get the list of models --->
	<cffunction name="getAll" displayname="getAll" access="public" returntype="query" hint="Get the list of models">
		
		<cfargument name="id" type="numeric" required="no" hint="Limit to a particular record by its id">
		<cfargument name="textId" type="string" required="no" hint="Limit to a particular record by its text id">
		<cfargument name="getArchived" type="boolean" required="no" default="false" hint="true: get archived model">
		
		<cfset metaData = getMetaData(this)>
		<cfset thisModelName = lcase(listLast(metaData.name, '.'))>
		
		<!--- Get the list of models --->
		<cfquery name="qList" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
			SELECT *
			FROM #this.tableName#
			WHERE 1 = 1
				
				<!--- Get archived model? --->
				<cfif arguments.getArchived>
					AND #this.archivedField# IS NOT NULL
				<cfelse>
					AND #this.archivedField# IS NULL
				</cfif>
				
				<cfloop collection="#This.wheres#" item="field">
					AND #field# = <cfqueryparam value="#This.wheres[field]#" />
				</cfloop>
			
				<cfloop collection="#This.where_list#" item="field">
					AND #field# IN (<cfqueryparam value="#This.where_list[field]#" list="yes" />)
				</cfloop>
			
				<!--- Limit to a particular record --->
				<cfif StructKeyExists(arguments, "id") AND val(arguments.id)>
					AND id = <cfqueryparam value="#val(arguments.id)#" cfsqltype="cf_sql_integer" />
				</cfif>
				
				<cfif StructKeyExists(arguments, "textId") AND trim(arguments.textId) neq "">
					AND #this.textIdField# = <cfqueryparam value="#trim(arguments.textId)#" cfsqltype="cf_sql_varchar" />
				</cfif>
			  
			<cfif isDefined("this.orderby")>
				ORDER BY #this.orderby#
			</cfif>
		</cfquery>
		
		<!--- Reset the where clauses --->
		<cfset StructClear(this.wheres)>
		<cfset StructClear(this.where_list)>

		<cfreturn qList>

	</cffunction>

	
	<!--- Set the where condition for this model --->
	<cffunction name="where" displayname="where" access="public" hint="Set the where condition for this model">
	
		<cfargument name="field" type="string" required="yes" hint="The where field">
		<cfargument name="value" type="string" required="yes" hint="The where value">
		
		<cfset this.wheres[arguments.field] = arguments.value>
		
		<cfreturn this>
	
	</cffunction>
		

	<!--- Reset all WHERE/filter conditions --->
	<cffunction name="resetWhere" displayname="resetWhere" access="private" hint="">
	
		<!--- Reset the where clauses --->
		<cfset StructClear(this.wheres)>
		<cfset StructClear(this.where_list)>
	
	</cffunction>
	

	<!--- Get the list of all models including both active and archived ones --->
	<cffunction name="getAllIncludingArchived" displayname="getAllIncludingArchived" access="public" returntype="query" hint="Get the list of models">
		<cfargument name="id" type="numeric" required="no" hint="Limit to a particular record by its id">
		<cfargument name="textId" type="string" required="no" hint="Limit to a particular record by its text id">

		<!--- Get the list of active models --->
		<cfinvoke method="getAll" returnvariable="qActive">
			<cfif StructKeyExists(arguments, "id")>
				<cfinvokeargument name="id" value="#arguments.id#">
			</cfif>
			<cfif StructKeyExists(arguments, "textId")>
				<cfinvokeargument name="textId" value="#arguments.textId#">
			</cfif>
		</cfinvoke>
		
		<!--- Get the list of archived models --->
		<cfinvoke method="getAll" returnvariable="qArchived">
			<cfif StructKeyExists(arguments, "id")>
				<cfinvokeargument name="id" value="#arguments.id#">
			</cfif>
			<cfif StructKeyExists(arguments, "textId")>
				<cfinvokeargument name="textId" value="#arguments.textId#">
			</cfif>
			<cfinvokeargument name="getArchived" value="true">
		</cfinvoke>
		
		<!--- Combine the 2 results --->
		<cfquery name="qList" dbtype="query">
			SELECT *
			FROM qActive
			
			UNION
			
			SELECT *
			FROM qArchived
			
			<cfif isDefined("this.orderby")>
				ORDER BY #this.orderby#
			</cfif>
		</cfquery>
		
		<cfreturn qList>
	</cffunction>
	
	
	<!--- Undelete a model --->
	<cffunction name="undelete" displayname="undelete" access="public" returntype="struct" hint="Undelete a model">
		
		<cfset var result = StructNew()>
		<cfset result.errorList = ArrayNew(1)>

		<!--- Is there any model to undelete? --->
		<cfif StructKeyExists(variables, "id")>
			<cfquery name="qDelete" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
				UPDATE #this.tableName#
				SET
					#this.archivedField# = NULL

					<!--- Record the person who makes this change? --->
					<cfif This.recordUpdatorId>
						, #this.archiverIdField# = NULL
					</cfif>
				WHERE id = <cfqueryparam value="#val(variables.id)#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfset ArrayAppend(result.errorList, "There is no #this.modelName# to undelete")>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Actually delete a model --->
	<cffunction name="hardDelete" displayname="hardDelete" access="public" returntype="struct" hint="Actually delete a model">
		
		<cfset var result = StructNew()>
		<cfset result.errorList = ArrayNew(1)>

		<!--- Is there any model to delete? --->
		<cfif StructKeyExists(variables, "id")>
			<cfquery name="qDelete" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
				DELETE FROM #this.tableName#
				WHERE id = <cfqueryparam value="#val(variables.id)#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfset ArrayAppend(result.errorList, "There is no #this.modelName# to delete")>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Update relationship with another model --->
	<cffunction name="updateRelationship" displayname="updateRelationship" access="public" returntype="struct" hint="Update relationship with another model">
		<cfargument name="relatedTableName" type="string" required="yes" hint="The related table name">
		<cfargument name="fieldName" type="string" required="yes" hint="The field name of this model inside the related table">
		<cfargument name="relatedFieldName" type="string" required="yes" hint="The field name of the related model inside the related table">
		<cfargument name="relatedIds" type="string" required="yes" hint="The related model ids">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<!--- Remove old relationships --->
		<cfquery name="qDeleteOld" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
			DELETE FROM #arguments.relatedTableName#
			WHERE #arguments.fieldName# = <cfqueryparam value="#val(variables.id)#" cfsqltype="cf_sql_integer">
				<cfif listLen(arguments.relatedIds)> 
					AND #arguments.relatedFieldName# NOT IN (<cfqueryparam value="#arguments.relatedIds#" list="yes" cfsqltype="cf_sql_integer">)
				</cfif>
		</cfquery>
		
		<!--- Anything to add back in? --->
		<cfif listLen(arguments.relatedIds)>
			<!--- Find new relationships --->
			<cfquery name="qExisting" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
				SELECT #arguments.relatedFieldName# AS modelId
				FROM #arguments.relatedTableName#
				WHERE #arguments.fieldName# = <cfqueryparam value="#val(variables.id)#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset newIds = application.core.listMinus(arguments.relatedIds, valueList(qExisting.modelId))>
			
			<!--- Insert new relationships --->
			<cfif listLen(newIds)>
				<cfset total = listLen(newIds)>
			
				<cfquery name="qAddNew" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
					INSERT INTO #arguments.relatedTableName# 
					(
						#arguments.fieldName#, #arguments.relatedFieldName#, #This.createdField#
	
						<!--- Record the person who makes this change? --->
						<cfif This.recordUpdatorId>
							, #This.creatorIdField#
						</cfif>
					)
	
					<!--- Add multiple relationships at once --->
					<cfloop from="1" to="#total#" index="i">
						(
							SELECT
							
							<cfqueryparam value="#val(variables.id)#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#val(listGetAt(newIds, i))#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP">
	
							<!--- Record the person who makes this change? --->
							<cfif This.recordUpdatorId>
								, <cfqueryparam value="#val(variables.userId)#" cfsqltype="CF_SQL_INTEGER">
							</cfif>
						)
						
						<cfif i lt total>UNION</cfif>
					</cfloop>
				</cfquery>
			</cfif>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	

	<!--- Clear this model current state --->
	<cffunction name="clear" displayname="clear" access="public" returntype="struct" hint="Clear this model current state">
		
		<cfset var result = StructNew()>
		<cfset result.errorList = ArrayNew(1)>
		
		<cfset this.ranValidation = false>
		<cfset this.error = "">
		<cfset StructDelete(variables, "id")>
		<cfset StructDelete(variables, "textId")>
		<cfset StructDelete(this, "id")>
		<cfset StructDelete(this, "textId")>
		
		<cfreturn result>
	
	</cffunction>
			

</cfcomponent>