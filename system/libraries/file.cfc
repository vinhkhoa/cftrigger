<!---
	Project:		cfTrigger
	Company:		cfTrigger
	Summary:		System file class
	
	Log:
	
	Created:		22/11/2009
	
	Modified:
	- 

--->

<cfcomponent displayname="File">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Delete a file but ignore any warning, even when the file does not exist to be deleted --->
	<cffunction name="delete" returntype="struct" access="public">
		<cfargument name="fileLocation" type="string" required="yes" hint="Location of the file to be deleted">
		<cfargument name="ignoreNonExisting" type="boolean" required="no" default="true" hint="true: ignore when the file does not exist, ie. does not return error in that case.">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<!--- Has a file path passed in? Otherwise, does nothing --->
		<cfif trim(fileLocation) neq "">
			<!--- File exists? --->
			<cfif fileExists(fileLocation)>
				<cftry>
					<cffile action="delete" file="#fileLocation#">
				
					<cfcatch type="any">
						<cfset result.error = cfcatch.message>
					</cfcatch>
				</cftry>
			<cfelse>
				<!--- Capture this error? --->
				<cfif NOT arguments.ignoreNonExisting>
					<cfset result.error = "The file does not exist.">
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Rename a file to a random string --->
	<cffunction name="renameToRandom" access="public" returntype="struct">
		<cfargument name="fileLocation" type="string" required="yes" hint="Location of the file to be renamed">
		<cfset var result = StructNew()>
		<cfset var folderLocation = "">
		<cfset var fileExt = "">
		<cfset var newFileName = "">
		<cfset var newFileLocation = "">
		<cfset result.error = "">
		<cfset result.newFileName = "">
		<cfset result.newFileLocation = "">
		
		<!--- Does the file exist? --->
		<cfif fileExists(arguments.fileLocation)>
			<!--- Get the file name --->
			<cfset folderLocation = getDirectoryFromPath(arguments.fileLocation)>
			<cfset fileExt = listLast(getFileFromPath(arguments.fileLocation), ".")>
			<cfif fileExt neq "">
				<cfset fileExt = "." & fileExt>
			</cfif>
			
			<!--- Get a new name --->
			<cfset newFileName = createUUID() & fileExt>
			<cfset newFileLocation = folderLocation & newFileName>
			
			<!--- This random file name already exists? Get another one --->
			<cfloop condition="#fileExists(newFileLocation)#">
				<cfset newFileName = createUUID() & fileExt>
				<cfset newFileLocation = folderLocation & newFileName>
			</cfloop>
			
			<!--- Rename the file --->
			<cftry>
				<cffile action="rename" source="#arguments.fileLocation#" destination="#newFileLocation#" attributes="normal">
				
				<cfset result.newFileName = newFileName>
				<cfset result.newFileLocation = newFileLocation>
				
				<cfcatch type="any">
					<cfset result.error = cfcatch.Message>
					<cfif StructKeyExists(cfcatch, "detail")>
						<cfset result.error = result.error & " " & cfcatch.Detail>
					</cfif>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset result.error = "The file does not exist.">
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Determine if a file is ascii based on its extension --->
	<cffunction name="isAscii" access="public" returntype="boolean">
		<cfargument name="fileLocation" type="string" required="yes" hint="Location of the file to be checked">
		
		<cfset var ext = listLast(getFileFromPath(arguments.fileLocation), ".")>
		
		<cfreturn (listFind(application.asciiExtensions, ext) gt 0)>
	
	</cffunction>
	

	<!--- Copy a file. Create missing directories --->
	<cffunction name="copy" returntype="struct" access="public">
		<cfargument name="fileLocation" type="string" required="yes" hint="Location of the file to be copied">
		<cfargument name="fileDestination" type="string" required="yes" hint="Copy file to this location">
		<cfset var result = StructNew()>
		<cfset var fileDestinationDirectory = "">
		<cfset result.error = "">
		
		<!--- File exists? --->
		<cfif fileExists(arguments.fileLocation)>
			<!--- Create destination file directory --->
			<cfset fileDestinationDirectory = application.core.listDeleteLast(arguments.fileDestination, application.separator)>
			<cfset application.directory.create(fileDestinationDirectory)>
			
			<!--- Copy file --->
			<cftry>
				<cffile action="copy" source="#arguments.fileLocation#" destination="#arguments.fileDestination#" nameconflict="overwrite">
				
				<cfcatch type="any">
					<cfset result.error = cfcatch.Message>
					<cfif StructKeyExists(cfcatch, "detail")>
						<cfset result.error = result.error & " " & cfcatch.Detail>
					</cfif>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset result.error = "The file does not exist.">
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
</cfcomponent>