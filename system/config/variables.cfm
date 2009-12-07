<!---
		
	Regards the session scope variables, we can't put this in the OnSessionStart because
	OnSessionStart method does not re-execute after user has logged out and log back in. The only time
	it will be executed again is when the session times out by inactivity.
	
	Here is what's gonna happen if we put these variable initilization on the OnSessionStart method: 
	
	1. User first time opens the browser, session variables are initialized with default values
	2. User browses around, everything good, nothing changes
	3. User logs out, StructClear(session) runs -> these variables are cleared (deleted permanently)
	4. User logs back in, OnSessionStart does not run again -> these variables are not vailable anymore!!!
	
--->
<cfparam name="session.UserId" default="">
<cfparam name="session.SysAdmin" default="false">
<cfparam name="session.message" default="">
<cfparam name="session.error" default="">
<cfparam name="session.errorList" default="#arrayNew(1)#">
<cfparam name="session.warning" default="">
<cfparam name="session.warningList" default="#arrayNew(1)#">
<cfparam name="url.scope" default="#application.defaultScope#">
<cfparam name="form.scope" default="#url.scope#">
<cfparam name="url.view" default="#application.defaultView#">
<cfparam name="form.view" default="#url.view#">
<cfparam name="form.action" default="">
<cfparam name="url.subView" default="">
<cfparam name="form.subView" default="#url.subView#">

