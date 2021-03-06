<!---
	Project:	cfTrigger
	Summary:	Loader library	
	Log:
	
	Created:
		- 02/06/2009
		
	Modified:
		- 09/06/2009:
			+ Add in try/catch to load view, model and controller
			+ Display 404 errors for non-found controllers and a friendly error message for not-found views or models

--->

<cfcomponent displayname="Load" output="false">

	<cfsetting enablecfoutputonly="yes">


	<!--- Load a controller --->
	<cffunction name="controller" access="public" output="false">
		<cfargument name="template" type="string" required="yes" hint="The path to the controller to be loaded">
		<cfset var result = "">
		
		<!--- Get and validate the controller --->
		<cfset var validateResult = this.validateController(arguments.template)>
		
		<!--- Get the controller file --->
		<cfif validateResult.exists>
			<cftry>
				<cfset result = CreateObject("component", validateResult.controllerComponent).init()>
				
				<cfcatch type="any">
					<!--- Error intialising the component. Likely that it in fact does not exist or its path is invalid --->
					<cfset application.error.show_404()>
				</cfcatch>
			</cftry>
		<cfelse>
			<!--- Display friendly error or let Coldfusion blow it up? --->
			<cfif application.showFriendlyError>
				<cfset application.error.show_404()>
			<cfelse>
				<!--- THIS WILL THROW ERROR!!! LOAD THE LIBRARY TO THROW ERROR ON PURPOSE --->
				<cfset result = CreateObject("component", validateResult.controllerComponent)>
			</cfif>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	

	<!--- Load a view --->
	<cffunction name="view" access="public" returntype="string">
		<cfargument name="template" type="string" required="yes" hint="The path to the view to be loaded">
		<cfargument name="data" type="struct" required="no" default="#StructNew()#" hint="Data passed to the view">
		<cfargument name="saveResult" type="boolean" required="no" default="false" hint="True: save the view and return it. False: display the view.">
		<cfargument name="fields" type="array" required="no" hint="Pass in the fields to set client side validation on forms">
		<cfset var result = "">
		<cfset var objTemplate = "">
		<cfset var replaceFroms = "">
		<cfset var replaceTos = "">
		<cfset var inputRules = "">
		<cfset var extractInputs = "">
		<cfset var input = "">
		<cfset var tag = "">
		<cfset var name = "">
		<cfset var thisRule = "">
		<cfset var replaceTo = "">
		<cfset var class = "">
		<cfset var attrs = "">
		<cfset var extractAttrRules = "">
		<cfset var counter = "">
		<cfset var field = "">
		
		<!--- Get and validate the view --->
		<cfset var validateResult = this.validateView(arguments.template)>

		<!--- Parse the view and save its content --->
		<cfif validateResult.exists>
			<!--- Include the template --->
			<cfset objTemplate = createObject("component", "template")>
			<cfinvoke component="#objTemplate#" method="includeWithData" returnvariable="result">
				<cfinvokeargument name="template" value="#validateResult.viewFile#">
				<cfinvokeargument name="data" value="#arguments.data#">
			</cfinvoke>
		<cfelse>
			<!--- Display friendly error or let Coldfusion blow it up? --->
			<cfif application.showFriendlyError>
				<cfset application.error.show_error("View not found", "The system cannot find the specified view: #validateResult.viewFile#")>
				<cfabort>
			<cfelse>
				<!--- THIS WILL THROW ERROR!!! INCLUDE THE FILE TO THROW ERROR ON PURPOSE --->
				<cfinclude template="#validateResult.viewFile#">
			</cfif>
		</cfif>
		
		<!--- Fields passed in to set validation? --->
		<cfif StructKeyExists(arguments, "fields")>
			<!--- Collect what needs to be replaced with what --->
			<cfset replaceFroms = arrayNew(1)>
			<cfset replaceTos = arrayNew(1)>
		
			<!--- Extract the rules from the fields settings --->
			<cfset inputRules = StructNew()>
			<cfloop array="#arguments.fields#" index="field">
				<cfset inputRules[field.name] = field.rules>
			</cfloop>
		
			<!--- Extract input fields from the form --->
			<cfset extractInputs = application.utils.extract(result, '(<(input|select|textarea)[^>]+name="([^"]+)"[^>]+>)')>
			
			<!--- Loop through each input field --->
			<cfloop array="#extractInputs#" index="input">
				<cfset tag = input[1]>
				<cfset name = input[3]>
			
				<!--- There is rule for this input? --->
				<cfif StructKeyExists(inputRules, name)>
					<cfset thisRule = inputRules[name]>
					<cfset replaceTo = tag>
					
					<!--- ========== CLASS =========== --->
					<cfset class = "">
					<cfif listFind(thisRule, "required")><cfset class = class & " required"></cfif>
					<cfif listFind(thisRule, "numeric")><cfset class = class & " number"></cfif>
					<cfif listFind(thisRule, "email")><cfset class = class & " email"></cfif>
					<cfif listFind(thisRule, "url")><cfset class = class & " url"></cfif>
					
					<!--- Any class to replace? --->
					<cfif class neq "">
						<!--- Is there already a class attribute? --->
						<cfif reFind('class="[^"]*"', replaceTo)>
							<cfset replaceTo = reReplace(replaceTo, 'class="', 'class=" #class# ')>
						<cfelse>
							<cfset replaceTo = reReplace(replaceTo, '(/?)>$', ' class="#class#" \1>')>
						</cfif>
					</cfif>
					
					<!--- ========== OTHER ATTRIBUTES =========== --->
					<cfset attrs = "">
					
					<!--- Min length attribute --->
					<cfset extractAttrRules = application.utils.extract(thisRule, "(minLen\[([^\]]+)\])")>
					<cfif arrayLen(extractAttrRules)>
						<cfset attrs = attrs & ' minlength="#extractAttrRules[1][2]#"'>
					</cfif>

					<!--- Max length attribute --->
					<cfset extractAttrRules = application.utils.extract(thisRule, "(maxLen\[([^\]]+)\])")>
					<cfif arrayLen(extractAttrRules)>
						<cfset attrs = attrs & ' maxlength="#extractAttrRules[1][2]#"'>
					</cfif>

					<!--- Min value attribute --->
					<cfset extractAttrRules = application.utils.extract(thisRule, "(minVal\[([^\]]+)\])")>
					<cfif arrayLen(extractAttrRules)>
						<cfset attrs = attrs & ' minval="#extractAttrRules[1][2]#"'>
					</cfif>

					<!--- Max value attribute --->
					<cfset extractAttrRules = application.utils.extract(thisRule, "(maxVal\[([^\]]+)\])")>
					<cfif arrayLen(extractAttrRules)>
						<cfset attrs = attrs & ' maxval="#extractAttrRules[1][2]#"'>
					</cfif>
					
					<!--- Any attribute to replace? --->
					<cfif attrs neq "">
						<cfset replaceTo = reReplace(replaceTo, '(/?)>$', ' #attrs# \1>')>
					</cfif>
					
					<cfset arrayAppend(replaceFroms, tag)>
					<cfset arrayAppend(replaceTos, replaceTo)>
				</cfif>
			</cfloop>
			
			<!--- Perform replacement to the entire form --->
			<cfloop from="1" to="#arrayLen(replaceFroms)#" index="counter">
				<cfset result = replace(result, replaceFroms[counter], replaceTos[counter], "ALL")>
			</cfloop>
		</cfif>

		<!--- Return the view or display it? --->
		<cfif NOT arguments.saveResult>
			<cfoutput>#result#</cfoutput>
			
			<cfset result = "">
		</cfif>
		
		<cfreturn result>
		
	</cffunction>


	<!--- Load a model --->
	<cffunction name="model" access="public" output="false">
		<cfargument name="template" type="string" required="yes" hint="The path to the model to be loaded">
		<cfargument name="id" type="numeric" required="no" hint="Model Id">
		<cfargument name="textId" type="string" required="no" hint="Model text Id">
		<cfargument name="data" type="struct" required="no" hint="Data passed to the controller init function">
		<cfargument name="getArchived" type="boolean" required="no" hint="true: get archived model">
		<cfset var result = "">
		<cfset var paramName= "">
		<cfset var templateFile = "">
		<cfset var templateComponent = "">
		
		<!--- Remove the .cfc extension (if exists) --->
		<cfset arguments.template = reReplaceNoCase(arguments.template, ".cfc$", "")>
		
		<!--- Get the component and file paths --->
		<cfset templateFile = application.modelFilePath & lcase(arguments.template) & ".cfc">
		<cfset templateComponent = application.modelRoot & "." & lcase(arguments.template)>
		
		<!--- load the application model --->
		<cfif fileExists(templateFile)>
			<cfset result = CreateObject("component", templateComponent)>
			
			<!--- Initialize the model --->
			<cfinvoke component="#result#" method="init" returnvariable="result">
				<cfif StructKeyExists(session, "userId")>
					<cfinvokeargument name="userId" value="#val(session.userId)#">
				<cfelse>
					<cfinvokeargument name="userId" value="0">
				</cfif>
				
				<!--- Limit by id? --->
				<cfif StructKeyExists(arguments, "id")>
					<cfinvokeargument name="id" value="#val(arguments.id)#">
				</cfif>
				
				<!--- Limit by text id? --->
				<cfif StructKeyExists(arguments, "textId")>
					<cfinvokeargument name="textId" value="#arguments.textId#">
				</cfif>

				<!--- Get archived model? --->
				<cfif StructKeyExists(arguments, "getArchived")>
					<cfinvokeargument name="getArchived" value="#arguments.getArchived#">
				</cfif>

				<!--- Any data/arguments for this model init function? --->
				<cfif StructKeyExists(arguments, "data")>
					<cfloop collection="#arguments.data#" item="paramName">
						<cfinvokeargument name="#paramName#" value="#arguments.data[paramName]#">
					</cfloop>
				</cfif>
			</cfinvoke>
		<cfelse>
			<!--- Display friendly error or let Coldfusion blow it up? --->
			<cfif application.showFriendlyError>
				<cfset application.error.show_error("Model not found", "The system cannot find the specified model: #templateComponent#")>
			<cfelse>
				<!--- THIS WILL THROW ERROR!!! LOAD THE LIBRARY TO THROW ERROR ON PURPOSE --->
				<cfset result = CreateObject("component", templateComponent)>
			</cfif>
		</cfif>		
		
		<!--- Store the model into application memory --->
		<!---<cfset application[listLast(arguments.template, ".")] = result>--->

		<cfreturn result>

	</cffunction>


	<!--- Load a library --->
	<cffunction name="library" access="public" output="false">
		<cfargument name="template" type="string" required="yes" hint="The path to the library to be loaded">
		<cfargument name="storeInApplication" type="boolean" required="no" default="false" hint="True: store the loaded library into application scope">
		<cfset var result = "">
		
		<!--- Get the component and file paths --->
		<cfset var templateFile = application.libraryFilePath & lcase(arguments.template) & ".cfc">
		<cfset var templateComponent = application.libraryRoot & "." & lcase(arguments.template)>
		<cfset var CFT_templateFile = application.CFT_libraryFilePath & lcase(arguments.template) & ".cfc">
		<cfset var CFT_templateComponent = "cft.libraries." & lcase(arguments.template)>
		
		<!--- load the application library --->
		<cfif fileExists(templateFile)>
			<cfset result = CreateObject("component", templateComponent)>
		<cfelse>
			<cfif fileExists(CFT_templateFile)>
				<cfset result = CreateObject("component", CFT_templateComponent)>
			<cfelse>
				<!--- Display friendly error or let Coldfusion blow it up? --->
				<cfif application.showFriendlyError>
					<cfset application.error.show_error("Library not found", "The system cannot find the specified library: #templateComponent# OR #CFT_templateComponent#")>
				<cfelse>
					<!--- THIS WILL THROW ERROR!!! LOAD THE LIBRARY TO THROW ERROR ON PURPOSE --->
					<cfset result = CreateObject("component", CFT_templateComponent)>
				</cfif>
			</cfif>
		</cfif>		
		
		<!--- Store the library into application memory --->
		<cfif arguments.storeInApplication>
			<cfset application[listLast(arguments.template, ".")] = result>
		</cfif>
		
		<cfreturn result>

	</cffunction>


	<!--- Load a view with a template --->
	<cffunction name="viewInTemplate" access="public" hint="Load a view and display them using the default site template">
		<cfargument name="template" type="string" required="yes" hint="The path to the view to be loaded">
		<cfargument name="data" type="struct" required="no" default="#StructNew()#" hint="Data passed to the view">
		<cfargument name="fields" type="array" required="no" hint="Pass in the fields to set client side validation on forms">
		<cfargument name="contentField" type="string" required="no" default="content" hint="Specify the variable name to be returned after loading the view. This variable is put into the struct to be passed to the template.">
		<cfargument name="useTemplate" type="string" required="no" default="#application.defaultTemplate#" hint="The template to be used. If no passed in, use the default template defined in the config">
		<cfset var templateData = StructNew()>
		<cfset var content = "">
		
		<cfset templateData = StructCopy(arguments.data)>
		<cfinvoke method="view" returnvariable="content">
			<cfinvokeargument name="template" value="#arguments.template#">
			<cfinvokeargument name="data" value="#arguments.data#">
			<cfinvokeargument name="saveResult" value="true">
			<cfif StructKeyExists(arguments, "fields")>
				<cfinvokeargument name="fields" value="#arguments.fields#">
			</cfif>
		</cfinvoke>

		<cfset templateData[arguments.contentField] = content>
		<cfset this.view(arguments.useTemplate, templateData)>
		
	</cffunction>
	
	
	<!--- Load an error --->
	<cffunction name="error" access="public" returntype="string">
		<cfargument name="template" type="string" required="yes" hint="The path to the error page to be loaded">
		<cfargument name="data" type="struct" required="no" default="#StructNew()#" hint="Data passed to the error">
		<cfargument name="saveResult" type="boolean" required="no" default="false" hint="True: save the error page and return it. False: display the error page.">
		<cfset var result = "">
		<cfset var objTemplate = createObject("component", "template")>
		
		<!--- Get the error file --->
		<cfset var errorFile = "#application.errorPath#/#lcase(arguments.template)#.cfm">
		<cfset var CFT_errorFile = "/cft/errors/#lcase(arguments.template)#.cfm">

		<!--- Parse the error page and save its content --->
		<cfif fileExists(expandPath(errorFile))>
			<!--- Include the template --->
			<cfinvoke component="#objTemplate#" method="includeWithData" returnvariable="result">
				<cfinvokeargument name="template" value="#errorFile#">
				<cfinvokeargument name="data" value="#arguments.data#">
			</cfinvoke>
		<cfelse>
			<!--- Include the template --->
			<cfinvoke component="#objTemplate#" method="includeWithData" returnvariable="result">
				<cfinvokeargument name="template" value="#CFT_errorFile#">
				<cfinvokeargument name="data" value="#arguments.data#">
			</cfinvoke>
		</cfif>

		<!--- Return the view or display it? --->
		<cfif NOT arguments.saveResult>
			<cfoutput>#result#</cfoutput>
			<cfset result = "">
		</cfif>
		
		<cfreturn result>
		
	</cffunction>


	<!--- Load an error with a template --->
	<cffunction name="errorInTemplate" access="public" hint="Load an errpr and display them using the default site template">
		<cfargument name="template" type="string" required="yes" hint="The path to the error page to be loaded">
		<cfargument name="data" type="struct" required="no" default="#StructNew()#" hint="Data passed to the errpr">
		<cfargument name="contentField" type="string" required="no" default="content" hint="Specify the variable name to be returned after loading the view. This variable is put into the struct to be passed to the template.">
		
		<cfset var templateData = arguments.data>
		<cfset var content = "">
		
		<cfinvoke method="error" returnvariable="content">
			<cfinvokeargument name="template" value="#arguments.template#">
			<cfinvokeargument name="data" value="#data#">
			<cfinvokeargument name="saveResult" value="true">
		</cfinvoke>
		<cfset templateData[contentField] = content>
		<cfset this.view(application.defaultTemplate, templateData)>
		
	</cffunction>
	
	
	<!--- Validate if a view exists --->
	<cffunction name="validateView" access="public" returntype="struct" output="false">
		<cfargument name="template" type="string" required="yes" hint="The path to the view to be validated">
		<cfset var result = StructNew()>
		<cfset result.exists = false>
		<cfset result.viewFile = "">
		
		<!--- Remove the .cfm extension (if exists) --->
		<cfset arguments.template = reReplaceNoCase(arguments.template, ".cfm$", "")>
		
		<!--- Direct file? --->
		<cfset result.viewFile = "#application.viewPath#/#arguments.template#.cfm">
		
		<cfif fileExists(expandPath(result.viewFile))>
			<cfset result.exists = true>
		<cfelse>
			<!--- Index file of a folder? --->
			<cfset result.viewFile = "#application.viewPath#/#arguments.template#/index.cfm">
			
			<cfif fileExists(expandPath(result.viewFile))>
				<cfset result.exists = true>
			</cfif>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Validate if a controller exists --->
	<cffunction name="validateController" access="public" returntype="struct" output="false">
		<cfargument name="template" type="string" required="yes" hint="The path to the controller to be validated">
		<cfset var result = StructNew()>
		<cfset result.exists = false>
		<cfset result.controllerFile = "">
		<cfset result.controllerComponent = "">
		
		<!--- Remove the .cfc extension (if exists) --->
		<cfset arguments.template = reReplaceNoCase(arguments.template, ".cfc$", "")>
		
		<!--- Direct file? --->
		<cfset result.controllerFile = "#application.controllerPath#/#arguments.template#.cfc">
		<cfset result.controllerComponent = application.controllerRoot & "." & lcase(replace(arguments.template, "/", ".", "ALL"))>

		<cfif fileExists(expandPath(result.controllerFile))>
			<cfset result.exists = true>
		<cfelse>
			<!--- Index file of a folder? --->
			<cfset result.controllerFile = "#application.controllerPath#/#arguments.template#/index.cfc">
			<cfset result.controllerComponent = application.controllerRoot & "." & lcase(replace(arguments.template, "/", ".", "ALL")) & ".index">

			<cfif fileExists(expandPath(result.controllerFile))>
				<cfset result.exists = true>
			</cfif>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>

</cfcomponent>