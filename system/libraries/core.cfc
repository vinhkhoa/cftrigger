<!---
	Project:	cfTrigger
	Company:	cfTrigger
	Summary:	Contains functions extended from coldfusion core/built in functions.
				For example, this file contains functions to enhance array, list, struct, query, etc.
	
	Log:
	
		Created:		21/12/2009		
		Modified:

--->

<cfcomponent displayname="Core" hint="Contains functions extended from coldfusion core/built in functions">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Get the list of values inside a struct. Similar to StructKeyList. Ignores complex variables --->
	<cffunction name="structValueList" access="public" returntype="string" hint="">
		<cfargument name="struct" type="struct" required="yes" hint="The struct that contains the values">
		<cfset var result = "">
		
		<cfloop collection="#arguments.struct#" item="k">
			<cfset v = arguments.struct[k]>
			
			<!--- Ignore complex and empty values --->
			<cfif isSimpleValue(v) AND trim(v) neq "">
				<cfset result = listAppend(result, v)>
			</cfif>
		</cfloop>

		<cfreturn result>

	</cffunction>


	<!--- ============================================= LIST ============================================ --->

	<!--- Remove duplicates from a list --->
	<cffunction name="ListUnique" access="public" returntype="string">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
	
		<!--- Convert it to array to use the arrayUnique function --->
		<cfset result = arrayToList(this.ArrayUnique(listToArray(arguments.ls)))>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the first number of items in a list. Similar to listFirst but more items --->
	<cffunction name="ListLeft" access="public" returntype="string">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
		<cfargument name="size" type="numeric" required="yes" hint="The number of elements to get" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfset count = 0>
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
	<cffunction name="ListRight" access="public" returntype="string">
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
	<cffunction name="ListReverse" access="public" returntype="string">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfset arr = arrayNew(1)>
		<cfset listSize = listLen(arguments.ls, arguments.delimiter)>
		<cfset counter = 0>
		<cfloop list="#arguments.ls#" index="item" delimiters="#arguments.delimiter#">
			<cfset counter = counter + 1>
			<cfset arr[listSize - counter + 1] = item>
		</cfloop>
		<cfset result = arrayToList(arr, arguments.delimiter)>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Delete the last item of the list --->
	<cffunction name="ListDeleteLast" access="public" returntype="string">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
	
		<cfif listLen(arguments.ls, arguments.delimiter)>
			<cfset result = listDeleteAt(arguments.ls, listLen(arguments.ls, arguments.delimiter), arguments.delimiter)>
		</cfif>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the intersect of 2 lists: a new list that contains items that appaear in both of the original lists --->
	<cffunction name="ListIntersect" access="public" returntype="string">
		<cfargument name="ls1" type="string" required="yes" hint="The first original list" />
		<cfargument name="ls2" type="string" required="yes" hint="The second original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfset ls1 = this.listUnique(arguments.ls1, arguments.delimiter)>
		<cfset ls2 = this.listUnique(arguments.ls2, arguments.delimiter)>
		
		<cfloop list="#ls1#" index="item" delimiters="#arguments.delimiter#">
			<cfif listFindNoCase(ls2, item, arguments.delimiter)>
				<cfset result = listAppend(result, item, arguments.delimiter)>
			</cfif>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the union of 2 lists: a new list that contains items from both list --->
	<cffunction name="ListUnion" access="public" returntype="string">
		<cfargument name="ls1" type="string" required="yes" hint="The first list" />
		<cfargument name="ls2" type="string" required="yes" hint="The second list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<!--- Convert lists to arrays as arrays are more efficient --->
		<cfset arr1 = listToArray(arguments.ls1, arguments.delimiter)>
		<cfset arr2 = listToArray(arguments.ls2, arguments.delimiter)>

		<cfset result = arrayToList(this.ArrayUnion(arr1, arr2), arguments.delimiter)>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Get the minus of 2 lists: a new list that contains items that appaear the first list but not the second list --->
	<cffunction name="ListMinus" access="public" returntype="string">
		<cfargument name="ls1" type="string" required="yes" hint="The first original list" />
		<cfargument name="ls2" type="string" required="yes" hint="The second original list" />
		<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />
		<cfset var result = "">
		
		<cfset ls1 = this.listUnique(arguments.ls1, arguments.delimiter)>
		<cfset ls2 = this.listUnique(arguments.ls2, arguments.delimiter)>
		
		<cfloop list="#ls1#" index="item" delimiters="#arguments.delimiter#">
			<cfif NOT listFindNoCase(ls2, item, arguments.delimiter)>
				<cfset result = listAppend(result, item, arguments.delimiter)>
			</cfif>
		</cfloop>
		
		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Reorder an item on the list --->
	<cffunction name="ListReorderAt" access="public" returntype="string">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
		<cfargument name="oldPosition" type="numeric" required="yes" hint="The original item position index" />
		<cfargument name="newPosition" type="numeric" required="yes" hint="The new item position index" />
		<cfset var result = arguments.ls>
	
		<!--- Valid index? --->
		<cfif val(arguments.oldPosition) ge 1 AND val(arguments.oldPosition) le listLen(arguments.ls)>
			<!--- Extract the item from the list --->
			<cfset thisItem = listGetAt(arguments.ls, val(arguments.oldPosition))>
			<cfset result = listDeleteAt(arguments.ls, val(arguments.oldPosition))>
			
			<!--- Insert the item into the new position --->
			<cfif val(arguments.newPosition) le listLen(result)>
				<cfset result = listInsertAt(result, val(arguments.newPosition), thisItem)>
			<cfelse>
				<cfset result = listAppend(result, thisItem)>
			</cfif>
		</cfif>

		<cfreturn result>
	
	</cffunction>
	
	
	<!--- Create a list from a range of numbers --->
	<cffunction name="ListFromRange" access="public" returntype="string">
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
	<cffunction name="ArrayUnique" access="public" returntype="array">
		<cfargument name="arr" type="array" required="yes" hint="The original array" />
		<cfset var result = ArrayNew(1)>
	
		<!--- Create a linked hashset java object as it has: 1) unique key and 2) order --->
		<cfset lhs = createObject("java", "java.util.LinkedHashSet").init(arguments.arr)>
		<cfset result = lhs.toArray()>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Get the union of 2 arrays: a new array that contains items from both array --->
	<cffunction name="ArrayUnion" access="public" returntype="array">
		<cfargument name="arr1" type="array" required="yes" hint="The first array" />
		<cfargument name="arr2" type="array" required="yes" hint="The second array" />
		<cfset var result = ArrayNew(1)>
		
		<!--- Add 2 arrays together --->
		<cfloop array="#arguments.arr2#" index="item">
			<cfset arrayAppend(arguments.arr1, item)>
		</cfloop>
		<cfset result = this.arrayUnique(arr1)>

		<cfreturn result>
	
	</cffunction>
	
	
	<!--- ============================================= STRUCT ============================================ --->
	
	<!--- ============================================= QUERY ============================================ --->
	
	<!--- Sort a query based on a custom list --->
	<cffunction name="QuerySort" displayname="QuerySort" access="public" hint="Sort a query based on a custom list" returntype="query">
		<cfargument name="query" type="query" required="yes" hint="The query to be sorted">
		<cfargument name="columnName" type="string" required="yes" hint="The name of the column to be sorted">
		<cfargument name="columnType" type="string" required="yes" default="numeric" hint="The column type. Possible values: numeric, varchar">
		<cfargument name="orderList" type="string" required="yes" hint="The lsit used to sort the query">
		<cfargument name="otherOrders" type="string" required="no" default="" hint="After order by the value list, also order by these criteria">
		<cfargument name="orderColumnName" type="string" required="no" default="orderNo" hint="The name of the column containing the order number">
		
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
	

</cfcomponent>