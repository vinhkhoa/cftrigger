<!---
	Project:	cfTrigger sample app
	Summary:	General error page. Used for development environment
				as it displays error details for debugging purpose.
				There's no need for error code here, it just looks like a normal page anyway.
	Log:

--->

<cfoutput>
<h1>#heading#</h1>
<p>#message#</p>
<p><a href="#application.rootURL#/">HOME</a></p>
</cfoutput>