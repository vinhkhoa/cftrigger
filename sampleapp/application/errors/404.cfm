<!---
	Project:	cfTrigger sample app
	Summary:	404 error page
	Log:

--->

<cfheader statuscode="404" statustext="404 - Page not found">
<cfoutput>
<h2>404 error - The page is not found.</h2>
<p>Sorry, the page you're looking for does not exist or has been deleted.</p>
<p><a href="#application.rootURL#/">HOME</a></p>
</cfoutput>	
