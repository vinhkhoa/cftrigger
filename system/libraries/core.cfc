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
		<cfargument name="str" type="string" required="yes" hint="The text to be capitalized">
		<cfset var result = "">
		
		<cfif len(arguments.str) eq 1>
			<cfset result = ucase(arguments.str)>
		<cfelseif len(arguments.str) gt 1>
			<cfset result = ucase(left(arguments.str, 1)) & right(arguments.str, len(arguments.str) - 1)>
		</cfif>

		<cfreturn result>

	</cffunction>


	<!--- Trim a particular character. Similar to the default trim which trims spaces, this one trims any characters --->
	<cffunction name="trimChar" access="public" returntype="string" hint="" output="false">
		<cfargument name="str" type="string" required="yes" hint="The text to be trimmed">
		<cfargument name="char" type="string" required="yes" hint="The char to be trimmed">
		<cfset var result = "">
		
		<!--- Trim left --->
		<cfset result = arguments.str>
		<cfset result = reReplaceNoCase(result, "^(#arguments.char#)+", "", "ALL")>
		<cfset result = reReplaceNoCase(result, "(#arguments.char#)+$", "", "ALL")>

		<cfreturn result>

	</cffunction>


	<!--- ============================================= LIST ============================================ --->

	<!--- Remove duplicates from a list --->
	<cffunction name="ListUnique" access="public" returntype="string" output="false">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
	
		<!--- Convert it to array to use the arrayUnique function --->
		<cfset var result = arrayToList(this.ArrayUnique(listToArray(arguments.ls, arguments.delimiter)), arguments.delimiter)>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the first number of items in a list. Similar to listFirst but more items --->
	<cffunction name="ListLeft" access="public" returntype="string" output="false">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
		<cfargument name="size" type="numeric" required="yes" hint="The number of elements to get" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfset var count = 0>
		<cfloop list="#arguments.ls#" index="item" delimiters="#arguments.delimiter#">
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
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
		<cfargument name="size" type="numeric" required="yes" hint="The number of elements to get" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = arguments.ls>
		
		<cfset result = this.ListReverse(result, arguments.delimiter)>
		<cfset result = this.ListLeft(result, arguments.size, arguments.delimiter)>
		<cfset result = this.ListReverse(result, arguments.delimiter)>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Reverse a list --->
	<cffunction name="ListReverse" access="public" returntype="string" output="false">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		
		<cfset var result = arrayToList(this.arrayReverse(listToArray(arguments.ls, arguments.delimiter)), arguments.delimiter)>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Delete the last item of the list --->
	<cffunction name="ListDeleteLast" access="public" returntype="string" output="false">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
	
		<cfif listLen(arguments.ls, arguments.delimiter)>
			<cfset result = listDeleteAt(arguments.ls, listLen(arguments.ls, arguments.delimiter), arguments.delimiter)>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the intersect of 2 lists: a new list that contains items that appaear in both of the original lists --->
	<cffunction name="ListIntersect" access="public" returntype="string" output="false">
		<cfargument name="ls1" type="string" required="yes" hint="The first original list" />
		<cfargument name="ls2" type="string" required="yes" hint="The second original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfset var list1 = this.listUnique(arguments.ls1, arguments.delimiter)>
		<cfset var list2 = this.listUnique(arguments.ls2, arguments.delimiter)>
		
		<cfloop list="#list1#" index="item" delimiters="#arguments.delimiter#">
			<cfif listFindNoCase(list2, item, arguments.delimiter)>
				<cfset result = listAppend(result, item, arguments.delimiter)>
			</cfif>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the union of 2 lists: a new list that contains items from both list --->
	<cffunction name="ListUnion" access="public" returntype="string" output="false">
		<cfargument name="ls1" type="string" required="yes" hint="The first list" />
		<cfargument name="ls2" type="string" required="yes" hint="The second list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<!--- Convert lists to arrays as arrays are more efficient --->
		<cfset var arr1 = listToArray(arguments.ls1, arguments.delimiter)>
		<cfset var arr2 = listToArray(arguments.ls2, arguments.delimiter)>

		<cfset result = arrayToList(this.ArrayUnion(arr1, arr2), arguments.delimiter)>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the minus of 2 lists: a new list that contains items that appaear the first list but not the second list --->
	<cffunction name="ListMinus" access="public" returntype="string" output="false">
		<cfargument name="ls1" type="string" required="yes" hint="The first original list" />
		<cfargument name="ls2" type="string" required="yes" hint="The second original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfset var list1 = this.listUnique(arguments.ls1, arguments.delimiter)>
		<cfset var list2 = this.listUnique(arguments.ls2, arguments.delimiter)>
		
		<cfloop list="#list1#" index="item" delimiters="#arguments.delimiter#">
			<cfif NOT listFindNoCase(list2, item, arguments.delimiter)>
				<cfset result = listAppend(result, item, arguments.delimiter)>
			</cfif>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Reorder an item on the list --->
	<cffunction name="ListReorderAt" access="public" returntype="string" output="false">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
		<cfargument name="oldPosition" type="numeric" required="yes" hint="The original item position index" />
		<cfargument name="newPosition" type="numeric" required="yes" hint="The new item position index" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = arguments.ls>
		<cfset var thisItem = "">
	
		<!--- Valid index? --->
		<cfif val(arguments.oldPosition) ge 1 AND val(arguments.oldPosition) le listLen(arguments.ls)>
			<!--- Extract the item from the list --->
			<cfset thisItem = listGetAt(arguments.ls, val(arguments.oldPosition), arguments.delimiter)>
			<cfset result = listDeleteAt(arguments.ls, val(arguments.oldPosition), arguments.delimiter)>
			
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
		<cfset var result = "">
		
		<cfloop from="#val(arguments.leftBound)#" to="#val(arguments.rightBound)#" index="i">
			<cfset result = listAppend(result, i)>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- ============================================= ARRAY ============================================ --->

	<!--- Remove duplicates from an array --->
	<cffunction name="ArrayUnique" access="public" returntype="array" output="false">
		<cfargument name="arr" type="array" required="yes" hint="The original array" />
		<cfset var result = ArrayNew(1)>
	
		<!--- Create a linked hashset java object as it has: 1) unique key and 2) order --->
		<cfset var lhs = createObject("java", "java.util.LinkedHashSet").init(arguments.arr)>
		<cfset result = lhs.toArray()>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Get the union of 2 arrays: a new array that contains items from both arrays --->
	<cffunction name="ArrayUnion" access="public" returntype="array" output="false">
		<cfargument name="arr1" type="array" required="yes" hint="The first array" />
		<cfargument name="arr2" type="array" required="yes" hint="The second array" />
		<cfset var result = ArrayNew(1)>
		
		<cfset result.addAll(arguments.arr1)>
		<cfset result.addAll(arguments.arr2)>
		<cfset result = this.arrayUnique(result)>

		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Reverse an array --->
	<cffunction name="ArrayReverse" access="public" returntype="array" output="false">
		<cfargument name="arr" type="array" required="yes" hint="The first array" />
		<cfset var result = ArrayNew(1)>
		
		<cfloop array="#arguments.arr#" index="i">
			<cfset arrayPrepend(result, i)>
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
					, #otherOrders#
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
	
		<cfargument name="obj" type="component" required="yes" hint="The object to retrieve the private variables from">
		<cfargument name="group" type="boolean" required="no" default="true" hint="Group the local variables">
		<cfset var result = StructNew()>
		
		<!--- Create a random function name --->
		<cfset var funcName = reReplaceNoCase("f_#createUUID()#", "[^a-zA-Z0-9_]", "", "ALL")>
		<cfset arguments.obj[funcName] = variables.getPrivate>
		<cfinvoke component="#arguments.obj#" method="#funcName#" group="#arguments.group#" returnvariable="result">
		
		<!--- Remove this function --->
		<cfset StructDelete(arguments.obj, funcName)>
		
		<cfreturn result>
		
	</cffunction>
		
</cfcomponent>