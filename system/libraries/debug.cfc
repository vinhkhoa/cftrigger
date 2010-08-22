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
			<cfset css_cell = "border: 1px solid ##000; padding: 4px;">
		
			<table style="border: 1px solid ##000; border-collapse: collapse;">
				<tr>
					<th style="#css_cell#">Variable</th>
					<th style="#css_cell#">Value</th>
				</tr>
				
				<!--- Server settings --->
				<tr>
					<td colspan="2" style="#css_cell#"><strong>Server settings</strong></td>
				</tr>
				<tr>
					<td style="#css_cell#">application.name</td>
					<td style="#css_cell#">#application.name#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.serverType</td>
					<td style="#css_cell#">#application.serverType#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.serverName</td>
					<td style="#css_cell#">#application.serverName#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.rootURL</td>
					<td style="#css_cell#">#application.rootURL#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.baseURL</td>
					<td style="#css_cell#">#application.baseURL#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.rootURLPath</td>
					<td style="#css_cell#">#application.rootURLPath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.baseURLPath</td>
					<td style="#css_cell#">#application.baseURLPath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.separator</td>
					<td style="#css_cell#">#application.separator#</td>
				</tr>

				<!--- Database settings --->
				<tr>
					<td colspan="2"><strong>Database settings</strong></td>
				</tr>
				<tr>
					<td style="#css_cell#">application.dbname</td>
					<td style="#css_cell#">#application.dbname#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.dbuser</td>
					<td style="#css_cell#">#application.dbuser#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.dbpassword</td>
					<td style="#css_cell#">#application.dbpassword#</td>
				</tr>

				<!--- Logical paths --->
				<tr>
					<td colspan="2"><strong>Logical paths</strong></td>
				</tr>
				<tr>
					<td style="#css_cell#">application.modelPath</td>
					<td style="#css_cell#">#application.modelPath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.viewPath</td>
					<td style="#css_cell#">#application.viewPath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.controllerPath</td>
					<td style="#css_cell#">#application.controllerPath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.libraryPath</td>
					<td style="#css_cell#">#application.libraryPath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.errorPath</td>
					<td style="#css_cell#">#application.errorPath#</td>
				</tr>

				<!--- Absolute paths / File paths --->
				<tr>
					<td colspan="2"><strong>Absolute paths / File paths</strong></td>
				</tr>
				<tr>
					<td style="#css_cell#">application.filePath</td>
					<td style="#css_cell#">#application.filePath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.modelFilePath</td>
					<td style="#css_cell#">#application.modelFilePath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.viewFilePath</td>
					<td style="#css_cell#">#application.viewFilePath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.controllerFilePath</td>
					<td style="#css_cell#">#application.controllerFilePath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.libraryFilePath</td>
					<td style="#css_cell#">#application.libraryFilePath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.errorFilePath</td>
					<td style="#css_cell#">#application.errorFilePath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.configFilePath</td>
					<td style="#css_cell#">#application.configFilePath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.CFT_libraryFilePath</td>
					<td style="#css_cell#">#application.CFT_libraryFilePath#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.CFT_viewFilePath</td>
					<td style="#css_cell#">#application.CFT_viewFilePath#</td>
				</tr>

				<!--- Package paths --->
				<tr>
					<td colspan="2"><strong>Package paths</strong></td>
				</tr>
				<tr>
					<td style="#css_cell#">application.modelRoot</td>
					<td style="#css_cell#">#application.modelRoot#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.controllerRoot</td>
					<td style="#css_cell#">#application.controllerRoot#</td>
				</tr>
				<tr>
					<td style="#css_cell#">application.libraryRoot</td>
					<td style="#css_cell#">#application.libraryRoot#</td>
				</tr>
			</table>
		</cfoutput>
		
	</cffunction>
	

	<!--- Print session simple variables --->
	<cffunction name="simpleSessionVariables" displayname="simpleSessionVariables" access="public" hint="Print application session variables">
	
		<cfoutput>
			<cfset css_cell = "border: 1px solid ##000; padding: 4px;">
		
			<table style="border: 1px solid ##000; border-collapse: collapse;">
				<tr>
					<th style="#css_cell#">Variable</th>
					<th style="#css_cell#">Value</th>
				</tr>
				
				<cfloop collection="#session#" item="thisVariable">
					<cfif isSimpleValue(session[thisVariable])>
						<tr>
							<td style="#css_cell#">#thisVariable#</td>
							<td style="#css_cell#">#session[thisVariable]#</td>
						</tr>
					</cfif>
				</cfloop>
			</table>
		</cfoutput>

	</cffunction>
	
</cfcomponent>