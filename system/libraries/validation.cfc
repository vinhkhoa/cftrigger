<!---
	Project:		cfTrigger
	Company:		cfTrigger
	Summary:		Main Controller class
	
	Log:
	
	Created:		25/08/2009
	
	Modified:
	- 

--->

<cfcomponent bindingname="Validation" displayname="Validation" hint="Validation class">

	<cfset this.model = "">
	<cfset this.modelName = "">
	<cfset this.modelId = "">
	<cfset this.fields = ArrayNew(1)>
	<cfset this.current = "">
	<cfset this.tableName = "">
	<cfset this.hasModel = false>
	

	<!--- Initialize the validation --->
	<cffunction name="init" displayname="required">
		<cfargument name="model" type="component" required="no" hint="The model being validated">
		<cfargument name="fields" type="array" required="no" hint="The fields validated">
		
		<cfif StructKeyExists(arguments, "model")>
			<cfset this.hasModel = true>
			<cfset this.model = arguments.model>
			<cfset this.modelName = getMetaData(this.model).displayName>
			
			<!--- Model id --->
			<cfif isDefined("this.model.id")>
				<cfset this.modelId = val(this.model.id)>
			<cfelse>
				<cfset this.modelId = 0>
			</cfif>
			<cfset this.fields = this.model.fields>
			
			<!--- Model table name --->
			<cfif isDefined("this.model.tableName")>
				<cfset this.tableName = this.model.tableName>
			<cfelse>
				<cfset this.tableName = application.utils.plural(this.modelName)>
			</cfif>
			<cfset this.current = this.model.get()>
		<cfelseif StructKeyExists(arguments, "fields")>
			<cfset this.fields = arguments.fields>
		</cfif>
		
		<cfreturn this>
		
	</cffunction>


	<!--- Run the validation --->
	<cffunction name="run" displayname="required" returntype="struct">
	
		<cfargument name="values" type="struct" required="yes" hint="The model field values">
		<cfset result = StructNew()>
		<cfset result.errorList = ArrayNew(1)>
		<cfset result.fields = StructNew()>
		
		<!--- Loop through all fields --->
		<cfloop array="#this.fields#" index="field">
			<cfset rules = field.rules>
			<cfset type = field.type>
			<cfset name = field.name>
			<cfif StructKeyExists(values, name)>
				<cfset value = arguments.values[name]>
			<cfelse>
				<cfset value = "">
			</cfif>
			
			<cfset thisError = "">
			<cfset ruleIndex = 0>
			<cfset ruleTotal = listLen(field.rules)>
			
			<!--- Loop through all rules until no rule left or an error has been encountered --->
			<cfloop condition="ruleIndex lt ruleTotal AND thisError eq ''">
				<cfset ruleIndex++>
				<cfset thisRule = listGetAt(field.rules, ruleIndex)>
				
				<!--- Extract the function name and argument(s) from the rule --->
				<cfset extractResult = application.utils.extract(thisRule, "([a-zA-Z]+)\[?([^\]]*)\]?")>
				<cfif arrayLen(extractResult)>
					<!--- Get the function name and arguments --->
					<cfset funcName = extractResult[1][1]>
					<cfset funcArgs = extractResult[1][2]>
					
					<!--- This function exists? --->
					<cfif StructKeyExists(this, "_#funcName#")>
						<cfinvoke method="_#funcName#" field="#field#" value="#value#" args="#funcArgs#" returnvariable="thisError">
					</cfif>
				</cfif>
			</cfloop>

			<!--- Any error? --->			
			<cfif len(thisError)>
				<cfset ArrayAppend(result.errorList, thisError)>
				<cfset result.fields[name] = thisError>
			</cfif>
		</cfloop>
		
		<!--- Mark this model as validated --->
		<cfif this.hasModel>
			<cfset this.model.ranValidation = true>
			<cfset this.model.validationResult = result>
		</cfif>
		
		<cfreturn result>

	</cffunction>
		

	<!--- ======================================= VALIDATAION RULES ========================================== --->

	<!--- Required field --->
	<cffunction name="_required" displayname="_required" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">
		
		<cfif (listFindNoCase("varchar", arguments.field.type) AND NOT len(trim(arguments.value))) OR 
				 (listFindNoCase("integer", arguments.field.type) AND NOT val(arguments.value))>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "required")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	
	
	<!--- Unique field --->
	<cffunction name="_unique" displayname="_unique" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">
		
		<cfquery name="qDuplicated" datasource="#application.dbname#" username="#application.dbuser#" password="#application.dbpassword#">
			SELECT id
			FROM #this.tableName#
			WHERE #this.model.archivedField# IS NULL
				AND #field.name# = <cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_#arguments.field.type#">		
				AND id != <cfqueryparam value="#val(this.current.id)#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfif qDuplicated.recordCount>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "unique")>
		</cfif>
		
		<cfreturn error>
	
	</cffunction>
	
	
	<!--- Email field --->
	<cffunction name="_email" displayname="_email" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif NOT isValid("email", arguments.value)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "email")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Minimum length --->
	<cffunction name="_minLen" displayname="_minLen" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfargument name="args" type="string" required="no" default="" hint="The minimum length value">
		<cfset var error = "">

		<cfif len(arguments.value) lt val(arguments.args)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "minLen", val(arguments.args))>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Maximum length --->
	<cffunction name="_maxLen" displayname="_maxLen" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfargument name="args" type="string" required="no" default="" hint="The minimum length value">
		<cfset var error = "">

		<cfif len(arguments.value) gt val(arguments.args)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "maxLen", val(arguments.args))>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Numeric --->
	<cffunction name="_numeric" displayname="_numeric" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif arguments.value neq "" AND NOT isValid("number", arguments.value)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "numeric")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Minimum value --->
	<cffunction name="_minVal" displayname="_minVal" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfargument name="args" type="string" required="no" default="" hint="The minimum value">
		<cfset var error = "">

		<cfif val(arguments.value) lt val(arguments.args)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "minVal", val(arguments.args))>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Maximum value --->
	<cffunction name="_maxVal" displayname="_maxVal" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfargument name="args" type="string" required="no" default="" hint="The maximum value">
		<cfset var error = "">

		<cfif val(arguments.value) gt val(arguments.args)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "maxVal", val(arguments.args))>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


	<!--- Username --->
	<cffunction name="_username" displayname="_username" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif reFindNoCase("[^a-zA-Z0-9_]", arguments.value)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "username")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


	<!--- Letters --->
	<cffunction name="_letters" displayname="_letters" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif reFindNoCase("[^a-zA-Z]", arguments.value)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "letters")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


	<!--- Numbers/Digits --->
	<cffunction name="_digits" displayname="_digits" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif reFindNoCase("[^0-9]", arguments.value)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "digits")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


	<!--- URL field --->
	<cffunction name="_url" displayname="_url" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif NOT isValid("url", arguments.value)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "url")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Provide user with freedom to limit what charactesr they want --->
	<cffunction name="_limitChars" displayname="_limitChars" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfargument name="args" type="string" required="no" default="" hint="The maximum value">
		<cfset var error = "">

		<cfif reFindNoCase("[^#arguments.args#]", arguments.value)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "limitChars", arguments.args)>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


	<!--- Valid/existing local directory path --->
	<cffunction name="_localDirectory" displayname="_localDirectory" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif NOT directoryExists(arguments.value)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "localDirectory")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Valid phone number --->
	<cffunction name="_phoneNumber" displayname="_phoneNumber" returntype="string">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">
		
		<cfset conciseNumber = reReplace(arguments.value, "[[:space:]]", "", "ALL")>

		<cfif reFindNoCase("[^0-9 ]", arguments.value) OR (conciseNumber neq "" AND len(conciseNumber) neq 10)>
			<cfset error = application.lang.getValidationLang(this.modelName, arguments.field, arguments.value, "phoneNumber")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	
</cfcomponent>
