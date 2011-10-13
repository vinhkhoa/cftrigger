<!---
	Project:	cfTrigger
	Summary:	Contains functions extended from coldfusion core/built in functions.
				For example, this file contains functions to enhance array, list, struct, query, etc.
	
	Log:
	
		Created:		21/12/2009		
		Modified:

--->

<cfcomponent displayname="Core" hint="Contains functions extended from coldfusion core/built in functions" output="false">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- ============================================= STRING ============================================ --->
	
	<!--- Capitalize the first word --->
	<cffunction name="capFirst" access="public" returntype="string" hint="" output="false">
		<cfargument name="string" type="string" required="yes" hint="The text to be capitalized">
		<cfset var result = "">
		
		<cfif len(arguments.string) eq 1>
			<cfset result = ucase(arguments.string)>
		<cfelseif len(arguments.string) gt 1>
			<cfset result = ucase(left(arguments.string, 1)) & right(arguments.string, len(arguments.string) - 1)>
		</cfif>

		<cfreturn result>

	</cffunction>


	<!--- Trim a particular character. Similar to the default trim which trims spaces, this one trims any characters --->
	<cffunction name="trimChar" access="public" returntype="string" hint="" output="false">
		<cfargument name="string" type="string" required="yes" hint="The text to be trimmed">
		<cfargument name="char" type="string" required="yes" hint="The char(s) to be trimmed">
		<cfset var result = "">
		<cfset var c = "">
		<cfset var i = "">
		<cfset var size = len(arguments.char)>
		
		<cfset result = arguments.string>
		
		<!--- Trim off every character, one by one --->
		<cfloop from="1" to="#size#" index="i">
			<cfset c = mid(arguments.char, i, 1)>
			
			<cfset result = reReplace(result, "^(#c#)+|(#c#)+$", "", "ALL")>
		</cfloop>
		
		<cfreturn result>

	</cffunction>


	<!--- Remove indentation of every line (tabs in specific for now, will add in spaces later on) --->
	<cffunction name="removeIndentation" access="public" returntype="string" hint="" output="false">
		<cfargument name="string" type="string" required="yes" hint="The text to be removed of tabs">
		<cfset var result = "">
		<cfset var minIndentation = 9999>
		<cfset var thisIndentation = "">
		<cfset var line = "">
		
		<!--- Find the smallest number of tabs that are preceding every line --->
		<cfloop list="#arguments.string#" delimiters="#chr(10)#" index="line">
			<cfif trim(line) neq "">
				<cfset thisIndentation = len(line) - len(reReplace(line, "^[\t]+", "", "ALL"))>
				<cfif thisIndentation lt minIndentation>
					<cfset minIndentation = thisIndentation>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfset result = reReplace(arguments.string, "(?m)^[\t]{#minIndentation#}", "", "ALL")>
		
		<cfreturn result>

	</cffunction>



	<!--- ============================================= LIST ============================================ --->

	<!--- Remove duplicates from a list --->
	<cffunction name="ListUnique" access="public" returntype="string" output="false">
		<cfargument name="list" type="string" required="yes" hint="The original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
	
		<!--- Convert it to array to use the arrayUnique function --->
		<cfset var result = arrayToList(this.ArrayUnique(listToArray(arguments.list, arguments.delimiter)), arguments.delimiter)>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the first number of items in a list. Similar to listFirst but more items --->
	<cffunction name="ListLeft" access="public" returntype="string" output="false">
		<cfargument name="list" type="string" required="yes" hint="The original list" />
		<cfargument name="size" type="numeric" required="yes" hint="The number of elements to get" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfset var count = 0>
		<cfloop list="#arguments.list#" index="item" delimiters="#arguments.delimiter#">
			<cfset count = count + 1>
			
			<!--- Within the range? Add in the item, otherwise stop looping --->
			<cfif count le arguments.size>
				<cfset result = listAppend(result, item, arguments.delimiter)>
			<cfelse>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the last number of items in a list. Similar to listRest but flexible number of items --->
	<cffunction name="ListRight" access="public" returntype="string" output="false">
		<cfargument name="list" type="string" required="yes" hint="The original list" />
		<cfargument name="size" type="numeric" required="yes" hint="The number of elements to get" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = arguments.list>
		
		<cfset result = this.ListReverse(result, arguments.delimiter)>
		<cfset result = this.ListLeft(result, arguments.size, arguments.delimiter)>
		<cfset result = this.ListReverse(result, arguments.delimiter)>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Reverse a list --->
	<cffunction name="ListReverse" access="public" returntype="string" output="false">
		<cfargument name="list" type="string" required="yes" hint="The original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		
		<cfset var result = arrayToList(this.arrayReverse(listToArray(arguments.list, arguments.delimiter)), arguments.delimiter)>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Delete the last item of the list --->
	<cffunction name="ListDeleteLast" access="public" returntype="string" output="false">
		<cfargument name="list" type="string" required="yes" hint="The original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
	
		<cfif listLen(arguments.list, arguments.delimiter)>
			<cfset result = listDeleteAt(arguments.list, listLen(arguments.list, arguments.delimiter), arguments.delimiter)>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the intersect of 2 lists: a new list that contains items that appaear in both of the original lists --->
	<cffunction name="ListIntersect" access="public" returntype="string" output="false">
		<cfargument name="list1" type="string" required="yes" hint="The first original list" />
		<cfargument name="list2" type="string" required="yes" hint="The second original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfset var ls1 = this.listUnique(arguments.list1, arguments.delimiter)>
		<cfset var ls2 = this.listUnique(arguments.list2, arguments.delimiter)>
		
		<cfloop list="#ls1#" index="item" delimiters="#arguments.delimiter#">
			<cfif listFindNoCase(ls2, item, arguments.delimiter)>
				<cfset result = listAppend(result, item, arguments.delimiter)>
			</cfif>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the union of 2 lists: a new list that contains items from both list --->
	<cffunction name="ListUnion" access="public" returntype="string" output="false">
		<cfargument name="list1" type="string" required="yes" hint="The first list" />
		<cfargument name="list2" type="string" required="yes" hint="The second list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<!--- Convert lists to arrays as arrays are more efficient --->
		<cfset var arr1 = listToArray(arguments.list1, arguments.delimiter)>
		<cfset var arr2 = listToArray(arguments.list2, arguments.delimiter)>

		<cfset result = arrayToList(this.ArrayUnion(arr1, arr2), arguments.delimiter)>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the minus of 2 lists: a new list that contains items that appaear the first list but not the second list --->
	<cffunction name="ListMinus" access="public" returntype="string" output="false">
		<cfargument name="list1" type="string" required="yes" hint="The first original list" />
		<cfargument name="list2" type="string" required="yes" hint="The second original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfset var ls1 = this.listUnique(arguments.list1, arguments.delimiter)>
		<cfset var ls2 = this.listUnique(arguments.list2, arguments.delimiter)>
		
		<cfloop list="#ls1#" index="item" delimiters="#arguments.delimiter#">
			<cfif NOT listFindNoCase(ls2, item, arguments.delimiter)>
				<cfset result = listAppend(result, item, arguments.delimiter)>
			</cfif>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Reorder an item on the list --->
	<cffunction name="ListReorderAt" access="public" returntype="string" output="false">
		<cfargument name="list" type="string" required="yes" hint="The original list" />
		<cfargument name="oldPosition" type="numeric" required="yes" hint="The original item position index" />
		<cfargument name="newPosition" type="numeric" required="yes" hint="The new item position index" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = arguments.list>
		<cfset var thisItem = "">
	
		<!--- Valid index? --->
		<cfif val(arguments.oldPosition) ge 1 AND val(arguments.oldPosition) le listLen(arguments.list)>
			<!--- Extract the item from the list --->
			<cfset thisItem = listGetAt(arguments.list, val(arguments.oldPosition), arguments.delimiter)>
			<cfset result = listDeleteAt(arguments.list, val(arguments.oldPosition), arguments.delimiter)>
			
			<!--- Insert the item into the new position --->
			<cfif val(arguments.newPosition) gt listLen(result)> 
				<cfset result = listAppend(result, thisItem, arguments.delimiter)>
			<cfelseif val(arguments.newPosition) le listLen(result) AND val(arguments.newPosition) ge 1>
				<cfset result = listInsertAt(result, val(arguments.newPosition), thisItem, arguments.delimiter)>
			<cfelse>
				<cfset result = listPrepend(result, thisItem, arguments.delimiter)>
			</cfif>
		</cfif>

		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Create a list from a range of numbers --->
	<cffunction name="ListFromRange" access="public" returntype="string" output="false">
		<cfargument name="leftBound" type="numeric" required="yes" hint="The left bound number" />
		<cfargument name="rightBound" type="numeric" required="yes" hint="The right bound number" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfloop from="#val(arguments.leftBound)#" to="#val(arguments.rightBound)#" index="i">
			<cfset result = listAppend(result, i, arguments.delimiter)>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Randomize a list --->
	<!--- Thanks to Ben Nadel blog post:
		http://www.bennadel.com/blog/280-Randomly-Sort-A-ColdFusion-Array-Updated-Thanks-Mark-Mandel.htm
	--->
	<cffunction name="ListRandomize" access="public" returntype="string" output="false">
		<cfargument name="list" type="string" required="yes" hint="The list to be randomized" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		<cfset var arr = "">
		
		<cfset arr = listToArray(arguments.list, arguments.delimiter)>
		<cfset CreateObject("java", "java.util.Collections").shuffle(arr)>
		<cfset result = arrayToList(arr, arguments.delimiter)>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Count the number of unique items in a list --->
	<cffunction name="ListLenUnique" access="public" returntype="string" output="false">
		<cfargument name="list" type="string" required="yes" hint="The original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
	
		<cfset var result = listLen(listUnique(arguments.list, arguments.delimiter), arguments.delimiter)>
		
		<cfreturn result>
	
	</cffunction>
	
	
	
	<!--- ============================================= ARRAY ============================================ --->

	<!--- Remove duplicates from an array --->
	<cffunction name="ArrayUnique" access="public" returntype="array" output="false">
		<cfargument name="array" type="array" required="yes" hint="The original array" />
		<cfset var result = ArrayNew(1)>
	
		<!--- Create a linked hashset java object as it has: 1) unique key and 2) order --->
		<cfset var hs = createObject("java", "java.util.HashSet").init(arguments.array)>
		<cfset result = hs.toArray()>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Get the union of 2 arrays: a new array that contains items from both arrays --->
	<cffunction name="ArrayUnion" access="public" returntype="array" output="false">
		<cfargument name="array1" type="array" required="yes" hint="The first array" />
		<cfargument name="array2" type="array" required="yes" hint="The second array" />
		<cfset var result = ArrayNew(1)>
		
		<cfset result.addAll(arguments.array1)>
		<cfset result.addAll(arguments.array2)>
		<cfset result = this.arrayUnique(result)>

		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Reverse an array --->
	<cffunction name="ArrayReverse" access="public" returntype="array" output="false">
		<cfargument name="array" type="array" required="yes" hint="The array to be reversed" />
		<cfset var result = ArrayNew(1)>
		
		<cfloop array="#arguments.array#" index="i">
			<cfset arrayPrepend(result, i)>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Randomize an array --->
	<!--- Thanks to Ben Nadel blog post:
		http://www.bennadel.com/blog/280-Randomly-Sort-A-ColdFusion-Array-Updated-Thanks-Mark-Mandel.htm
	--->
	<cffunction name="ArrayRandomize" access="public" returntype="array" output="false">
		<cfargument name="array" type="array" required="yes" hint="The array to be randomized" />
		<cfset var result = arguments.array>
		
		<cfset CreateObject("java", "java.util.Collections").shuffle(result)>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Convert 2D array to Java array --->
	<cffunction name="Array2DToJava" access="private" returntype="any">
	
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
	
	
	<!--- Convert array to Java array --->
	<cffunction name="ArrayToJava" access="private" returntype="any">
	
		<cfargument name="array" type="Array" required="yes" hint="The array to be converted">
		<cfset var result = "">
		<cfset var local = StructNew()>
		
		<!--- Create java array dimension --->
		<cfset local.dimensions = ArrayNew(1)>
		<cfset local.dimensions[1] = arrayLen(arguments.array)>

		<!--- Get some java class --->
		<cfset local.objStringClass = createObject("java", "java.lang.String").getClass()>
		<cfset local.objReflect = createObject("java", "java.lang.reflect.Array")>
		
		<!--- Create java array --->
		<cfset result = local.objReflect.newInstance(local.objStringClass, javaCast("int[]", local.dimensions))>
		
		<!--- Populate native array --->
		<cfloop from="1" to="#arrayLen(arguments.array)#" index="local.index">
			<cfset local.objReflect.set(result, javaCast("int", local.index - 1), arguments.array[local.index])>
		</cfloop>
	
		<cfreturn result>
	
	</cffunction>
	

	<!--- ============================================= STRUCT ============================================ --->
	
	<!--- Get the list of values inside a struct. Similar to StructKeyList. Ignores complex variables --->
	<cffunction name="structValueList" access="public" returntype="string" output="false">
		<cfargument name="struct" type="struct" required="yes" hint="The struct that contains the values">
		<cfset var result = "">
		<cfset var v = "">
		
		<cfloop collection="#arguments.struct#" item="k">
			<cfset v = arguments.struct[k]>
			
			<!--- Ignore complex and empty values --->
			<cfif isSimpleValue(v) AND trim(v) neq "">
				<cfset result = listAppend(result, v)>
			</cfif>
		</cfloop>

		<cfreturn result>

	</cffunction>



	<!--- ============================================= QUERY ============================================ --->
	
	<!--- Sort a query based on a custom list --->
	<cffunction name="QuerySort" displayname="QuerySort" access="public" hint="Sort a query based on a custom list" returntype="query" output="false">
		<cfargument name="query" type="query" required="yes" hint="The query to be sorted">
		<cfargument name="columnName" type="string" required="yes" hint="The name of the column to be sorted">
		<cfargument name="columnType" type="string" required="no" default="numeric" hint="The column type. Possible values: numeric, varchar">
		<cfargument name="orderList" type="string" required="yes" hint="The lsit used to sort the query">
		<cfargument name="otherOrders" type="string" required="no" default="" hint="After order by the value list, also order by these criteria">
		<cfargument name="orderColumnName" type="string" required="no" default="orderNo" hint="The name of the column containing the order number">
		<cfset var qResult = "">
		
		<!--- Make the order list unique to avoid duplicating query records --->
		<cfset arguments.orderList = ListUnique(arguments.orderList)>
		
		<cfquery name="qResult" dbtype="query">
			<cfloop from="1" to="#listLen(arguments.orderList)#" index="order">
				SELECT *, #order# AS #arguments.orderColumnName#
				FROM arguments.query
				WHERE #arguments.columnName# = <cfqueryparam value="#listGetAt(arguments.orderList, order)#" cfsqltype="cf_sql_#arguments.columnType#" />
				
				UNION
			</cfloop>
	
			SELECT *, #listLen(arguments.orderList) + 1# AS #arguments.orderColumnName#
			FROM arguments.query
			WHERE #arguments.columnName# NOT IN (<cfqueryparam value="#arguments.orderList#" list="yes" cfsqltype="cf_sql_#arguments.columnType#" />)
			
			ORDER BY #arguments.orderColumnName#
				<cfif trim(arguments.otherOrders) neq "">
					, #arguments.otherOrders#
				</cfif>
		</cfquery>
		
		<cfreturn qResult>
		
	</cffunction>
	

	<!--- Group query records --->
	<cffunction name="QueryGroup" displayname="QueryGroup" access="public" hint="Group query records" returntype="query" output="false">
		<cfargument name="query" type="query" required="yes" hint="The query to be sorted">
		<cfargument name="groupBy" type="string" required="yes" hint="The name of the column to be grouped by">
		<cfargument name="groupColumns" type="string" required="yes" hint="The columns to be combined/group">
		<cfargument name="delimiter" type="string" required="no" default="," hint="The grouped col delimiter">

		<cfset var qGrouped = QueryNew(arguments.query.columnList,repeatString("varchar,", listLen(arguments.query.columnList) - 1) & "varchar")>
		<cfset var grouped = "">
		
		<cfoutput query="arguments.query" group="#arguments.groupBy#">
			<!--- Create empty groups --->
			<cfset grouped = StructNew()>
			<cfloop list="#arguments.groupColumns#" index="col">
				<cfset grouped[col] = "">
			</cfloop>
			
			<!--- Group the rows --->
			<cfoutput>
				<cfloop list="#arguments.groupColumns#" index="col">
					<cfset grouped[col] = listAppend(grouped[col], arguments.query[col][arguments.query.currentRow], arguments.delimiter)>
				</cfloop>
			</cfoutput>
			
			<!--- Add these groups of rows into the new query --->
			<cfset queryAddRow(qGrouped)>
			<cfloop list="#arguments.query.columnList#" index="col">
				<cfif listFindNoCase(arguments.groupColumns, col)>
					<cfset querySetCell(qGrouped, col, application.core.listUnique(grouped[col], arguments.delimiter), qGrouped.recordCount)>
				<cfelse>
					<cfset querySetCell(qGrouped, col, arguments.query[col][arguments.query.currentRow], qGrouped.recordCount)>
				</cfif>
			</cfloop>
		</cfoutput>
		
		<cfreturn qGrouped>	
		
	</cffunction>
			
	
	<!--- Get executed SQL statement --->
	<cffunction name="getSQLStatement" displayname="getSQLStatement" access="public" hint="Get executed SQL statement" returntype="string" output="false">
	
		<cfargument name="sqlResult" type="struct" required="yes" hint="The SQL result">
		<cfset var result = "">
		<cfset var local = StructNew()>
		
		<cfset result = HTMLEditFormat(trim(application.core.removeIndentation(arguments.sqlResult.sql)))>
		<cfif StructKeyExists(arguments.sqlResult, "sqlParameters") AND arrayLen(arguments.sqlResult.sqlParameters)>
			<cfloop array="#arguments.sqlResult.sqlParameters#" index="local.thisParam">
				<cfif LSIsDate(local.thisParam)>
					<cfset local.thisParam = "'" & dateFormat(local.thisParam, "yyyy-mm-dd") & timeFormat(local.thisParam, " hh:mm:ss.l") & "'">
				<cfelseif NOT isNumeric(local.thisParam)>
					<cfset local.thisParam = "'#local.thisParam#'">
				</cfif>
				
				<cfset result = replace(result, "?", "<strong>#local.thisParam#</strong>")>
			</cfloop>
		</cfif>
	
		<cfreturn result>
	
	</cffunction>
	

	<!--- Convert query to 2D array --->
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

	
	
	<!--- ============================================= OBJECT/COMPONENT ============================================ --->

	<!--- Retrieve private variables --->
	<cffunction name="getPrivate" displayname="getPrivate" access="private" returntype="struct" hint="Retrieve private variables" output="false">
		
		<cfargument name="group" type="boolean" required="no" default="true" hint="Group the local variables">
		<cfset var result = StructNew()>
		<cfset var thisVar = "">
		
		<!--- Group the variables? --->
		<cfif arguments.group>
			<cfset result.simpleValues = StructNew()>
			<cfset result.arrays = StructNew()>
			<cfset result.structs = StructNew()>
			<cfset result.queries = StructNew()>
			<cfset result.objects = StructNew()>
			<cfset result.privateFunctions = StructNew()>
			
			<cfloop collection="#variables#" item="thisVar">
			
				<!--- Simple values? --->
				<cfif isSimpleValue(variables[thisVar])>
					<cfset result.simpleValues[thisVar] = variables[thisVar]>
				
				<!--- Array? --->
				<cfelseif isArray(variables[thisVar])>
					<cfset result.arrays[thisVar] = variables[thisVar]>
				
				<!--- Struct? --->
				<cfelseif isStruct(variables[thisVar]) AND thisVar neq "this">
					<cfset result.structs[thisVar] = variables[thisVar]>
				
				<!--- Query? --->
				<cfelseif isQuery(variables[thisVar])>
					<cfset result.queries[thisVar] = variables[thisVar]>
				
				<!--- Object? --->
				<cfelseif isObject(variables[thisVar]) AND thisVar neq "this">
					<cfset result.objects[thisVar] = variables[thisVar]>
				
				<!--- Private custom functions? --->
				<cfelseif isCustomFunction(variables[thisVar]) AND variables[thisVar].access eq "private">
					<cfset result.privateFunctions[thisVar] = variables[thisVar]>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset result = variables>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Get private variables inside an object --->
	<cffunction name="getPrivateVariables" displayname="getPrivateVariables" access="public" hint="Get private variables inside an object" output="false">
	
		<cfargument name="object" type="component" required="yes" hint="The object to retrieve the private variables from">
		<cfargument name="group" type="boolean" required="no" default="true" hint="Group the local variables">
		<cfset var result = StructNew()>
		
		<!--- Create a random function name --->
		<cfset var funcName = reReplaceNoCase("f_#createUUID()#", "[^a-zA-Z0-9_]", "", "ALL")>
		<cfset arguments.object[funcName] = variables.getPrivate>
		<cfinvoke component="#arguments.object#" method="#funcName#" group="#arguments.group#" returnvariable="result">
		
		<!--- Remove this function --->
		<cfset StructDelete(arguments.object, funcName)>
		
		<cfreturn result>
		
	</cffunction>
		


	<!--- ============================================= OBJECT/COMPONENT ============================================ --->

	<!--- Extract cookies from HTTP response --->
	<cffunction name="getResponseCookies" displayname="getResponseCookies" access="public" returntype="struct" hint="Extract cookies from HTTP response">
		
		<cfargument name="response" type="struct" required="yes" hint="The HTTP response">
		<cfset var local = StructNew()>
		<cfset var result = StructNew()>
		
		<!--- Check that this response object contains new cookies --->
		<cfif StructKeyExists(arguments.response, "responseHeader") AND 
			  StructKeyExists(arguments.response.responseHeader, "set-cookie") AND
			  isArray(arguments.response.responseHeader["set-cookie"])>
			<cfloop array="#arguments.response.responseHeader['set-cookie']#" index="local.thisCookie">
				<cfset local.stCookie = StructNew()>
				
				<!--- Extract cookie name --->
				<cfset local.namePair = listFirst(local.thisCookie, ";")>
				<cfset local.cookieName = listFirst(local.namePair, "=")>
				<cfset local.cookieValue = listLast(local.namePair, "=")>
				<cfset local.thisCookie = listDeleteAt(local.thisCookie, 1)>
	
				<cfset local.stCookie.name = cookieName>
				<cfset local.stCookie.value = cookieValue>
				
				<!--- Extract cookie attributes --->
				<cfset local.stCookie.attributes = StructNew()>
				<cfloop list="#local.thisCookie#" index="local.pair">
					<cfset local.stCookie.attributes[listFirst(local.namePair, "=")] = listLast(local.namePair, "=")>
				</cfloop>
				
				<!--- Reconstruct the cookie --->
				<cfset result[local.stCookie.name] = StructNew()>
				<cfset result[local.stCookie.name].value = local.stCookie.value>
				<cfset result[local.stCookie.name].attributes = local.stCookie.attributes>
			</cfloop>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>



	<!--- ============================================= DATE ============================================ --->

	<!--- Create date from string in the format dd/mm/yyyy --->
	<cffunction name="dateParse" access="public" returntype="struct" hint="Create date from string">
		
		<cfargument name="strDate" type="string" required="yes" hint="The date string">
		<cfset var local = StructNew()>
		<cfset var result = StructNew()>
		<cfset result.date = "">
		<cfset result.valid = 0>
		<cfset result.error = "">
		
		<!--- Does the string contains all 3 parts? --->
		<cfif listLen(arguments.strDate, "/") eq 3>
			<cftry>
				<!--- Attempt to parse the date --->
				<cfset result.date = createDate(listLast(arguments.strDate, "/"), listGetAt(arguments.strDate, 2, "/"), listFirst(arguments.strDate, "/"))>
				<cfset result.valid = 1>
				
				<cfcatch type="any">
					<cfset result.valid = 0>
					<cfset result.error = "Invalid date">
				</cfcatch>
			</cftry>
			
			<!--- Validate the date range --->
			<cfif result.error eq "">
				<cfif (result.date lt createDate(1900,1,1)) OR (result.date gt createDate(3000,12,31))>
					<cfset result.valid = 0>
					<cfset result.error = "Date out of range">
				</cfif>
			</cfif>
		<cfelse>
			<cfset result.valid = 0>
			<cfset result.error = "Invalid date">
		</cfif>
		
		<cfreturn result>
		
	</cffunction>

</cfcomponent>