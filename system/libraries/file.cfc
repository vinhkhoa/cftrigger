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
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<cfif trim(fileLocation) neq "" AND fileExists(fileLocation)>
			<cftry>
				<cffile action="delete" file="#fileLocation#">
			
				<cfcatch type="any">
					<!--- IGNORE --->
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Rename a file to a random string --->
	<cffunction name="renameToRandom" access="public" returntype="struct">
		<cfargument name="fileLocation" type="string" required="yes" hint="Location of the file to be renamed">
		<cfset var result = StructNew()>
		<cfset result.newFileName = "">
		<cfset result.newFileLocation = "">
		
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
		<cffile action="rename" source="#fileLocation#" destination="#newFileLocation#" attributes="normal">
		
		<cfset result.newFileName = newFileName>
		<cfset result.newFileLocation = newFileLocation>
		
		<cfreturn result>
	</cffunction>
	
	
	<!--- Determine if a file is ascii based on its extension --->
	<cffunction name="isAscii" access="public" returntype="boolean">
		<cfargument name="fileLocation" type="string" required="yes" hint="Location of the file to be checked">
		
		<cfset ext = listLast(getFileFromPath(arguments.fileLocation), ".")>
		
		<cfreturn (listFind(application.asciiExtensions, ext) gt 0)>
	
	</cffunction>
	
</cfcomponent>