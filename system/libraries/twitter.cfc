<!---
	Project:	cfTrigger
	Company:	cfTrigger
	Summary:	Twitter library, used to handle functions related to twitter
	
	=========================================================================
	
	This function is from the following source. Big thanks to Andy Jarrett!
	SOME SMALL MODIFICATIONS SUCH AS SPACING AND COMMENTS ARE MADE TO MAKE THE CODE FIT INTO CFTRIGGER STYLE
	
	Filename: twitterCFC.cfc
	Creation Date: 18/July/2007
	Original Author: Andy Jarrett
	Revision: $Rev:14 $
	$LastChangedBy:andyj $
	$LastChangedDate:2007-11-17 15:36:21 +0000 (Sat, 17 Nov 2007) $
	Description:
	TwitterCFC
	
	Methods:
	init(username,password)
	postToTwitter(status,username,password)
	getFriendsTimeline(username,password)
	getPublicTimeline()

--->

<cfcomponent displayname="Twitter" hint="Twitter library, used to handle functions related to twitter">

	<cfsetting enablecfoutputonly="yes">


	<!--- Initialize the library --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="username" required="true" />
		<cfargument name="password" required="true" />
		
		<cfset instance = structNew() />
		<cfset instance.username =  arguments.username />
		<cfset instance.password =  arguments.password />
	
		<!--- Check that the user is authorised --->
		<cfset verifyCredentials(arguments.username, arguments.password) />	
			
		<cfreturn this />
		
	</cffunction>
	
	
	<!--- ==================================== PUBLIC MEHTODS ==================================== --->	

	<!--- Post message to twitter --->
	<cffunction name="postToTwitter" access="public" output="false" returntype="Any" hint="Post message to twitter">
		<cfargument name="status" required="true" />
		<cfargument name="username" default="#instance.username#" />
		<cfargument name="password" default="#instance.password#" />
		<cfset var cfhttp = "" />

		<!--- Check that the user is authorised --->
		<cfset verifyCredentials(arguments.username, arguments.password) />
		
		<!--- Post to twitterl --->
		<cfhttp url="http://twitter.com/statuses/update.xml" method="post" username="#arguments.username#" password="#arguments.password#" useragent="twitterCFC">
			<cfhttpparam name="status" value="#arguments.status#" type="formfield" />
		</cfhttp>
		
		<!--- If the status is not OK(200) then abort and return the status header --->
		<cfif cfhttp.StatusCode NEQ "200 ok">
			<cfabort showerror="#cfhttp.StatusCode#">
		</cfif>		
		
		<!--- Return the XML only --->
		<cfreturn cfhttp.FileContent />
		
	</cffunction>
	

	<!--- Get friends timeline --->
	<cffunction name="getFriendsTimeLine" access="public" output="false" returntype="Any" hint="Get Friends timeline">
		<cfargument name="username" default="#instance.username#" />
		<cfargument name="password" default="#instance.password#" />	
		<cfset var cfhttp = "" />
		
		<!--- Get the time line xml --->
		<cfhttp url="http://twitter.com/statuses/friends_timeline.xml"
		 method="get"
		 username="#arguments.username#"
		 password="#arguments.password#"
		 useragent="twitterCFC" />		
		
		<!--- If the status is not OK(200) then abort and return the status header --->
		<cfif cfhttp.StatusCode NEQ "200 ok">
			<cfabort showerror="Error in getFriendsTimeLine() :#cfhttp.StatusCode#">
		</cfif>		
		
		<!--- Return the XML only --->
		<cfreturn cfhttp.FileContent />
		
	</cffunction>


	<!--- Get public timeline --->
	<cffunction name="getPublicTimeline" access="public" output="false" returntype="Any" hint="Get public timeline">
		<cfset var cfhttp = "" />
		
		<!--- Get the time line --->
		<cfhttp url="http://twitter.com/statuses/public_timeline.rss"
		 method="get" />		
		<!--- If the status is not OK(200) then abort and return the status header --->
		<cfif cfhttp.StatusCode NEQ "200 ok">
			<cfabort showerror="Error in getPublicTimeline() : #cfhttp.StatusCode#">
		</cfif>		
		
		<cfreturn cfhttp.FileContent />
		
	</cffunction>
	
	
	<!--- ==================================== PRIVATE MEHTODS ==================================== --->	
	
	<!--- Verify twitter account --->
	<cffunction name="verifyCredentials" access="private" output="false" returntype="boolean">
		<cfargument name="username" required="true"/>
		<cfargument name="password" required="true"/>
		<cfset var cfhttp = "" />
		
		<!--- Post to twitterl --->
		<cfhttp url="http://twitter.com/account/verify_credentials.xml" method="get" username="#arguments.username#" password="#arguments.password#" useragent="twitterCFC" />	

		<!--- If the status is not OK(200) then the user is not authorised --->
		<cfif cfhttp.StatusCode NEQ "200 ok">
			<cfreturn false />
		<cfelse>
			<cfreturn true />
		</cfif>				
	
	</cffunction>

</cfcomponent>