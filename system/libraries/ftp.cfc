<!---
	Project:		cfTrigger
	Company:		cfTrigger
	Summary:		System ftp class
	
	Log:
	
	Created:		31/12/2009
	
	Modified:
	- 

--->

<cfcomponent displayname="FTP">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Initialize the connection --->
	<cffunction name="init" displayname="init" access="public" hint="Initialize the connection">
	
		<cfargument name="server" type="string" required="yes" hint="The FTP server address">
		<cfargument name="username" type="string" required="yes" hint="The account username used to connect to the server">
		<cfargument name="password" type="string" required="yes" hint="The account password used to connect to the server">
		<cfargument name="port" type="numeric" required="no" default="21" hint="The server port number">
		<cfargument name="rootDirectory" type="string" required="no" default="/" hint="The root directory to work on">
		<cfset this.error = "">
		
		<cfset variables.server = arguments.server>
		<cfset variables.username = arguments.username>
		<cfset variables.password = arguments.password>
		<cfset variables.port = arguments.port>
		<cfset variables.rootDirectory = arguments.rootDirectory>
		
		<!--- Validate FTP connection --->
		<cfset openResult = this.open()>
		
		<cfset this.error = openResult.error>

		<cfreturn this>
	
	</cffunction>
	
	
	<!--- =================================== CONNECTION FUNCTIONS ======================================== --->
	
	<!--- Open the connection --->
	<cffunction name="open" displayname="open" access="private" returntype="struct" hint="Open the connection">
	
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<!--- Open the FTP connection --->
		<cfif NOT this.isConnected()>
			<cftry>
				<cfftp action="open" server="#variables.server#" username="#variables.username#" password="#variables.password#" port="#variables.port#" connection="variables.connection" stoponerror="No">
				
				<!--- Succeded opening the connection? --->
				<cfif cfftp.Succeeded>
					<!--- Check if the root directory exists --->
					<cfif NOT this.existsDir(variables.rootDirectory)>
						<cfset result.error = "The root directory #variables.rootDirectory# does not exist">
					</cfif>
				<cfelse>
					<cfset result.error = cfftp.ErrorText>
				</cfif>
				
				<!--- Any error in attempting to open the FTP connection? --->
				<cfcatch type="any">
					<cfset result.error = "Cannot open FTP connection to server #variables.server#: #cfcatch.Message#">
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	
		
	<!--- Close the connection --->
	<cffunction name="close" displayname="close" access="private" returntype="struct" hint="Close the connection">
	
		<cfif this.isConnected()>
			<cfftp action="close" server="#variables.server#" username="#variables.username#" password="#variables.password#" port="#variables.port#" stoponerror="No">
		</cfif>

	</cffunction>
	
	
	<!--- Check if a connection to the server has been opened --->
	<cffunction name="isConnected" displayname="isConnected" access="public" returntype="boolean" hint="Check if a connection to the server has been opened">

		<cfreturn StructKeyExists(variables, "connection") AND variables.connection.isConnected()>

	</cffunction>


	<!--- =================================== DIRECTORY FUNCTIONS ======================================== --->
	
	<!--- Check if a directory exists --->
	<cffunction name="existsDir" displayname="existsDir" access="public" returntype="boolean" hint="Check if a directory exists">
	
		<cfargument name="directoryPath" type="string" required="yes" hint="The directory path">
	
		<cfftp action="existsdir" directory="#arguments.directoryPath#" server="#variables.server#" username="#variables.username#" password="#variables.password#" port="#variables.port#" stoponerror="No">
		
		<cfreturn cfftp.ReturnValue>
	
	</cffunction>
	
	
	<!--- List files inside a directory --->
	<cffunction name="listDir" displayname="listDir" access="public" returntype="struct" hint="List files inside a directory">
	
		<cfargument name="directoryPath" type="string" required="yes" hint="The directory path">
		<cfargument name="excludeItems" type="string" required="no" hint="Pass in the items to be hidden. For example, hidden files are not wished to be returned.">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		<cfset result.qList = "">

		<!--- Directory exists? --->
		<cfif this.existsDir(arguments.directoryPath)>
			<cfftp action="listdir" directory="#arguments.directoryPath#" name="result.qList" server="#variables.server#" username="#variables.username#" password="#variables.password#" port="#variables.port#" stoponerror="No">
			
			<!--- Order the list by directory first and exclude some items if specified --->
			<cfquery name="result.qList" dbtype="query">
				SELECT *
				FROM result.qList
				<cfif StructKeyExists(arguments, "excludeItems")>
					WHERE name NOT IN (<cfqueryparam value="#arguments.excludeItems#" cfsqltype="cf_sql_varchar" list="yes">)
				</cfif>
				ORDER BY type
			</cfquery>
		<cfelse>
			<cfset result.error = "Directory '#arguments.directoryPath#' does not exist.">
		</cfif>
		
		<cfreturn result>
		
	</cffunction>


	<!--- Create a directory --->
	<cffunction name="createDir" displayname="createDir" access="public" returntype="struct" hint="Create a directory">
	
		<cfargument name="directoryPath" type="string" required="yes" hint="The directory path">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<!--- Keep crawling up the the tree until found a directory that exists --->
		<cfset missingDirs = arrayNew(1)>
		<cfset thisDir = arguments.directoryPath>
		<cfloop condition="#thisDir neq '/' AND thisDir neq ""#">
			<cfif this.existsDir(thisDir)>
				<cfbreak>
			<cfelse>
				<cfset arrayPrepend(missingDirs, thisDir)>
			</cfif>
			
			<cfset thisDir = application.core.listDeleteLast(thisDir, "/")>
		</cfloop>
		
		<!--- Create the missing directories --->
		<cfloop array="#missingDirs#" index="thisDir">
			<cfftp action="createdir" directory="#thisDir#" server="#variables.server#" username="#variables.username#" password="#variables.password#" port="#variables.port#" stoponerror="No">
			
			<!--- Any error? --->
			<cfif NOT cfftp.succeeded>
				<cfset result.error = "Cannot create directory '#thisDir#': #cfftp.ErrorText#">
				<cfreturn result>
			</cfif>
		</cfloop>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Delete a directory --->
	<cffunction name="removeDir" displayname="removeDir" access="public" returntype="struct" hint="Delete a directory">
	
		<cfargument name="directoryPath" type="string" required="yes" hint="The directory path">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<!--- Directory exists? --->
		<cfif this.existsDir(arguments.directoryPath)>
			<!--- Directory is empty? --->
			<cfif this.isEmptyDir(arguments.directoryPath)>
				<!--- Delete the directory --->
				<cfftp action="removedir" directory="#arguments.directoryPath#" server="#variables.server#" username="#variables.username#" password="#variables.password#" port="#variables.port#" stoponerror="no">
	
				<!--- Succeeded? --->
				<cfif NOT cfftp.succeeded>
					<cfset result.error = "Cannot delete the directory '#deleteDirectory#': " & cfftp.ErrorText>
				</cfif>
			<cfelse>
				<cfset result.error = "The directory is not empty.">
			</cfif>
		<cfelse>
			<cfset result.error = "The directory does not exist.">
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Check if a directory is empty --->
	<cffunction name="isEmptyDir" displayname="isEmptyDir" access="public" returntype="boolean" hint="Check if a directory is empty">
	
		<cfargument name="directoryPath" type="string" required="yes" hint="The directory path">

		<cfftp action="listDir" directory="#arguments.directoryPath#" server="#variables.server#" username="#variables.username#" password="#variables.password#" port="#variables.port#" stoponerror="No" name="qList">
		
		<cfreturn qList.recordCount eq 0>
	
	</cffunction>
	
	
	<!--- =================================== FILE FUNCTIONS ======================================== --->
	
	<!--- Check if a file exists --->
	<cffunction name="existsFile" displayname="existsFile" access="public" returntype="boolean" hint="Check if a directory exists">
	
		<cfargument name="filePath" type="string" required="yes" hint="The file path">
	
		<cfftp action="existsfile" remotefile="#arguments.filePath#" server="#variables.server#" username="#variables.username#" password="#variables.password#" port="#variables.port#" stoponerror="No">
		
		<cfreturn cfftp.ReturnValue>
	
	</cffunction>
	
	
	<!--- Delete a file --->
	<cffunction name="remove" displayname="remove" access="public" returntype="struct" hint="Delete a file">
	
		<cfargument name="filePath" type="string" required="yes" hint="The file path">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<!--- File exists? --->
		<cfif this.existsFile(arguments.filePath)>
			<cfftp action="remove" item="#arguments.filePath#" server="#variables.server#" username="#variables.username#" password="#variables.password#" port="#variables.port#" stoponerror="no">
			
			<!--- Succeeded? --->
			<cfif NOT cfftp.succeeded>
				<cfset result.error = "Cannot delete file: #cfftp.ErrorText#.">
			</cfif>
		<cfelse>
			<cfset result.error = "The file does not exist. Nothing is deleted.">
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Upload file --->
	<cffunction name="putFile" displayname="putFile" access="public" returntype="struct" hint="Upload file">
		
		<cfargument name="localFilePath" type="string" required="yes" hint="The file path">
		<cfargument name="remoteFilePath" type="string" required="yes" hint="The file path">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<!--- Create the parent directory --->
		<cfset parentDirectory = application.core.listDeleteLast(arguments.remoteFilePath, "/")>
		<cfset createDirectoryResult = this.createDir(parentDirectory)>
		
		<!--- Any error in creating the directory? --->
		<cfif createDirectoryResult.error neq "">
			<cfset result.error = "Cannot upload file: " & createDirectoryResult.error>
			<cfreturn result>
		</cfif>
		
		<!--- Upload the file --->
		<cfftp action="putfile" localfile="#arguments.localFilePath#" remotefile="#arguments.remoteFilePath#" server="#variables.server#" username="#variables.username#" password="#variables.password#" port="#variables.port#" stoponerror="no">
		
		<!--- Succeeded? --->
		<cfif NOT cfftp.Succeeded>
			<cfset result.error = cfftp.ErrorText>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	
</cfcomponent>