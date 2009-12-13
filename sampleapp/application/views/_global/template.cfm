<!---
	Project:	cfTrigger sample app
	Summary:	Site template
	Log:
	
--->

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><cfif heading neq "">#heading# - </cfif>cfTrigger Sample App</title>
	<link rel="stylesheet" href="#application.rootURL#/css/core.css" type="text/css" media="screen" charset="utf-8"/>
</head>

<body>
<div id="content">
	#content#
</div>

<script type="text/javascript" src="#application.rootURL#/js/core.js"></script>
</body>
</html>
</cfoutput>