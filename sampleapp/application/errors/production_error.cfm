<!---
	Project:	cfTrigger sample app
	Summary:	General error page. Used for production environment
				as we do not want to expos too much details about the error
				to our users for security reason.
	Log:

--->

<cfheader statuscode="500" statustext="500 - Internal Server Error">
<cfoutput>
<h2>500 error - Internal Server Error occurs.</h2>
<p>Sorry, some unexpected error has happened.</p>
<p><a href="#application.rootURL#/">HOME</a></p>
</cfoutput>	
