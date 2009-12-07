<!---
	Project:	cfTrigger
	Company:	cfTrigger
	Summary:	Output library, handle the display of output	
	
	Log:
	
		Created:		29/11/2009		
		Modified:

--->

<cfcomponent displayname="Output" hint="Output library, handle the display of output">

	<cfsetting enablecfoutputonly="yes">
	
	<!--- Display text preserving its format --->
	<cffunction name="pre" access="public" returntype="string" hint="">
		<cfargument name="string" type="string" required="yes" hint="The text to be displayed">
		<cfset var result = HTMLEditFormat(arguments.string)>
		
		<!---<cfset result = reReplace(result, "[\t]{2,}", chr(9), "ALL")>
		<cfset result = reReplace(result, "[ ]{2,}", " ", "ALL")>--->
		<cfset result = reReplace(result, chr(9), "&nbsp;&nbsp;&nbsp;&nbsp;", "ALL")>
		<cfset result = reReplace(result, "[ ]{2,}", " ", "ALL")>
		<cfset result = replace(result, chr(13) & chr(10), "<br />", "ALL")>
		
		<!--- <cfset result = '<pre>' & result& '</pre>'> --->
		
		<cfreturn result>
		
	</cffunction>


	<!--- Create a friendly date representation for display purpose --->
	<cffunction name="displayDate" displayname="displayDate" access="public" returntype="string" output="no">
		<cfargument name="date" type="date" required="yes" hint="The original dates to start with">
		<cfset var result = arguments.date>
		
		<!--- Get the date part --->
		<cfset dDiff = dateDiff("d", arguments.date, now())>		
		<cfswitch expression="#dDiff#">
			<cfcase value="0"><cfset dPart = "today"></cfcase>
			<cfcase value="1"><cfset dPart = "yesterday"></cfcase>
			<cfcase value="2,3,4,5,6"><cfset dPart = "#dDiff# days ago"></cfcase>
			<cfcase value="7"><cfset dPart = "a week ago"></cfcase>
			<cfdefaultcase><cfset dPart = DateFormat(result, "dd mmm yyyy")></cfdefaultcase>
		</cfswitch>
		
		<cfset result = dPart & ", " & TimeFormat(result, "h:mm tt")>
		
		<cfreturn result>
		
	</cffunction>


</cfcomponent>
