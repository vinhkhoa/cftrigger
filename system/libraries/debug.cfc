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
			<table border="1">
				<tr>
					<th>Variable</th>
					<th>Value</th>
				</tr>
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
					<td>application.separator</td>
					<td>#application.separator#</td>
				</tr>
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
				<tr>
					<td colspan="2"><strong>Absolute paths / File paths</strong></td>
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
				<tr>
					<td colspan="2"><strong>Package paths:</strong></td>
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
	
</cfcomponent>