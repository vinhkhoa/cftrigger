<!---
	Project:		cfTrigger
	Summary:		Main Controller class
	
	Log:
	
	Created:		25/08/2009
	
	Modified:
	- 

--->

<cfcomponent bindingname="Validation" displayname="Validation" hint="Validation class" output="false">
	
	<cfsetting enablecfoutputonly="yes">
	
	<cfset variables.model = "">
	<cfset variables.modelName = "">
	<cfset variables.fields = ArrayNew(1)>
	<cfset variables.hasModel = false>
	

	<!--- Initialize the validation --->
	<cffunction name="init" displayname="required" output="false">
		<cfargument name="model" type="component" required="no" hint="The model being validated">
		<cfargument name="fields" type="array" required="no" hint="The fields validated">
		<cfset var metaData = "">
		
		<cfif StructKeyExists(arguments, "model")>
			<cfset variables.hasModel = true>
			<cfset variables.model = arguments.model>
			<cfset metaData = getMetaData(variables.model)>
			<cfset variables.modelName = lcase(listLast(metaData.name, '.'))>
			<cfset variables.fields = variables.model.fields>
			
		<cfelseif StructKeyExists(arguments, "fields")>
			<cfset variables.fields = arguments.fields>
		</cfif>
		
		<cfreturn this>
		
	</cffunction>


	<!--- Run the validation --->
	<cffunction name="run" displayname="required" returntype="struct" output="false">
	
		<cfargument name="values" type="struct" required="yes" hint="The model field values">
		<cfargument name="fieldList" type="array" required="no" default="#variables.fields#" hint="The list of fields to be checked against">
		<cfset var result = StructNew()>
		<cfset var value = "">
		<cfset var ruleTotal = "">
		<cfset var thisError = "">
		<cfset var ruleIndex = "">
		<cfset var thisRule = "">
		<cfset var extractResult = "">
		<cfset var funcName = "">
		<cfset var funcArgs = "">
		<cfset result.errorList = ArrayNew(1)>
		<cfset result.fields = StructNew()>
		
		<!--- Loop through all fields --->
		<cfloop array="#arguments.fieldList#" index="field">
			<cfif StructKeyExists(values, field.name)>
				<cfset value = arguments.values[field.name]>
			<cfelse>
				<cfset value = "">
			</cfif>
			
			<cfset thisError = "">
			<cfset ruleIndex = 0>
			
			<!--- Rules defined as array? --->
			<cfif isArray(field.rules)>
				<cfset ruleTotal = arrayLen(field.rules)>
			<cfelse>
				<cfset ruleTotal = listLen(field.rules)>
			</cfif>
			
			<!--- Loop through all rules until no rule left or an error has been encountered --->
			<cfloop condition="ruleIndex lt ruleTotal AND thisError eq ''">
				<cfset ruleIndex++>
				
				<!--- Rules defined as array? --->
				<cfif isArray(field.rules)>
					<cfset thisRule = field.rules[ruleIndex]>
				<cfelse>
					<cfset thisRule = listGetAt(field.rules, ruleIndex)>
				</cfif>
				
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
				<cfset result.fields[field.name] = thisError>
			</cfif>
		</cfloop>
		
		<!--- Mark this model as validated --->
		<cfif variables.hasModel>
			<cfset variables.model.ranValidation = true>
			<cfset variables.model.validationResult = result>
		</cfif>
		
		<cfreturn result>

	</cffunction>
		

	<!--- ======================================= VALIDATAION RULES ========================================== --->

	<!--- Required field --->
	<cffunction name="_required" displayname="_required" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">
		
		<!--- <cfif (listFindNoCase("varchar", arguments.field.type) AND NOT len(trim(arguments.value))) OR 
				 (listFindNoCase("integer,decimal,float", arguments.field.type) AND NOT val(arguments.value))> --->
		<cfif NOT len(trim(arguments.value))>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "required")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	
	
	<!--- Unique field --->
	<cffunction name="_unique" displayname="_unique" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">
		
		<cfif variables.model.hasDuplicates(arguments.field, arguments.value)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "unique")>
		</cfif>
		
		<cfreturn error>
	
	</cffunction>
	
	
	<!--- Email field --->
	<cffunction name="_email" displayname="_email" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif NOT isValid("email", arguments.value)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "email")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Minimum length --->
	<cffunction name="_minLen" displayname="_minLen" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfargument name="args" type="string" required="no" default="" hint="The minimum length value">
		<cfset var error = "">

		<cfif len(arguments.value) lt val(arguments.args)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "minLen", val(arguments.args))>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Maximum length --->
	<cffunction name="_maxLen" displayname="_maxLen" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfargument name="args" type="string" required="no" default="" hint="The maximum length value">
		<cfset var error = "">

		<cfif len(arguments.value) gt val(arguments.args)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "maxLen", val(arguments.args))>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Numeric --->
	<cffunction name="_numeric" displayname="_numeric" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif arguments.value neq "" AND NOT isValid("numeric", arguments.value)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "numeric")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Minimum value --->
	<cffunction name="_minVal" displayname="_minVal" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfargument name="args" type="string" required="no" default="" hint="The minimum value">
		<cfset var error = "">

		<cfif val(arguments.value) lt val(arguments.args)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "minVal", val(arguments.args))>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Maximum value --->
	<cffunction name="_maxVal" displayname="_maxVal" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfargument name="args" type="string" required="no" default="" hint="The maximum value">
		<cfset var error = "">

		<cfif val(arguments.value) gt val(arguments.args)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "maxVal", val(arguments.args))>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


	<!--- Username --->
	<cffunction name="_username" displayname="_username" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif reFind("[^a-zA-Z0-9_]", arguments.value)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "username")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


	<!--- Letters --->
	<cffunction name="_letters" displayname="_letters" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif reFind("[^a-zA-Z]", arguments.value)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "letters")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


	<!--- Numbers/Digits --->
	<cffunction name="_digits" displayname="_digits" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif reFind("[^0-9]", arguments.value)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "digits")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


	<!--- URL field --->
	<cffunction name="_url" displayname="_url" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif trim(arguments.value) neq "" AND NOT isValid("url", arguments.value)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "url")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Provide user with freedom to limit what charactesr they want --->
	<cffunction name="_limitChars" displayname="_limitChars" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfargument name="args" type="string" required="no" default="" hint="The maximum value">
		<cfset var error = "">
		<cfset var regExp = "">
		<cfset var regExpWords = "">

		<cfif reFind("[^#arguments.args#]", arguments.value)>
			<!--- Attempt to get some meanings out of the regular expression --->
			<cfset regExp = arguments.args>
			<cfset regExpWords = "">
			<cfif find("a-z", arguments.args)>
				<cfset regExpWords = listAppend(regExpWords, " lowercase")>
			</cfif>
			<cfif find("A-Z", arguments.args)>
				<cfset regExpWords = listAppend(regExpWords, " uppercase")>
			</cfif>
			<cfif find("0-9", arguments.args)>
				<cfset regExpWords = listAppend(regExpWords, " digits")>
			</cfif>
			<cfif find("_", arguments.args)>
				<cfset regExpWords = listAppend(regExpWords, " underscore")>
			</cfif>
			<cfif find("\-", arguments.args)>
				<cfset regExpWords = listAppend(regExpWords, " hyphen")>
			</cfif>
			<cfif find(".", arguments.args)>
				<cfset regExpWords = listAppend(regExpWords, " period")>
			</cfif>
			<cfif find(" ", arguments.args)>
				<cfset regExpWords = listAppend(regExpWords, " space")>
			</cfif>
			<cfset regExpWords = reverse(replace(reverse(regExpWords), ",", " dna "))>
		
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "limitChars", regExpWords)>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


	<!--- Valid/existing local directory path --->
	<cffunction name="_localDirectory" displayname="_localDirectory" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif NOT directoryExists(arguments.value)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "localDirectory")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Valid phone number --->
	<cffunction name="_phoneNumber" displayname="_phoneNumber" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">
		
		<cfset var conciseNumber = reReplace(arguments.value, "[[:space:]]", "", "ALL")>

		<cfif reFind("[^0-9 ]", arguments.value) OR (conciseNumber neq "" AND len(conciseNumber) neq 10)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "phoneNumber")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>
	

	<!--- Valid URL characters --->
	<cffunction name="_validURLChars" displayname="_validURLChars" returntype="string" output="false">
	
		<cfargument name="field" type="struct" required="yes" hint="The field being checked">
		<cfargument name="value" type="string" required="yes" hint="The value of the field being checked">
		<cfset var error = "">

		<cfif reFind("[^a-zA-Z0-9_\-]", arguments.value)>
			<cfset error = application.lang.getValidationLang(variables.modelName, arguments.field, arguments.value, "validURLChars")>
		</cfif>
			
		<cfreturn error>
	
	</cffunction>


</cfcomponent>
