<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Install cfTrigger</title>
<link type="text/css" rel="stylesheet" href="/cftrigger/css/install.css" media="all" />
</head>

<body>

<h1>Install cfTrigger</h1>

<p>Hi! Welcome to cfTrigger. To get started, please fill in a little bit of configuration for your application. After saving, please delete the installation files (or everyone will be able to configure your app!)</p>

<!--- Display error --->		
<cfif StructKeyExists(request, "error") AND len(trim(request.error))>
	<cfset session.error = request.error>
	<cfset StructDelete(request, "error")>
</cfif>
<cfif StructKeyExists(session, "error") AND len(trim(session.error))>
	<div class="error" id="error">#HTMLEditFormat(session.error)#</div>
	<cfset StructDelete(session, "error")>
</cfif>
<cfif StructKeyExists(session, "errorList") AND isArray(session.errorList) AND arrayLen(session.errorList)>
	<div class="error">
		Please fix the following errors:<br />
		
		<ul>
			<cfloop array="#session.errorList#" index="thisError">
				<li>#HTMLEditFormat(thisError)#</li>
			</cfloop>
		</ul>
	</div>
	<cfset StructDelete(session, "errorList")>
</cfif>

<!--- Display message --->		
<cfif StructKeyExists(request, "message") AND len(trim(request.message))>
	<cfset session.message = request.message>
	<cfset StructDelete(request, "message")>
</cfif>
<cfif StructKeyExists(session, "message") AND len(trim(session.message))>
	<div class="message" id="message">#HTMLEditFormat(session.message)#</div>
	<cfset StructDelete(session, "message")>
</cfif>

<!--- Display warning --->		
<cfif StructKeyExists(request, "warning") AND len(trim(request.warning))>
	<cfset session.warning = request.warning>
	<cfset StructDelete(request, "warning")>
</cfif>
<cfif StructKeyExists(session, "warning") AND len(trim(session.warning))>
	<div class="warning" id="warning">#HTMLEditFormat(session.warning)#</div>
	<cfset StructDelete(session, "warning")>
</cfif>
<cfif StructKeyExists(session, "warningList") AND isArray(session.warningList) AND arrayLen(session.warningList)>
	<div class="warning" id="warning">
		WARNING, please consider the following issues:<br />
		
		<ul>
			<cfloop array="#session.warningList#" index="thisWarning">
				<li>#HTMLEditFormat(thisWarning)#</li>
			</cfloop>
		</ul>
	</div>
	<cfset StructDelete(session, "warningList")>
</cfif>

<form method="post">

	<!--- Main --->
	<fieldset>
		<legend>Main</legend>
		<div class="row">
			<label for="appName">Application name:</label>
			<input type="text" name="appName" id="appName" class="text" value="#form.appName#" />
		</div>
	
		<div class="row">
			<label for="defaultController">Default controller:</label>
			<input type="text" name="defaultController" id="defaultController" class="text" value="#form.defaultController#" />
		</div>
		<!--- <div class="row">
			<label for="enableUserAuthentication">Authentication:</label>
			<select name="enableUserAuthentication" id="enableUserAuthentication">
				<option value="true" <cfif application.enableUserAuthentication>selected</cfif>>Yes</option>
				<option value="false" <cfif NOT application.enableUserAuthentication>selected</cfif>>No</option>
			</select>
		</div> --->
	</fieldset>
	
	<!--- Email addresses --->
	<!--- <fieldset>
		<legend>Email addresses</legend>
		<div class="row">
			<label for="fromEmail">From email:</label>
			<input type="text" name="fromEmail" id="fromEmail" class="text" value="#form.fromEmail#" />
		</div>
		<div class="row">
			<label for="errorEmail">Error email:</label>
			<input type="text" name="errorEmail" id="errorEmail" class="text" value="#form.errorEmail#" />
		</div>
		<div class="row">
			<label for="adminEmail">Admin email:</label>
			<input type="text" name="adminEmail" id="adminEmail" class="text" value="#form.adminEmail#" />
		</div>
	</fieldset> --->
	
	<!--- Default --->
	<!--- <fieldset>
		<legend>Default</legend>
		<div class="row">
			<label for="defaultController">Default controller:</label>
			<input type="text" name="defaultController" id="defaultController" class="text" value="#form.defaultController#" />
		</div>
		<div class="row">
			<label for="defaultTemplate">Default template:</label>
			<input type="text" name="defaultTemplate" id="defaultTemplate" class="text" value="#form.defaultTemplate#" />
		</div>
	</fieldset> --->

	<!--- Others --->
	<!--- <fieldset>
		<legend>Others</legend>

		<div class="row">
			<label for="showLocalFriendlyError">Show local friendly error:</label>
			<select name="showLocalFriendlyError" id="showLocalFriendlyError">
				<option value="true" <cfif application.showLocalFriendlyError>selected</cfif>>Yes</option>
				<option value="false" <cfif NOT application.showLocalFriendlyError>selected</cfif>>No</option>
			</select>
		</div>

		<div class="row">
			<label for="show404OnMissingController">Show 404 missing controller:</label>
			<select name="show404OnMissingController" id="show404OnMissingController">
				<option value="true" <cfif application.show404OnMissingController>selected</cfif>>Yes</option>
				<option value="false" <cfif NOT application.show404OnMissingController>selected</cfif>>No</option>
			</select>
		</div>

		<div class="row">
			<label for="canSendEmail">Can send email:</label>
			<select name="canSendEmail" id="canSendEmail">
				<option value="true" <cfif application.canSendEmail>selected</cfif>>Yes</option>
				<option value="false" <cfif NOT application.canSendEmail>selected</cfif>>No</option>
			</select>
		</div>

		<div class="row">
			<label for="guestDefaultController">Guest controller:</label>
			<input type="text" name="guestDefaultController" id="guestDefaultController" class="text" value="#form.guestDefaultController#" />
		</div>
		
		<div class="row">
			<label for="defaultView">Default view:</label>
			<input type="text" name="defaultView" id="defaultView" class="text" value="#form.defaultView#" />
		</div>
		
		<div class="row">
			<label for="extraAllowedScripts">Extra allowed scripts:</label>
			<input type="hidden" name="allowedScripts" value="index.cfm" />
			<input type="text" name="extraAllowedScripts" id="extraAllowedScripts" class="text" value="#application.core.trimChar(replace(application.allowedScripts, 'index.cfm', ''), ',')#" />
		</div>

	</fieldset> --->
		
	<!--- Others --->
	<!--- <fieldset>
		<legend>Maintenance</legend>
		
		<div class="row">
			<label for="maintenanceMode">Under maintenance:</label>
			<select name="maintenanceMode" id="maintenanceMode">
				<option value="true" <cfif application.maintenanceMode>selected</cfif>>Yes</option>
				<option value="false" <cfif NOT application.maintenanceMode>selected</cfif>>No</option>
			</select>
		</div>

		<div class="row">
			<label for="maintenancePage">Maintenance page:</label>
			<input type="text" name="maintenancePage" id="maintenancePage" class="text" value="#form.maintenancePage#" />
		</div>
	</fieldset> --->
	
	<div class="buttons">
		<input type="submit" name="save" class="button" value="Save" />
	</div>
</form>
</cfoutput>
</body>
</html>
