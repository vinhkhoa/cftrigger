<!---
	Project:		cfTrigger
	Company:		cfTrigger
	Summary:		System text class
	
	Log:
	
	Created:		02/12/2009
	
	Modified:
	- 

--->

<cfcomponent displayname="Text">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Convert a number to word --->
	<cffunction name="numberToWord" displayname="numberToWord" access="public" returntype="string" hint="Convert a number to word">
		<cfargument name="number" type="numeric" required="yes" hint="The number to be converted to text">
		<cfset var result = "">
		
		<!--- Arrays --->
		<cfset words = arrayNew(2)>
		<cfset words[1][1] = "one">
		<cfset words[1][2] = "two">
		<cfset words[1][3] = "three">
		<cfset words[1][4] = "four">
		<cfset words[1][5] = "five">
		<cfset words[1][6] = "six">
		<cfset words[1][7] = "seven">
		<cfset words[1][8] = "eight">
		<cfset words[1][9] = "nine">
		<cfset words[1][10] = "ten">
		<cfset words[2][1] = "eleven">
		<cfset words[2][2] = "twelve">
		<cfset words[2][3] = "thirteen">
		<cfset words[2][4] = "fourteen">
		<cfset words[2][5] = "fifteen">
		<cfset words[2][6] = "sixteen">
		<cfset words[2][7] = "seventeen">
		<cfset words[2][8] = "eighteen">
		<cfset words[2][9] = "ninteen">
		<cfset words[2][10] = "twenty">
		
		<cfset teens = arrayNew(1)>
		<cfset teens[1] = "eleven">
		<cfset teens[2] = "twelve">
		<cfset teens[3] = "thirteen">
		<cfset teens[4] = "fourteen">
		<cfset teens[5] = "fifteen">
		<cfset teens[6] = "sixteen">
		<cfset teens[7] = "seventeen">
		<cfset teens[8] = "eighteen">
		<cfset teens[9] = "ninteen">
		
		<cfset ties = arrayNew(1)>
		<cfset ties[1] = "ten">
		<cfset ties[2] = "twenty">
		<cfset ties[3] = "thirty">
		<cfset ties[4] = "forty">
		<cfset ties[5] = "fifty">
		<cfset ties[6] = "sixty">
		<cfset ties[7] = "seventy">
		<cfset ties[8] = "eighty">
		<cfset ties[9] = "ninty">
		
		<!--- <cfset digits = listToArray(reReplace(reverse(arguments.number), "(\d)", "\1,", "ALL"))>
		<cfdump var="#digits#">
		<cfabort> --->
		
		<cfif val(arguments.number) ge 1 AND val(arguments.number) le 10>
			<cfset result = words[1][val(arguments.number)]>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	
</cfcomponent>