<!---
	Project:	cfTrigger
	Company:	cfTrigger
	Summary:	Template library. The main funciton of this library is to include a templat using
				to the built cfinclude function except that it has the ability to receive data and
				make it available to the included template. It works like a number of cfset before
				cfinclude function:
				
				<cfset ... = ... >
				<cfset ... = ... >
				<cfset ... = ... >
				<cfset ... = ... >
				
				<cfinclude template="...">
				
				However, but put these into a separate component, we have the ability to isolate these
				variables and make them available to ONLY this template but not the rest of the request
				or the rest of the component. This component is expected to be created everytime to ensure
				the variables scope is fresh everytime.
	Log:
	
	Created:
		- 29/11/2009
		
--->

<cfcomponent displayname="Template">

	<cfsetting enablecfoutputonly="yes">
	
	<cfset this.template = "">
	<cfset this.data = StructNew()>


	<!--- Initialize the "includer" --->
	<cffunction name="init" access="public">
		<cfargument name="template" type="string" required="yes" hint="The path to the template to be included">
		<cfargument name="data" type="struct" required="no" default="#StructNew()#" hint="Data passed to the template">
		
		<cfset this.template = arguments.template>
		<cfset this.data = arguments.data>
		
		<cfreturn this>
	
	</cffunction>
	
	
	<!--- Run the include function --->
	<cffunction name="includeWithData" access="public">
	
		<!--- Extract the data that is passed in to make it available for "include" statement --->
		<cfloop collection="#this.data#" item="key">
			<cfset variables[key] = this.data[key]>
		</cfloop>
	
		<cfinclude template="#this.template#">
	
	</cffunction>
	
</cfcomponent>
	
	
