<cfcomponent name="POI" output="false">

	<!--- Initialise --->
	<cffunction name="init" access="public" output="false">

		<cfargument name="excelClassPath" type="string" required="yes" hint="The class path/name of the Excel java file">

		<cfset variables.excelClassPath = arguments.excelClassPath>
		
		<cfreturn this>
	
	</cffunction>


	<!--- ================================================= PUBLIC FUNCTIONS ================================================= --->
	
	<!--- Convert Query to Excel --->
	<cffunction name="QueryToExcel" access="public" output="false" returntype="struct">
		<cfargument name="query" type="query" required="yes" hint="The query to be converted to Excel">
		<cfargument name="columnList" type="string" required="no" hint="The columns to be included">
		<cfargument name="headingList" type="string" required="no" hint="The column headings to be included">
		<cfset var local = StructNew()>
		<cfset var result = StructNew()>
		<cfset result.error = "">
		<cfset result.filePath = "">
		
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
		
		<cfset result = ArrayToExcel(local.arrContent)>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Convert 2D array to Excel --->
	<cffunction name="ArrayToExcel" access="public" output="false" returntype="struct">
		<cfargument name="array" type="array" required="true" hint="The array to be converted to Excel">	
		<cfset var local = StructNew()>
		<cfset var result = StructNew()>
		<cfset result.error = "">
		<cfset result.filePath = getTempDirectory() & createUUID() & ".xls">		
		
		<!--- Create Excel file --->
		<cfset local.excel = createObject("java", variables.excelClassPath)>
		<cfset local.excel.write(convert2DArrayToJava(arguments.array), result.filePath)>
		
		<!--- Convert the file content to base 64 --->
		<cffile action="readBinary" file="#result.filePath#" variable="local.fileContent">
		<cfset result.base64Content = binaryEncode(local.fileContent, "base64")>
		
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
