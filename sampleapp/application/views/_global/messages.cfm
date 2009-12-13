<!--- 
	Summary:	Display error messages
 --->

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

