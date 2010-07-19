<!---
	Project:	cfTrigger
	Company:	cfTrigger
	Summary:	Contains functions to do debugging
	
	Log:
	
		Created:		26/03/2010		
		Modified:

--->

<cfcomponent displayname="Debug" hint="Contains functions to do debugging">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Print application simple variables --->
	<cffunction name="simpleAppVariables" displayname="simpleAppVariables" access="public" hint="Print application simple variables">
		
		<cfoutput>
			#getStyle()#
		
			<table class="scopeDump">
				<tr>
					<th>Variable</th>
					<th>Value</th>
				</tr>
				
				<!--- Server settings --->
				<tr>
					<td colspan="2"><strong>Server settings</strong></td>
				</tr>
				<tr>
					<td>application.name</td>
					<td>#application.name#</td>
				</tr>
				<tr>
					<td>application.serverType</td>
					<td>#application.serverType#</td>
				</tr>
				<tr>
					<td>application.serverName</td>
					<td>#application.serverName#</td>
				</tr>
				<tr>
					<td>application.rootURL</td>
					<td>#application.rootURL#</td>
				</tr>
				<tr>
					<td>application.baseURL</td>
					<td>#application.baseURL#</td>
				</tr>
				<tr>
					<td>application.rootURLPath</td>
					<td>#application.rootURLPath#</td>
				</tr>
				<tr>
					<td>application.baseURLPath</td>
					<td>#application.baseURLPath#</td>
				</tr>
				<tr>
					<td>application.separator</td>
					<td>#application.separator#</td>
				</tr>

				<!--- Database settings --->
				<tr>
					<td colspan="2"><strong>Database settings</strong></td>
				</tr>
				<tr>
					<td>application.dbname</td>
					<td>#application.dbname#</td>
				</tr>
				<tr>
					<td>application.dbuser</td>
					<td>#application.dbuser#</td>
				</tr>
				<tr>
					<td>application.dbpassword</td>
					<td>#application.dbpassword#</td>
				</tr>

				<!--- Logical paths --->
				<tr>
					<td colspan="2"><strong>Logical paths</strong></td>
				</tr>
				<tr>
					<td>application.modelPath</td>
					<td>#application.modelPath#</td>
				</tr>
				<tr>
					<td>application.viewPath</td>
					<td>#application.viewPath#</td>
				</tr>
				<tr>
					<td>application.controllerPath</td>
					<td>#application.controllerPath#</td>
				</tr>
				<tr>
					<td>application.libraryPath</td>
					<td>#application.libraryPath#</td>
				</tr>
				<tr>
					<td>application.errorPath</td>
					<td>#application.errorPath#</td>
				</tr>

				<!--- Absolute paths / File paths --->
				<tr>
					<td colspan="2"><strong>Absolute paths / File paths</strong></td>
				</tr>
				<tr>
					<td>application.filePath</td>
					<td>#application.filePath#</td>
				</tr>
				<tr>
					<td>application.modelFilePath</td>
					<td>#application.modelFilePath#</td>
				</tr>
				<tr>
					<td>application.viewFilePath</td>
					<td>#application.viewFilePath#</td>
				</tr>
				<tr>
					<td>application.controllerFilePath</td>
					<td>#application.controllerFilePath#</td>
				</tr>
				<tr>
					<td>application.libraryFilePath</td>
					<td>#application.libraryFilePath#</td>
				</tr>
				<tr>
					<td>application.errorFilePath</td>
					<td>#application.errorFilePath#</td>
				</tr>
				<tr>
					<td>application.CFT_LibraryFilePath</td>
					<td>#application.CFT_LibraryFilePath#</td>
				</tr>

				<!--- Package paths --->
				<tr>
					<td colspan="2"><strong>Package paths</strong></td>
				</tr>
				<tr>
					<td>application.modelRoot</td>
					<td>#application.modelRoot#</td>
				</tr>
				<tr>
					<td>application.controllerRoot</td>
					<td>#application.controllerRoot#</td>
				</tr>
				<tr>
					<td>application.libraryRoot</td>
					<td>#application.libraryRoot#</td>
				</tr>
			</table>
		</cfoutput>
		
	</cffunction>
	

	<!--- Print session simple variables --->
	<cffunction name="simpleSessionVariables" displayname="simpleSessionVariables" access="public" hint="Print application session variables">
	
		<cfoutput>
			#getStyle()#
			
			<table class="scopeDump">
				<tr>
					<th>Variable</th>
					<th>Value</th>
				</tr>
				
				<cfloop collection="#session#" item="thisVariable">
					<cfif isSimpleValue(session[thisVariable])>
						<tr>
							<td>#thisVariable#</td>
							<td>#session[thisVariable]#</td>
						</tr>
					</cfif>
				</cfloop>
			</table>
		</cfoutput>

	</cffunction>
	
	
	<!--- Get debug style --->
	<cffunction name="getStyle" displayname="getStyle" access="private" returntype="string" hint="Get debug style">
		<cfset var result = "">
		
		<cfsavecontent variable="result">
			<cfoutput>	
				<style>
					table.scopeDump
					{
						border: 1px solid ##000;
						border-collapse: collapse;
					}
					
					table.scopeDump td, table.scopeDump th
					{
						border: 1px solid ##000;
						padding: 4px;
					}
				</style>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn result>
		
	</cffunction>
	
</cfcomponent>