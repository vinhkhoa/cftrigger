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
		
		<cfset var css_cell = "border: 1px solid ##000; padding: 4px;">
		
		<cfoutput>
			<cfif isDefined("application")>
				<table style="border: 1px solid ##000; border-collapse: collapse;">
					<tr>
						<th style="#css_cell#">Variable</th>
						<th style="#css_cell#">Value</th>
					</tr>
					
					<cfif StructKeyExists(application, "name")>
						<tr>
							<td style="#css_cell#">application.name</td>
							<td style="#css_cell#">#application.name#</td>
						</tr>
					</cfif>
					
					<!--- Server settings --->
					<tr>
						<td colspan="2" style="#css_cell#"><strong>Server settings</strong></td>
					</tr>
					<cfif StructKeyExists(application, "serverType")>
						<tr>
							<td style="#css_cell#">application.serverType</td>
							<td style="#css_cell#">#application.serverType#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "serverName")>
						<tr>
							<td style="#css_cell#">application.serverName</td>
							<td style="#css_cell#">#application.serverName#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "rootURL")>
						<tr>
							<td style="#css_cell#">application.rootURL</td>
							<td style="#css_cell#">#application.rootURL#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "baseURL")>
						<tr>
							<td style="#css_cell#">application.baseURL</td>
							<td style="#css_cell#">#application.baseURL#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "rootURLPath")>
						<tr>
							<td style="#css_cell#">application.rootURLPath</td>
							<td style="#css_cell#">#application.rootURLPath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "baseURLPath")>
						<tr>
							<td style="#css_cell#">application.baseURLPath</td>
							<td style="#css_cell#">#application.baseURLPath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "separator")>
						<tr>
							<td style="#css_cell#">application.separator</td>
							<td style="#css_cell#">#application.separator#</td>
						</tr>
					</cfif>
	
					<!--- Database settings --->
					<tr>
						<td colspan="2" style="#css_cell#"><strong>Database settings</strong></td>
					</tr>
					<cfif StructKeyExists(application, "dbname")>
						<tr>
							<td style="#css_cell#">application.dbname</td>
							<td style="#css_cell#">#application.dbname#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "dbuser")>
						<tr>
							<td style="#css_cell#">application.dbuser</td>
							<td style="#css_cell#">#application.dbuser#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "dbpassword")>
						<tr>
							<td style="#css_cell#">application.dbpassword</td>
							<td style="#css_cell#">#application.dbpassword#</td>
						</tr>
					</cfif>
	
					<!--- Logical paths --->
					<tr>
						<td colspan="2" style="#css_cell#"><strong>Logical paths</strong></td>
					</tr>
					<cfif StructKeyExists(application, "modelPath")>
						<tr>
							<td style="#css_cell#">application.modelPath</td>
							<td style="#css_cell#">#application.modelPath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "viewPath")>
						<tr>
							<td style="#css_cell#">application.viewPath</td>
							<td style="#css_cell#">#application.viewPath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "controllerPath")>
						<tr>
							<td style="#css_cell#">application.controllerPath</td>
							<td style="#css_cell#">#application.controllerPath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "libraryPath")>
						<tr>
							<td style="#css_cell#">application.libraryPath</td>
							<td style="#css_cell#">#application.libraryPath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "errorPath")>
						<tr>
							<td style="#css_cell#">application.errorPath</td>
							<td style="#css_cell#">#application.errorPath#</td>
						</tr>
					</cfif>
	
					<!--- Absolute paths / File paths --->
					<tr>
						<td colspan="2" style="#css_cell#"><strong>Absolute paths / File paths</strong></td>
					</tr>
					<cfif StructKeyExists(application, "filePath")>
						<tr>
							<td style="#css_cell#">application.filePath</td>
							<td style="#css_cell#">#application.filePath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "modelFilePath")>
						<tr>
							<td style="#css_cell#">application.modelFilePath</td>
							<td style="#css_cell#">#application.modelFilePath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "viewFilePath")>
						<tr>
							<td style="#css_cell#">application.viewFilePath</td>
							<td style="#css_cell#">#application.viewFilePath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "controllerFilePath")>
						<tr>
							<td style="#css_cell#">application.controllerFilePath</td>
							<td style="#css_cell#">#application.controllerFilePath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "libraryFilePath")>
						<tr>
							<td style="#css_cell#">application.libraryFilePath</td>
							<td style="#css_cell#">#application.libraryFilePath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "errorFilePath")>
						<tr>
							<td style="#css_cell#">application.errorFilePath</td>
							<td style="#css_cell#">#application.errorFilePath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "configFilePath")>
						<tr>
							<td style="#css_cell#">application.configFilePath</td>
							<td style="#css_cell#">#application.configFilePath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "CFT_libraryFilePath")>
						<tr>
							<td style="#css_cell#">application.CFT_libraryFilePath</td>
							<td style="#css_cell#">#application.CFT_libraryFilePath#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "CFT_viewFilePath")>
						<tr>
							<td style="#css_cell#">application.CFT_viewFilePath</td>
							<td style="#css_cell#">#application.CFT_viewFilePath#</td>
						</tr>
					</cfif>
					
					<!--- Package paths --->
					<tr>
						<td colspan="2" style="#css_cell#"><strong>Package paths</strong></td>
					</tr>
					<cfif StructKeyExists(application, "modelRoot")>
						<tr>
							<td style="#css_cell#">application.modelRoot</td>
							<td style="#css_cell#">#application.modelRoot#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "controllerRoot")>
						<tr>
							<td style="#css_cell#">application.controllerRoot</td>
							<td style="#css_cell#">#application.controllerRoot#</td>
						</tr>
					</cfif>
					<cfif StructKeyExists(application, "libraryRoot")>
						<tr>
							<td style="#css_cell#">application.libraryRoot</td>
							<td style="#css_cell#">#application.libraryRoot#</td>
						</tr>
					</cfif>
				</table>
			<cfelse>
				<p>Application scope is not turned on.</p>
			</cfif>
		</cfoutput>
		
	</cffunction>
	

	<!--- Print session simple variables --->
	<cffunction name="simpleSessionVariables" displayname="simpleSessionVariables" access="public" hint="Print application session variables">
	
		<cfset var css_cell = "border: 1px solid ##000; padding: 4px;">
		
		<cfoutput>
			<cfif isDefined("session")>
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
			<cfelse>
				<p>Session is not turned on.</p>
			</cfif>
		</cfoutput>

	</cffunction>
	
	
</cfcomponent>