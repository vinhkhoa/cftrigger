<!---
	Project:	cfTrigger
	Summary:	Contains functions related to handling CSV file
	Log:
--->

<cfcomponent displayname="CSV" hint="Contains functions related to handling CSV file" output="false">

	<cfsetting enablecfoutputonly="yes">

	<!--- Initialise --->
	<cffunction name="init" access="public" output="false">
		
		<cfargument name="CSVClassPath" type="string" required="yes" hint="The class path/name of the CSV file">

		<cfset variables.CSVClassPath = arguments.CSVClassPath>
		
		<cfreturn this>
	
	</cffunction>


	<!--- ================================================= PUBLIC FUNCTIONS ================================================= --->
	
	<!--- Read CSV file into Query --->
	<cffunction name="CSVToQuery" access="public" output="false" returntype="query">
		<cfargument name="filePath" type="string" required="yes" hint="The CSV file path to be converted">
		<cfargument name="columnList" type="string" required="yes" hint="Query columns">
		<cfargument name="excludeHeading" type="boolean" required="no" default="false" hint="True: exclude the first row as it is heading">
		<cfset var local = StructNew()>
		<cfset var result = QueryNew(arguments.columnList,repeatString("varchar,",listLen(arguments.columnList)))>
		<cfset var arrColumns = listToArray(arguments.columnList)>

		<!--- Read the file --->
		<cftry>
			<cfset local.arrEntries = createObject("java", variables.CSVClassPath).read(javaCast("String", arguments.filePath))>
			
			<cfcatch type="any">
				<cfthrow object="#cfcatch#">
			</cfcatch>
		</cftry>

		<!--- Exclude heading (first row)? --->
		<cfif arguments.excludeHeading>
			<cfset local.startRow = 2>
		<cfelse>
			<cfset local.startRow = 1>
		</cfif>

		<!--- Add entries to the result query --->
		<cfloop from="#local.startRow#" to="#arrayLen(local.arrEntries)#" index="local.counter">
			<cfset local.thisEntry = local.arrEntries[local.counter]>
			<cfset queryAddRow(result)>
			
			<cfloop from="1" to="#arrayLen(local.thisEntry)#" index="local.index">
				<!--- Does this entry have this many fields? If not, just leave it empty --->
				<cfif arrayLen(local.thisEntry) ge local.index>
					<cfset querySetCell(result, arrColumns[local.index], local.thisEntry[local.index], result.recordCount)>
				</cfif>
			</cfloop>
		</cfloop>
	
		<cfreturn result>

	</cffunction>


	<!--- Write Query out to CSV file --->
	<cffunction name="QueryToCSV" access="public" output="false" returntype="struct">
		<cfargument name="query" type="query" required="yes" hint="The query containing data to be written into CSV file">
		<cfargument name="filePath" type="string" required="no" hint="The CSV file path to be written to. If not passed in, the CSV file will be saved into temp directory">
		<cfargument name="columnList" type="string" required="no" hint="Query columns">
		<cfargument name="headingList" type="string" required="no" hint="CSV Heading columns">
		<cfset var local = StructNew()>
		<cfset var result = StructNew()>
		<cfset result.error = "">
		<cfset result.filePath = "">
		
		<!--- Is CSV file path specified? --->
		<cfif NOT StructKeyExists(arguments, "filePath") OR trim(arguments.filePath) eq "">
			<cfset arguments.filePath = getTempDirectory() & createUUID() & ".csv">
		</cfif>
		
		<!--- Mark if specific columns and headings are specified --->
		<cfset local.specifiedColumnList = StructKeyExists(arguments, "columnList") AND trim(arguments.columnList) neq "">
		<cfset local.specifiedHeadingList = StructKeyExists(arguments, "headingList") AND trim(arguments.headingList) neq "">
		
		<!--- Convert this query to array --->
		<cfinvoke method="QueryToArray" returnvariable="local.arrContent">
			<cfinvokeargument name="query" value="#arguments.query#">
			<cfif local.specifiedColumnList>
				<cfinvokeargument name="columnList" value="#arguments.columnList#">
			</cfif>
		</cfinvoke>
		
		<!--- Add heading row (only if column list is specified) --->
		<cfif local.specifiedColumnList AND local.specifiedHeadingList>
			<cfset local.tempArray = ArrayNew(1)>
			<cfloop list="#arguments.headingList#" index="local.thisHeading">
				<cfset arrayAppend(local.tempArray, local.thisHeading)>
			</cfloop>
			<cfset arrayPrepend(local.arrContent, duplicate(local.tempArray))>
		</cfif>
		
		<cfset result = ArrayToCSV(local.arrContent, arguments.filePath)>
		
		<cfreturn result>

	</cffunction>


	<!--- Read CSV file into Array --->
	<cffunction name="CSVToArray" access="public" output="false" returntype="array">
		<cfargument name="filePath" type="string" required="yes" hint="The CSV file path to be converted">

		<!--- Read the file --->
		<cftry>
			<cfset result = createObject("java", variables.CSVClassPath).read(javaCast("String", arguments.filePath))>
			
			<cfcatch type="any">
				<cfthrow object="#cfcatch#">
			</cfcatch>
		</cftry>
		
		<cfreturn result>
		
	</cffunction>


	<!--- Write array out to CSV file --->
	<cffunction name="ArrayToCSV" access="public" output="false" returntype="struct">
		<cfargument name="array" type="array" required="yes" hint="The array containing data to be written into CSV file">
		<cfargument name="filePath" type="string" required="no" hint="The CSV file path to be written to. If not passed in, the CSV file will be saved into temp directory">
		<cfset var local = StructNew()>
		<cfset var result = StructNew()>
		<cfset result.error = "">
		<cfset result.filePath = "">
		
		<!--- Is CSV file path specified? --->
		<cfif NOT StructKeyExists(arguments, "filePath") OR trim(arguments.filePath) eq "">
			<cfset arguments.filePath = getTempDirectory() & createUUID() & ".csv">
		</cfif>
		
		<!--- Write the file --->
		<cftry>
			<cfset local.writeResult = createObject("java", variables.CSVClassPath).write(convert2DArrayToJava(arguments.array), javaCast("String", arguments.filePath))>
			
			<cfcatch type="any">
				<cfthrow object="#cfcatch#">
			</cfcatch>
		</cftry>

		<cfset result.filePath = arguments.filePath>

		<cfreturn result>

	</cffunction>


	<!--- ================================================= PRIVATE FUNCTIONS ================================================= --->
	
	<!--- Convert 2D array to Java array --->
	<cffunction name="convert2DArrayToJava" access="private" returntype="any">
	
		<cfargument name="array" type="Array" required="yes" hint="The array to be converted">
		<cfset var result = "">
		<cfset var local = StructNew()>
		
		<!--- Create java array dimension --->
		<cfset local.dimensions = ArrayNew(1)>
		<cfset local.dimensions[1] = arrayLen(arguments.array)>
		<cfset local.dimensions[2] = 1>

		<!--- Get some java class --->
		<cfset local.objStringClass = createObject("java", "java.lang.String").getClass()>
		<cfset local.objReflect = createObject("java", "java.lang.reflect.Array")>
		
		<!--- Create java array --->
		<cfset result = local.objReflect.newInstance(local.objStringClass, javaCast("int[]", local.dimensions))>
		
		<!--- Populate native array --->
		<cfloop from="1" to="#arrayLen(arguments.array)#" index="local.row">
			<cfset local.tempArray = ArrayNew(1)>
		
			<cfloop from="1" to="#arrayLen(arguments.array[1])#" index="local.col">
				<cfset arrayAppend(local.tempArray, arguments.array[local.row][local.col])>
			</cfloop>
			
			<cfset local.objReflect.set(result, javaCast("int", local.row - 1), javaCast("string[]", local.tempArray))>
		</cfloop>
	
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Convert query to array --->
	<cffunction name="QueryToArray" access="private" returntype="array">
		<cfargument name="query" type="query" required="yes" hint="The query to be converted">
		<cfargument name="columnList" type="string" required="no" hint="The columns to be converted. Do not pass in to include all columns">
		<cfset var local = StructNew()>
		<cfset var result = ArrayNew(2)>
		
		<!--- Get column names and types available in the query --->
		<cfset local.strFields = StructNew()>
		<cfloop array="#GetMetaData(arguments.query)#" index="local.thisCol">
			<cfset local.strFields[local.thisCol.name] = local.thisCol.typeName>
		</cfloop>

		<!--- Is there a column list specified? --->
		<cfif StructKeyExists(arguments, "columnList") AND trim(arguments.columnList) neq "">
			<!--- Remove invalid columns --->
			<cfset local.columnList = "">
			
			<cfloop list="#arguments.columnList#" index="local.thisColumn">
				<cfif listFindNoCase(arguments.query.columnList, local.thisColumn)>
					<cfset local.columnList = listAppend(local.columnList, local.thisColumn)>
				</cfif>
			</cfloop>
		<cfelse>
			<!--- No column list specified, get all columns of the query --->
			<cfset local.columnList = arguments.query.columnList>
		</cfif>
		
		<cfset result = ArrayNew(1)>
		
		<!--- Loop through query rows --->
		<cfloop query="arguments.query">
			<cfset local.tempArray = ArrayNew(1)>
			<cfset local.colNum = 1>			
			
			<!--- Loop through columns --->
			<cfloop list="#local.columnList#" index="local.thisColumn">
				<cfset local.thisValue = arguments.query[local.thisColumn][arguments.query.currentRow]>
			
				<!--- Format this field --->
				<cfswitch expression="#local.strFields[local.thisColumn]#">
					<cfcase value="timestamp">
						<cfset local.thisValue = dateFormat(local.thisValue, "dd/mm/yyyy") & " " & timeFormat(local.thisValue, "hh:mm:ss")>
					</cfcase>
				</cfswitch>
			
				<cfset arrayAppend(local.tempArray, local.thisValue)>
			</cfloop>
			
			<cfset arrayAppend(result, duplicate(local.tempArray))>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	

</cfcomponent>