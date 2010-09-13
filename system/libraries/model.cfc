<!---
	Project:		cfTrigger
	Summary:		Main Model class
	
	Log:
	
	Created:		05/06/2009
	
	Modified:
	- 

--->

<cfcomponent displayname="Model" hint="Main Model class" output="false">

	<cfsetting enablecfoutputonly="yes">


	<!--- MODEL VARIABLES --->
	<cfscript>
		variables.wheres = StructNew();
		variables.where_list = StructNew();
		variables.recordUpdatorId = true;
		variables.ranValidation = false;
		variables.validationResult = "";
		variables.properties = StructNew();
		
		// Fields
		variables.createdField = "created";
		variables.creatorIdField = "creatorId";
		variables.modifiedField = "modified";
		variables.modifierIdField = "modifierId";
		variables.archivedField = "archived";
		variables.archiverIdField = "archiverId";
		variables.orderby = "id DESC";
		variables.textIdField = "textId";
		variables.hasOnes = "";
		variables.hasManys = "";
		variables.tableName = "";
		This.error = "";
	</cfscript>
	
	
	<!--- Initialize model --->
	<cffunction name="init" access="public" output="false">
		
		<cfargument name="userId" type="numeric" required="no" default="0" hint="ID of the user">
		<cfargument name="id" type="numeric" required="no" hint="ID of the model object">
		<cfargument name="textId" type="string" required="no" hint="text ID of the model object">
		<cfargument name="getArchived" type="boolean" required="no" default="false" hint="true: get archived model">
		<cfargument name="properties" type="struct" required="no" default="#StructNew()#" hint="Pass in some extra properties for this model">
		<cfset var item = "">
		
		<cfset variables.userId = val(arguments.userId)>
		<cfset variables.getArchived = arguments.getArchived>
		
		<!--- Record this id --->
		<cfif StructKeyExists(arguments, "id")>
			<cfset variables.id = val(arguments.id)>
			<cfset This.id = val(arguments.id)>
		</cfif>
		
		<!--- Record this text id --->
		<cfif StructKeyExists(arguments, "textId")>
			<cfset variables.textId = arguments.textId>
		</cfif>
		
		<!--- Model metadata --->
		<cfset variables.metaData = getMetaData(this)>
		<cfset variables.modelName = lcase(listLast(variables.metaData.name, '.'))>
				
		<!--- Table name for this model --->
		<cfif NOT len(trim(variables.tableName))>
			<cfset variables.tableName = application.utils.plural(variables.modelName)>
		</cfif>
		
		<!--- Some extra properties for this model --->
		<cfloop collection="#arguments.properties#" item="item">
			<cfset variables.properties[item] = arguments.properties[item]>
		</cfloop>

		<cfif (StructKeyExists(arguments, "id") OR StructKeyExists(arguments, "textId"))>
			<!--- Get the model details and force it to refresh as user initializes the model --->
			<cfset variables.query = variables.get(true)>
			
			<cfif variables.query.recordCount>
				<!--- A record is found, update this model id --->
				<cfset variables.id = variables.query.id>
				<cfset This.id = variables.query.id>
			<cfelse>
				<cfset This.error = "The #lcase(variables.modelName)# is not found">
			</cfif>
		</cfif>
		
		<cfreturn This>
		
	</cffunction>
	
	
	<!--- Add/update model --->
	<cffunction name="save" displayname="save" access="public" returntype="struct" hint="Add/update model" output="false">
	
		<cfargument name="fieldCollection" type="struct" required="no" hint="Collection of fields">		
		<cfargument name="ignoreMissingFields" type="boolean" required="no" default="false" hint="true: ignore fields that are not passed in. Only validate those that were passed.">		
		<cfset var result = StructNew()>
		<cfset var fieldValues = "">
		<cfset var fieldList = "">
		<cfset var validateResult = "">
		<cfset var objValidation = "">
		<cfset var field = "">
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
			<cfloop array="#This.fields#" index="field">
				<cfif StructKeyExists(fieldValues, field.name)>
					<cfset arrayAppend(fieldList, field)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset fieldList = This.fields>
		</cfif>
				
		<!--- Validate the values --->
		<cfif variables.ranValidation>
			<cfset validateResult.errorList = variables.validationResult.errorList>
		<cfelse>
			<cfset objValidation = application.load.library("validation").init(this)>
			<cfset validateResult = objValidation.run(fieldValues, fieldList)>
		</cfif>
		
		<cfif ArrayLen(validateResult.errorList)>
			<cfset result.errorList = validateResult.errorList>
		<cfelse>
			<cfif StructKeyExists(variables, "id")>
				<!--- Update the model --->
				<cfquery name="qUpdate" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
					UPDATE #variables.tableName#
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
						#variables.modifiedField# = <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP">
						
						<!--- Record the person who makes this change? --->
						<cfif variables.recordUpdatorId>
							, #variables.modifierIdField# = <cfqueryparam value="#val(variables.userId)#" cfsqltype="CF_SQL_INTEGER">
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
					INSERT INTO #variables.tableName# (
						<cfloop array="#fieldList#" index="field">
							<cfif StructKeyExists(fieldValues, field.name)>
								#field.name#, 
							</cfif>
						</cfloop>
						#variables.createdField#

						<!--- Record the person who makes this change? --->
						<cfif variables.recordUpdatorId>
							, #variables.creatorIdField#
						</cfif>
						)
					VALUES
					(
						<cfloop array="#fieldList#" index="field">
							<cfif StructKeyExists(fieldValues, field.name)>
								<cfif listFindNoCase("bigint,bit,decimal,double,float,integer,numeric,real,smallint,timestamp", field.type)>
									<cfqueryparam value="#val(fieldValues[field.name])#" cfsqltype="cf_sql_#field.type#">, 
								<cfelse>
									<cfqueryparam value="#fieldValues[field.name]#" cfsqltype="cf_sql_#field.type#">, 
								</cfif>
							</cfif>
						</cfloop>
						<cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP">

						<!--- Record the person who makes this change? --->
						<cfif variables.recordUpdatorId>
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
				<cfif StructKeyExists(fieldValues, variables.textIdField)>
					<cfset result.newTextId = fieldValues[variables.textIdField]>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Delete a model --->
	<cffunction name="delete" displayname="delete" access="public" returntype="struct" hint="Delete a model" output="false">
		
		<cfset var result = StructNew()>
		<cfset result.errorList = ArrayNew(1)>

		<!--- Is there any model to delete? --->
		<cfif StructKeyExists(variables, "id")>
			<cfquery name="qDelete" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
				UPDATE #variables.tableName#
				SET
					#variables.archivedField# = <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP">

					<!--- Record the person who makes this change? --->
					<cfif variables.recordUpdatorId>
						, #variables.archiverIdField# = <cfqueryparam value="#val(variables.userId)#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
				WHERE id = <cfqueryparam value="#val(variables.id)#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfset ArrayAppend(result.errorList, "There is no #variables.modelName# to delete")>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Get a model details --->
	<cffunction name="get" displayname="get" access="public" returntype="query" hint="Get a model details" output="false">
		
		<cfargument name="refresh" type="boolean" required="no" default="false" hint="true: force refresh the query">
		<cfset var qDetails = "">
		
		<cfif NOT StructKeyExists(variables, "query") OR arguments.refresh>
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
			<cfreturn variables.query>
		</cfif>
		
	</cffunction>
	

	<!--- Get the list of models --->
	<cffunction name="getAll" displayname="getAll" access="public" returntype="query" hint="Get the list of models" output="false">
		
		<cfargument name="id" type="numeric" required="no" hint="Limit to a particular record by its id">
		<cfargument name="textId" type="string" required="no" hint="Limit to a particular record by its text id">
		<cfargument name="getArchived" type="boolean" required="no" default="false" hint="true: get archived model">
		<cfset var field = "">
		
		<!--- Get the list of models --->
		<cfquery name="qList" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
			SELECT *
			FROM #variables.tableName#
			WHERE 1 = 1
				
				<!--- Get archived model? --->
				<cfif arguments.getArchived>
					AND #variables.archivedField# IS NOT NULL
				<cfelse>
					AND #variables.archivedField# IS NULL
				</cfif>
				
				<cfloop collection="#variables.wheres#" item="field">
					AND #field# = <cfqueryparam value="#variables.wheres[field]#" />
				</cfloop>
			
				<cfloop collection="#variables.where_list#" item="field">
					AND #field# IN (<cfqueryparam value="#variables.where_list[field]#" list="yes" />)
				</cfloop>
			
				<!--- Limit to a particular record --->
				<cfif StructKeyExists(arguments, "id") AND val(arguments.id)>
					AND id = <cfqueryparam value="#val(arguments.id)#" cfsqltype="cf_sql_integer" />
				</cfif>
				
				<cfif StructKeyExists(arguments, "textId") AND trim(arguments.textId) neq "">
					AND #variables.textIdField# = <cfqueryparam value="#trim(arguments.textId)#" cfsqltype="cf_sql_varchar" />
				</cfif>
			  
			<cfif isDefined("variables.orderby")>
				ORDER BY #variables.orderby#
			</cfif>
		</cfquery>
		
		<!--- Reset the where clauses --->
		<cfset StructClear(variables.wheres)>
		<cfset StructClear(variables.where_list)>

		<cfreturn qList>

	</cffunction>

	
	<!--- Set the where condition for this model --->
	<cffunction name="where" displayname="where" access="public" hint="Set the where condition for this model" output="false">
	
		<cfargument name="field" type="string" required="yes" hint="The where field">
		<cfargument name="value" type="string" required="yes" hint="The where value">
		
		<cfset variables.wheres[arguments.field] = arguments.value>
		
		<cfreturn this>
	
	</cffunction>
		

	<!--- Reset all WHERE/filter conditions --->
	<cffunction name="resetWhere" displayname="resetWhere" access="private" hint="" output="false">
	
		<!--- Reset the where clauses --->
		<cfset StructClear(variables.wheres)>
		<cfset StructClear(variables.where_list)>
	
	</cffunction>
	

	<!--- Get the list of all models including both active and archived ones --->
	<cffunction name="getAllIncludingArchived" displayname="getAllIncludingArchived" access="public" returntype="query" hint="Get the list of models" output="false">
		<cfargument name="id" type="numeric" required="no" hint="Limit to a particular record by its id">
		<cfargument name="textId" type="string" required="no" hint="Limit to a particular record by its text id">
		<cfset var qActive = "">
		<cfset var qArchived = "">

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
			
			<cfif isDefined("variables.orderby")>
				ORDER BY #variables.orderby#
			</cfif>
		</cfquery>
		
		<cfreturn qList>
	</cffunction>
	
	
	<!--- Undelete a model --->
	<cffunction name="undelete" displayname="undelete" access="public" returntype="struct" hint="Undelete a model" output="false">
		
		<cfset var result = StructNew()>
		<cfset result.errorList = ArrayNew(1)>

		<!--- Is there any model to undelete? --->
		<cfif StructKeyExists(variables, "id")>
			<cfquery name="qDelete" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
				UPDATE #variables.tableName#
				SET
					#variables.archivedField# = NULL

					<!--- Record the person who makes this change? --->
					<cfif variables.recordUpdatorId>
						, #variables.archiverIdField# = NULL
					</cfif>
				WHERE id = <cfqueryparam value="#val(variables.id)#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfset ArrayAppend(result.errorList, "There is no #variables.modelName# to undelete")>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Actually delete a model --->
	<cffunction name="hardDelete" displayname="hardDelete" access="public" returntype="struct" hint="Actually delete a model" output="false">
		
		<cfset var result = StructNew()>
		<cfset result.errorList = ArrayNew(1)>

		<!--- Is there any model to delete? --->
		<cfif StructKeyExists(variables, "id")>
			<cfquery name="qDelete" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
				DELETE FROM #variables.tableName#
				WHERE id = <cfqueryparam value="#val(variables.id)#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfset ArrayAppend(result.errorList, "There is no #variables.modelName# to delete")>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Update relationship with another model --->
	<cffunction name="updateRelationship" displayname="updateRelationship" access="public" returntype="struct" hint="Update relationship with another model" output="false">
		<cfargument name="relatedTableName" type="string" required="yes" hint="The related table name">
		<cfargument name="fieldName" type="string" required="yes" hint="The field name of this model inside the related table">
		<cfargument name="relatedFieldName" type="string" required="yes" hint="The field name of the related model inside the related table">
		<cfargument name="relatedIds" type="string" required="yes" hint="The related model ids">
		<cfset var result = StructNew()>
		<cfset var newIds = "">
		<cfset var totalNewIds = "">
		<cfset var counter = "">
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
				<cfset totalNewIds = listLen(newIds)>
			
				<cfquery name="qAddNew" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
					INSERT INTO #arguments.relatedTableName# 
					(
						#arguments.fieldName#, #arguments.relatedFieldName#, #createdField#
	
						<!--- Record the person who makes this change? --->
						<cfif variables.recordUpdatorId>
							, #variables.creatorIdField#
						</cfif>
					)
	
					<!--- Add multiple relationships at once --->
					<cfloop from="1" to="#totalNewIds#" index="counter">
						(
							SELECT
							
							<cfqueryparam value="#val(variables.id)#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#val(listGetAt(newIds, counter))#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP">
	
							<!--- Record the person who makes this change? --->
							<cfif variables.recordUpdatorId>
								, <cfqueryparam value="#val(variables.userId)#" cfsqltype="CF_SQL_INTEGER">
							</cfif>
						)
						
						<cfif counter lt totalNewIds>UNION</cfif>
					</cfloop>
				</cfquery>
			</cfif>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	

	<!--- Clear this model current state --->
	<cffunction name="clear" displayname="clear" access="public" returntype="struct" hint="Clear this model current state" output="false">
		
		<cfset var result = StructNew()>
		<cfset result.errorList = ArrayNew(1)>
		
		<cfset variables.ranValidation = false>
		<cfset This.error = "">
		<cfset StructDelete(variables, "id")>
		<cfset StructDelete(variables, "textId")>
		<cfset StructDelete(this, "id")>
		<cfset StructDelete(this, "textId")>
		
		<cfreturn result>
	
	</cffunction>
			

	<!--- Check if there are any duplicated records with this model --->
	<cffunction name="hasDuplicates" displayname="hasDuplicates" access="public" returntype="boolean" hint="Check if there are any duplicated records with this model" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var currentQuery = "">
		
		<cfif StructKeyExists(variables, "query")>
			<cfset currentQuery = variables.query>
		<cfelse>
			<cfset currentQuery = this.get()>
		</cfif>
		
		<cfquery name="qDuplicates" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
			SELECT id
			FROM #variables.tableName#
			WHERE #variables.archivedField# IS NULL
				AND #arguments.field.name# = <cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_#arguments.field.type#">		
				AND id != <cfqueryparam value="#val(currentQuery.id)#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfreturn qDuplicates.recordCount gt 0>
	
	</cffunction>
	
	

</cfcomponent>