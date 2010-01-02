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
	

	<!--- Remove duplicates from an array --->
	<cffunction name="ArrayUnique" access="public" returntype="array">
		<cfargument name="arr" type="array" required="yes" hint="The original array" />
	
		<!--- Create a linked hashset java object as it has: 1) unique key and 2) order --->
		<cfset lhs = createObject("java", "java.util.LinkedHashSet").init(arguments.arr)>
		<cfset result = lhs.toArray()>
		
		<cfreturn result>
	
	</cffunction>
	

	<!--- Remove duplicates from a list --->
	<cffunction name="ListUnique" access="public" returntype="string">
		<cfargument name="ls" type="string" required="yes" hint="The original list" />
	
		<!--- Convert it to array to use the arrayUnique function --->
		<cfset result = arrayToList(this.ArrayUnique(listToArray(arguments.ls)))>
		
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
	
	
</cfcomponent>