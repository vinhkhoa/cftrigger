<!---
	Project:		cfTrigger
	Company:		cfTrigger
	Summary:		System directory class
	
	Log:
	
	Created:		02/01/2010
	
	Modified:
	- 

--->

<cfcomponent displayname="Directory">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Delete a directory but ignore any warning, even when the directory does not exist--->
	<cffunction name="delete" returntype="struct" access="public">
		<cfargument name="directoryLocation" type="string" required="yes" hint="Location of the directory to be deleted">
		<cfargument name="ignoreNonExisting" type="boolean" required="no" default="true" hint="true: ignore when the directory does not exist, ie. does not return error in that case.">
		<cfargument name="deleteEmptyOnly" type="boolean" required="no" default="true" hint="true: only delete if the directory is empty and throw error when it's not. False: delete the directory and all of its content">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<!--- Has a directory path passed in? Otherwise, does nothing --->
		<cfif trim(arguments.directoryLocation) neq "">
			<!--- Directory exists? --->
			<cfif directoryExists(arguments.directoryLocation)>
				<!--- Directory empty? --->
				<cfdirectory action="list" directory="#arguments.directoryLocation#" name="qList">
				
				<!--- Directory is not empty and said to delete empty only? --->
				<cfif qList.recordCount AND arguments.deleteEmptyOnly>
					<cfset result.error = "The directory is not empty.">
				<cfelse>
					<cftry>
						<cfdirectory action="delete" directory="#arguments.directoryLocation#" recurse="#NOT arguments.deleteEmptyOnly#">
					
						<cfcatch type="any">
							<cfset result.error = cfcatch.message>
						</cfcatch>
					</cftry>
				</cfif>
			<cfelse>
				<!--- Capture this error? --->
				<cfif NOT arguments.ignoreNonExisting>
					<cfset result.error = "The directory does not exist.">
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Create a directory, ignore if the directory already exists --->
	<cffunction name="create" returntype="struct" access="public">
		<cfargument name="directoryLocation" type="string" required="yes" hint="Location of the directory to be deleted">
		<cfargument name="ignoreExisting" type="boolean" required="no" default="true" hint="true: ignore when the directory already exists, ie. does not return error in that case.">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<!--- Has a directory path passed in? Otherwise, does nothing --->
		<cfif trim(arguments.directoryLocation) neq "">
			<!--- Directory exists? --->
			<cfif NOT directoryExists(arguments.directoryLocation)>
				<cftry>
					<cfdirectory action="create" directory="#arguments.directoryLocation#">
					
					<cfcatch type="any">
						<cfset result.error = cfcatch.message>
					</cfcatch>
				</cftry>
			<cfelse>
				<!--- Capture this error? --->
				<cfif NOT arguments.ignoreExisting>
					<cfset result.error = "The directory already exists.">
				</cfif>
			</cfif>
		</cfif>
	
		<cfreturn result>
		
	</cffunction>
</cfcomponent>