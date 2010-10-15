<!---
	Project:	cfTrigger
	Summary:	Output library, handle the display of output	
	
	Log:
	
		Created:		29/11/2009		
		Modified:

--->

<cfcomponent displayname="Output" hint="Output library, handle the display of output" output="false">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Display text preserving its format --->
	<cffunction name="pre" access="public" returntype="string" hint="" output="false">
		<cfargument name="string" type="string" required="yes" hint="The text to be displayed">
		<cfset var result = HTMLEditFormat(arguments.string)>
		
		<!---<cfset result = reReplace(result, "[\t]{2,}", chr(9), "ALL")>
		<cfset result = reReplace(result, "[ ]{2,}", " ", "ALL")>--->
		<cfset result = reReplace(result, chr(9), "&nbsp;&nbsp;&nbsp;&nbsp;", "ALL")>
		<cfset result = reReplace(result, "[ ]{2,}", " ", "ALL")>
		<cfset result = reReplace(result, "(#chr(13)##chr(10)#){2,}", "</p><p>", "ALL")>
		<cfset result = replace(result, chr(13) & chr(10), "<br />", "ALL")>
		<cfset result = "<p>#result#</p>">

		<cfreturn result>
		
	</cffunction>


	<!--- Create a friendly date representation for display purpose --->
	<cffunction name="displayDate" displayname="displayDate" access="public" returntype="string" output="false">
		<cfargument name="date" type="date" required="yes" hint="The original dates to start with">
		<cfset var result = arguments.date>
		
		<!--- Get the date part --->
		<cfset var dDiff = dateDiff("d", arguments.date, now())>	
		<cfset var dPart = "">	
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
	<cffunction name="extractPhoneNumber" displayname="extractPhoneNumber" access="public" returntype="string" hint="Extract a phone number from some text" output="false">
		<cfargument name="string" type="string" required="yes" hint="The string that contains the phone number">
		<cfset var result = "">
		<cfset var extractResult = reMatch("0[0-9]{9,9}", arguments.string)>
		
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
	<cffunction name="stripTags" access="public" returntype="string" hint="" output="false">
		<cfargument name="string" type="string" required="yes" hint="The string that contains tags to be stripped out">
		<cfargument name="replaceWithSpace" type="boolean" required="no" default="false" hint="True: put in a space where tag is stripped out">
		<cfset var result = "">
		<cfset var replacement = "">
		
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
	<cffunction name="capFirst" access="public" returntype="string" hint="" output="false">
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
	<cffunction name="capWords" access="public" returntype="string" hint="" output="false">
		<cfargument name="string" type="string" required="yes" hint="The text to be changed">
		<cfset var result = "">
		<cfset var word = "">
		
		<cfloop list="#arguments.string#" index="word" delimiters=" ">
			<cfset result = listAppend(result, this.capFirst(word), " ")>
		</cfloop>
		
		<cfreturn result>
		
	</cffunction>
	
	
	<!--- Display pagination --->
	<cffunction name="pagination" access="public" hint="">
		<cfargument name="page" type="numeric" required="no" default="1" hint="The current page">
		<cfargument name="total" type="numeric" required="yes" hint="The total number of records">	
		<cfargument name="pageSize" type="numeric" required="yes" hint="The number of records per page">	
		<cfargument name="paginationSize" type="numeric" required="yes" hint="The number of pages to be shown in the pagination">	
		<cfargument name="urlPageVariable" type="string" required="no" default="p" hint="The url variable that represents the current page">	
		<cfargument name="alternativePathInfo" type="string" required="no" hint="In case of no path info, use this one">	
		<cfargument name="paginationClassName" type="string" required="no" default="pagination" hint="The class name to be used for the pagination">	
		<cfargument name="nextPrevClassName" type="string" required="no" default="nextprev" hint="The class name to be used for the next and previous buttons">	
		<cfargument name="paginationId" type="string" required="no" default="pagination" hint="The ID to be used for the pagination">	
		<cfset var thisPage = "">
		<cfset var pageNum = "">
		<cfset var queryString = "">
		<cfset var pathInfo = "">
		<cfset var pageURL = "">
		<cfset var leftPage = "">
		<cfset var rightPage = "">
		<cfset var counter = "">
	
		<cfif val(arguments.total)>
			<!--- Validate the current page number --->
			<cfset thisPage = round(val(arguments.page))>
			<cfif thisPage lt 1>
				<cfset thisPage = 1>
			</cfif>
			
			<!--- Get the total number of pages --->
			<cfif val(arguments.total) MOD val(arguments.pageSize) eq 0>
				<cfset pageNum = val(arguments.total) / val(arguments.pageSize)>
			<cfelse>
				<cfset pageNum = int(val(arguments.total) / val(arguments.pageSize)) + 1>
			</cfif>
			
			<!--- Remove page number from the query string --->
			<cfset queryString = reReplaceNoCase(reReplaceNoCase(reReplaceNoCase(CGI.QUERY_STRING, "#urlPageVariable#=[^&]+", "", "ALL"), "^&|&$", "", "ALL"), "[&]+", "&amp;", "ALL")>
			<cfif queryString neq "">
				<cfset queryString = queryString & "&amp;">
			</cfif>

			<!--- Get the current page url. If home page, set it to the ad list page --->
			<cfif CGI.PATH_INFO eq "" AND StructKeyExists(arguments, "alternativePathInfo")>
				<cfset pathInfo = arguments.alternativePathInfo>
			<cfelse>
				<cfset pathInfo = CGI.PATH_INFO>
			</cfif>
			<cfset pageURL = application.baseURL & pathInfo & "?" & queryString>
			
			<!--- ============================ Pagination ============================ --->
			
			<!--- Get the left and right number of pages --->
			<cfif val(arguments.paginationSize) MOD 2 eq 0>
				<cfset leftPage = thisPage - val(arguments.paginationSize)/2 + 1>
			<cfelse>
				<cfset leftPage = thisPage - (val(arguments.paginationSize) - 1)/2>
			</cfif>
			<cfset rightPage = leftPage + val(arguments.paginationSize) - 1>
			
			<!--- If both page ends are outside of range --->
			<cfif leftPage le 1 AND rightPage gt pageNum>
				<cfset leftPage = 1>
				<cfset rightPage = pageNum>
			
			<!--- If left page is inside range, but right page is not --->
			<cfelseif leftPage ge 1 AND rightPage gt pageNum>
				<cfset rightPage = pageNum>
				<cfset leftPage = max(rightPage - val(arguments.paginationSize) + 1, 1)>
			
			<!--- If left page is out side of range, but right is inside --->
			<cfelseif leftPage lt 1 AND rightPage le pageNum>
				<cfset leftPage = 1>
				<cfset rightPage = min(leftPage + val(arguments.paginationSize) - 1, pageNum)>
			<cfelse>
				<!--- Do nothing --->
			</cfif>
			
			<!--- Has more than one page to display the pagination? --->
			<cfif pageNum gt 1>
				<cfoutput>
				<ul id="#arguments.paginationId#" class="#arguments.paginationClassName#">
				
				<!--- Check if to display the "First" and "Previous" links --->
				<cfif thisPage gt 1>
					<li><a href="#pageURL##urlPageVariable#=1" class="#nextPrevClassName#">First</a></li>
					<li><a href="#pageURL##urlPageVariable#=#thisPage - 1#" class="#nextPrevClassName#">&lt; Prev</a></li>
				<cfelse>
					<li><span class="#nextPrevClassName#">First</span></li>
					<li><span class="#nextPrevClassName#">&lt; Prev</span></li>
				</cfif>
				
				<!--- Only display page in range --->
				<cfloop from="1" to="#pageNum#" index="counter">
					<cfif counter ge leftPage AND counter le rightPage>
						<cfif counter eq thisPage>
							<li class="current"><span>Page </span>#counter#</li>
						<cfelse>
							<li><a href="#pageURL##urlPageVariable#=#counter#"><span>Page </span>#counter#</a></li>
						</cfif>
					</cfif>
				</cfloop>
				
				<!--- Check if to display the "Next" and "Last" links --->
				<cfif thisPage lt pageNum>
					<li><a href="#pageURL##urlPageVariable#=#thisPage + 1#" class="#nextPrevClassName#">Next &gt;</a></li>
					<li><a href="#pageURL##urlPageVariable#=#pageNum#" class="#nextPrevClassName#">Last</a></li>
				<cfelse>
					<li><span class="#nextPrevClassName#">Next &gt;</span></li>
					<li><span class="#nextPrevClassName#">Last</span></li>
				</cfif>
				
				</ul>
				</cfoutput>	
			</cfif>
		</cfif>
		
	</cffunction>


	<!--- Download a file --->
	<cffunction name="download" access="public" hint="Download a file" output="false">
		<cfargument name="filePath" type="string" required="yes" hint="Full path to the file to be downloaded">
		<cfargument name="downloadFileName" type="string" required="no" hint="Filename that the end user will save the file as">
		<cfargument name="MIMEType" type="string" required="no" hint="Specify the MIME type for download. If not passed in, an appropriate mime type will be used based on the file extension">
		
		<!--- Get the filename for download --->
		<cfif NOT StructKeyExists(arguments, "downloadFileName")>
			<cfset arguments.downloadFileName = getFileFromPath(argumenst.filePath)>
		</cfif>

		<!--- Get the download file MIME type --->
		<cfif NOT StructKeyExists(arguments, "MIMEType")>
			<cfset arguments.MIMEType = getPageContext().getServletContext().getMimeType(arguments.downloadFileName)>
		</cfif>
		
		<!--- Download the file now --->
		<cfheader name="content-disposition" value="attachment;filename=""#arguments.downloadFileName#""">
		<cfcontent type="#arguments.MIMEType#" file="#arguments.filePath#">
		
	</cffunction>


</cfcomponent>
