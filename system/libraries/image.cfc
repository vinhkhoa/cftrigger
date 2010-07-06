<!---
	Project:		cfTrigger
	Company:		cfTrigger
	Summary:		System image class
	
	Log:
	
	Created:		21/11/2009
	
	Modified:
	- 

--->

<cfcomponent displayname="Image">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Resize an image to fit a size --->
	<cffunction name="resize" displayname="resize" returntype="struct" hint="Resize an image to fit a size">
		<cfargument name="fileLocation" type="string" required="yes" hint="The image location">
		<cfargument name="fileName" type="string" required="yes" hint="The image file name. Can be different from the one specified in the file location depending on the context">
		<cfargument name="resizeWidth" type="numeric" required="no" hint="The width to resize">
		<cfargument name="resizeHeight" type="numeric" required="no" hint="The height to resize">
		<cfargument name="forceScaling" type="boolean" required="no" default="false" hint="true: always attempt to scale and throw error when attempting to scale up an image. flase: when the image size is unchanged or smaller than then scale size, just ignore and return no error">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		
		<!--- Is there a size passed in? --->
		<cfif NOT StructKeyExists(arguments, "resizeWidth") AND NOT StructKeyExists(arguments, "resizeHeight")>
			<cfset result.error = "Either width or height is required to resize the image">
			<cfreturn result>
		</cfif>
		
		<!--- Is this actually an image? --->
		<cfif NOT isImageFile(arguments.fileLocation) OR NOT isImage(ImageNew(arguments.fileLocation))>
			<cfset result.error = "The file '#arguments.fileName#' is a not valid image.">
			<cfreturn result>
		</cfif>
			
		<!--- Get original image size --->
		<cfimage action="read" source="#arguments.fileLocation#" name="imgInfo">
		<cfset imgRatio = imgInfo.width / imgInfo.height>
			
		<!--- Get the height from width or vice versa --->
		<cfif NOT StructKeyExists(arguments, "resizeHeight") OR NOT val(arguments.resizeHeight)>
			<cfset w = val(arguments.resizeWidth)>
			<cfset h = w / imgRatio>
		<cfelseif NOT StructKeyExists(arguments, "resizeWidth") OR NOT val(arguments.resizeWidth)>
			<cfset h = val(arguments.resizeHeight)>
			<cfset w = h * imgRatio>
		<cfelse>
			<cfset w = val(arguments.resizeWidth)>
			<cfset h = val(arguments.resizeHeight)>
		</cfif>
			
		<cfset resizeRatio = w / h>
	
		<!--- Which ratio is bigger? --->
		<cfif resizeRatio gt imgRatio>
			<!--- Will fit as long as height fits => get w from h --->
			<cfset w = h * imgRatio>
		<cfelseif resizeRatio lt imgRatio>
			<!--- will fit as long as width fits => get h from w --->
			<cfset h = w / imgRatio>
		</cfif>
		
		<!--- Resize to 0? --->
		<cfif w le 0 OR h le 0>
			<cfset result.error = "Cannot resize an image to 0 size">
			<cfreturn result>
		
		<!--- Scale up? --->
		<cfelseif w gt imgInfo.width OR h gt imgInfo.height>
			<!--- Force scaling? Return error --->
			<cfif arguments.forceScaling>
				<cfset result.error = "Cannot scale up the image">
			</cfif>
			<cfreturn result>
		
		<!--- Image size unchanged? --->
		<cfelseif w eq imgInfo.width OR h eq imgInfo.height>
			<!--- Force scaling? Return error --->
			<cfif arguments.forceScaling>
				<cfset result.error = "The size is unchanged. Nothing to resize">
			</cfif>
			<cfreturn result>
		</cfif>
		
		<cfimage action="resize" height="#h#" width="#w#" source="#arguments.fileLocation#" destination="#arguments.fileLocation#" overwrite="yes">
			
			<!--- Create thumb? --->
			<!---<cfif StructKeyExists(arguments, "thumbWidth") OR StructKeyExists(arguments, "thumbHeight")>
				<!--- Get the height from width or vice versa --->
				<cfif NOT StructKeyExists(arguments, "thumbHeight") OR NOT val(arguments.thumbHeight)>
					<cfset tw = val(arguments.thumbWidth)>
					<cfset th = tw / imgRatio>
				<cfelseif NOT StructKeyExists(arguments, "thumbWidth") OR NOT val(arguments.thumbWidth)>
					<cfset th = val(arguments.thumbHeight)>
					<cfset tw = th * imgRatio>
				<cfelse>
					<cfset tw = val(arguments.thumbWidth)>
					<cfset th = val(arguments.thumbHeight)>
				</cfif>
				
				<cfset resizeRatio = tw / th>
			
				<!--- Which ratio is bigger? --->
				<cfif resizeRatio gt imgRatio>
					<!--- Will fit as long as height fits => get w from h --->
					<cfset tw = th * imgRatio>
				<cfelseif resizeRatio lt imgRatio>
					<!--- will fit as long as width fits => get h from w --->
					<cfset th = tw / imgRatio>
				</cfif>
				
				<!--- Only scale down the image thumb --->
				<cfset createThumb = (tw gt 0) AND (th gt 0) AND (tw lt imgInfo.width OR th lt imgInfo.height)>
				<cfset arguments.thumbLocation = reReplace(arguments.fileLocation, '.([a-zA-Z]+)$', '_thumb.\1')>
			</cfif>--->
		
		
		<cfreturn result>
			
	</cffunction>


	<!--- Upload and resize image --->
	<cffunction name="uploadAndResize" displayname="uploadAndResize" access="public" returntype="struct" hint="Upload and resize image">
		<cfargument name="formField" type="string" required="yes" hint="The name of the form field that contains the image">
		<cfargument name="destinationFolder" type="string" required="yes" hint="The path to the folder where the images are uploaded to">
		<cfargument name="resizeWidth" type="numeric" required="no" hint="The width to resize">
		<cfargument name="resizeHeight" type="numeric" required="no" hint="The height to resize">
		<cfargument name="fileName" type="string" required="no" hint="Rename the file to this specific file name">
		<cfargument name="keepClientFileName" type="string" required="no" default="false" hint="true: keep the client file name">
		<cfargument name="overwrite" type="string" required="no" default="true" hint="true: overwrite existing file">
		<cfset var result = StructNew()>
		<cfset result.error = "">
		<cfset result.clientFile = "">
		<cfset result.uploadedFolder = "">
		<cfset result.uploadedFile = "">
		<cfset result.uploadedLocation = "">
		<cfset result.clientFileExists = true>
		
		<!--- Upload the file --->
		<cfset destinationFolder = application.FilePath & arguments.destinationFolder & application.separator>
		<cfset destinationFolder = reReplace(destinationFolder, "\#application.oppSeparator#", application.separator, "ALL")>
		<cfset destinationFolder = reReplace(destinationFolder, "\#application.separator#{2,}", application.separator, "ALL")>
		
		<cftry>
			<!--- Overwrite? --->
			<cfif arguments.overwrite>
				<cfset nameconflict = "overwrite">
			<cfelse>
				<cfset nameconflict = "error">
			</cfif>
		
			<cfset application.directory.create(destinationFolder)>
			<cffile action="upload" fileField="#arguments.formField#" destination="#destinationFolder#" accept="image/jpg,image/gif,image/png,image/jpeg" nameconflict="#nameconflict#" result="uploadResult">
			<cfset result.uploadedFolder = uploadResult.serverDirectory & application.separator>
			<cfset result.uploadedLocation = result.uploadedFolder & uploadResult.serverFile>
			<cfset result.clientFile = uploadResult.clientFile>
			
			<!--- Keep the client file name? OR Rename the file to a specified name?--->
			<cfif arguments.keepClientFileName>
				<cfset result.uploadedFile = result.clientFile>
				
			<cfelseif StructKeyExists(arguments, "fileName") AND trim(arguments.fileName) neq "">
				<!--- Does this file name have an extension? --->
				<cfif listLen(arguments.fileName, ".") ge 2>
					<cfset newFileName = arguments.fileName>
				<cfelse>
					<cfset newFileName = arguments.fileName & "." & listLast(result.clientFile, ".")>
				</cfif>
				<cfset newFileLocation = getDirectoryFromPath(result.uploadedLocation) & newFileName>
				
				<!--- Not overwrite file? Check if the file is there yet --->
				<cfif NOT arguments.overwrite AND fileExists(newFileLocation)>
					<cfthrow message="duplicated">
				</cfif>
				
				<!--- Rename the file --->
				<cffile action="rename" source="#result.uploadedLocation#" destination="#newFileLocation#" attributes="normal">
			
				<cfset result.uploadedFile = newFileName>
				<cfset result.uploadedLocation = newFileLocation>
				
			<!--- Rename this file to a random name --->
			<cfelse>
				<cfset renameResult = application.file.renameToRandom(result.uploadedLocation)>
				<cfset result.uploadedFile = renameResult.newFileName>
				<cfset result.uploadedLocation = renameResult.newFileLocation>
			</cfif>
			
			<cfcatch type="application">
				<!--- File extension not accepted? --->
				<cfif reFindNoCase("The MIME type of the uploaded file [^ ]+ was not accepted by the server", cfcatch.Message)>
					<cfset result.error = "Please upload only jpg, jpeg, gif or png file">
				<cfelseif reFindNoCase("doesn't exist or has no content", cfcatch.message)>
					<cfset result.clientFileExists = false>
					<cfset result.error = "Please select an image to upload">
				<cfelseif reFindNoCase("File overwriting is not permitted in this instance of the cffile tag", cfcatch.message) OR
							reFindNoCase("duplicated", cfcatch.message)>
					<cfset result.error = "The file already exists">
				<cfelse>
					<cfset result.error = cfcatch.message>
				</cfif>
				
				<!--- Delete uploaded file --->
				<cfset application.file.delete(result.uploadedFolder & result.clientFile)>
			</cfcatch>
		</cftry>
		
		<!--- Resize the image --->
		<cfif result.error eq "">
			<cfinvoke component="#application.image#" method="resize" returnvariable="resizeResult">
				<cfinvokeargument name="fileLocation" value="#result.uploadedLocation#">
				<cfinvokeargument name="fileName" value="#result.clientFile#">
				<cfinvokeargument name="resizeWidth" value="#arguments.resizeWidth#">
				<cfinvokeargument name="resizeHeight" value="#arguments.resizeHeight#">
			</cfinvoke>
			
			<cfset result.error = resizeResult.error>
		</cfif>
			
		<!--- Any error happens? Delete the uploaded file  --->
		<cfif result.error neq "">
			<cfset application.file.delete(result.uploadedLocation)>
			<cfset result.uploadedLocation = "">
		</cfif>
		
		<cfreturn result>
		
	</cffunction>


	<!--- Generate qr code image --->
	<cffunction name="generateQRCode" displayname="generateQRCode" access="public" returntype="struct" hint="Generate qr code image">
		<cfargument name="destinationFolder" type="string" required="yes" hint="The path to the folder where the images are saved to">
		<cfargument name="fileName" type="string" required="yes" hint="The file name of the qr code image">
		<cfargument name="imageSize" type="numeric" required="yes" hint="The width and height of the image">
		<cfargument name="content" type="string" required="yes" hint="The content to be generated in this qr code">
		<cfset var result = StructNew()>
		<cfset result.error = "">

		<!--- Get the qr code image folder and file name --->
		<cfset destinationFolder = application.FilePath & arguments.destinationFolder & application.separator>
		<cfset destinationFolder = reReplace(destinationFolder, "\#application.separator#{2,}", application.separator, "ALL")>
		
		<!--- Create the folder --->
		<cfset createDirResult = application.directory.create(destinationFolder)>
		
		<!--- Generate and save qr code image --->
		<cfimage action="write" source="http://chart.apis.google.com/chart?cht=qr&chs=#arguments.imageSize#x#arguments.imageSize#&chl=#URLEncodedFormat(arguments.content)#" destination="#destinationFolder##arguments.fileName#" overwrite="yes">
		
		<cfreturn result>
				
	</cffunction>
	
</cfcomponent>