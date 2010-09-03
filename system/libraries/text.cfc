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
		<cfset var positions = listToArray(reReplace(reverse(arguments.number), "(\d)", "\1,", "ALL"))>
		<cfset var positionWords = arrayNew(1)>
		<cfset var thisNumber = int(val(arguments.number))>
		<cfset var units = "">
		<cfset var teens = "">
		<cfset var ties = "">
		<cfset var digit = "">
		<cfset var part1 = "">
		<cfset var part2 = "">
		<cfset var part1Value = "">
		<cfset var pos = "">

		<!--- Units --->
		<cfset units = arrayNew(1)>
		<cfset units[1] = "">
		<cfset units[2] = "one">
		<cfset units[3] = "two">
		<cfset units[4] = "three">
		<cfset units[5] = "four">
		<cfset units[6] = "five">
		<cfset units[7] = "six">
		<cfset units[8] = "seven">
		<cfset units[9] = "eight">
		<cfset units[10] = "nine">
		
		<!--- Teens --->
		<cfset teens = arrayNew(1)>
		<cfset teens[1] = "ten">
		<cfset teens[2] = "eleven">
		<cfset teens[3] = "twelve">
		<cfset teens[4] = "thirteen">
		<cfset teens[5] = "fourteen">
		<cfset teens[6] = "fifteen">
		<cfset teens[7] = "sixteen">
		<cfset teens[8] = "seventeen">
		<cfset teens[9] = "eighteen">
		<cfset teens[10] = "ninteen">
		
		<!--- Ties --->
		<cfset ties = arrayNew(1)>
		<cfset ties[1] = "">
		<cfset ties[2] = "">
		<cfset ties[3] = "twenty">
		<cfset ties[4] = "thirty">
		<cfset ties[5] = "forty">
		<cfset ties[6] = "fifty">
		<cfset ties[7] = "sixty">
		<cfset ties[8] = "seventy">
		<cfset ties[9] = "eighty">
		<cfset ties[10] = "ninty">

		<cfif thisNumber ge 1>
			<!--- 1 to 9 --->
			<cfif thisNumber le 9>
				<cfset result = units[thisNumber + 1]>
				
			<!--- 10 to 19 --->
			<cfelseif thisNumber le 19>
				<cfset result = teens[thisNumber - 9]>
				
			<!--- 20 to 99 --->
			<cfelseif thisNumber le 99>
				<cfloop from="1" to="#arrayLen(positions)#" index="pos">
					<cfset digit = positions[pos]>
					
					<!--- First digit? --->
					<cfif pos eq 1>
						<cfset positionWords[pos] = units[digit + 1]>
					<cfelse>
						<cfset positionWords[pos] = ties[digit + 1]>
					</cfif>
				</cfloop>
				
				<cfset result = trim(arrayToList(application.core.arrayReverse(positionWords), " "))>
			
			<!--- 100 to 999 --->
			<cfelseif thisNumber le 999>
				<cfset part1 = this.numberToWord(thisNumber MOD 100)>
				<cfset part2 = units[positions[3] + 1]>
				
				<!--- Anything in part 1? --->
				<cfif part1 eq "">
					<cfset result = part2 & " hundred">
				<cfelse>
					<cfset result = part2 & " hundred and " & part1>
				</cfif>
				
			<!--- 1000 to 9999 --->
			<cfelseif thisNumber le 9999>
				<cfset part1Value = thisNumber MOD 1000>
				<cfset part1 = this.numberToWord(part1Value)>
				<cfset part2 = units[positions[4] + 1]>
				
				<!--- Anything in part 1? --->
				<cfif part1 eq "">
					<cfset result = part2 & " thousand">
				<cfelse>
					<!--- Part 1 from 1 to 99 --->
					<cfif part1Value lt 100>
						<cfset result = part2 & " thousand and " & part1>
					<cfelse>
						<cfset result = part2 & " thousand " & part1>
					</cfif>
				</cfif>
			<cfelse>
				<cfset result = "[Error!! the number is too big]">
			</cfif>
		</cfif>

		<cfreturn result>
		
	</cffunction>
	
</cfcomponent>