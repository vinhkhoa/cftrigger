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
	
	
	<!--- Extract a phone number from some text --->
	<cffunction name="extractPhoneNumber" displayname="extractPhoneNumber" access="public" returntype="string" hint="Extract a phone number from some text">
		<cfargument name="string" type="string" required="yes" hint="The string that contains the phone number">
		<cfset var result = "">
		
		<cfset extractResult = reMatch("0[0-9]{9,9}", arguments.string)>
		
		<cfif arrayLen(extractResult)>
			<cfset result = extractResult[1]>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>

	<!--- Return an XML content to the browser. This function ensures there is no extra destructive spaces --->
	<cffunction name="returnXMLToBrowser">
		<cfargument name="xmlContent" type="string" required="yes" hint="Content of the xml to be returned">
		
		<cfsetting showdebugoutput="no">
		<cfcontent reset="yes" type="text/xml"><cfoutput>#trim(arguments.xmlContent)#</cfoutput>
		<cfabort>
	</cffunction>


	<!--- Strip tags from a string --->
	<cffunction name="stripTags" access="public" returntype="string" hint="">
		<cfargument name="string" type="string" required="yes" hint="The string that contains tags to be stripped out">
		<cfargument name="replaceWithSpace" type="boolean" required="no" default="false" hint="True: put in a space where tag is stripped out">
		
		<!--- Add in a space to replace tags? --->
		<cfif arguments.replaceWithSpace>
			<cfset replacement = " ">
		<cfelse>
			<cfset replacement = "">
		</cfif>
		
		<cfset result = reReplace(arguments.string, "</?[A-Za-z]+>", replacement, "ALL")>
		
		<cfreturn result>
	
	</cffunction>


	<!--- Capitalize the first letter --->
	<cffunction name="capFirst" access="public" returntype="string" hint="">
		<cfargument name="string" type="string" required="yes" hint="The text to be changed">
		<cfset var result = "">
		
		<cfif len(arguments.string) lt 2>
			<cfset result = uCase(arguments.string)>
		<cfelse>
			<cfset result = ucase(left(arguments.string, 1)) & right(arguments.string, len(arguments.string) - 1)>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>


	<!--- Capitalize the first letter of each word --->
	<cffunction name="capWords" access="public" returntype="string" hint="">
		<cfargument name="string" type="string" required="yes" hint="The text to be changed">
		<cfset var result = "">
		
		<cfloop list="#arguments.string#" index="word" delimiters=" ">
			<cfset result = listAppend(result, this.capFirst(word), " ")>
		</cfloop>
		
		<cfreturn result>
		
	</cffunction>


</cfcomponent>
