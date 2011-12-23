<!---
	Project:		cfTrigger
	Summary:		System image class
	
	Log:
	
	Created:		21/11/2009
	
	Modified:
	- 

--->

<cfcomponent displayname="Image" output="false">

	<cfsetting enablecfoutputonly="yes">
	
	
	<!--- Resize an image to fit a size --->
	<cffunction name="resize" displayname="resize" returntype="struct" hint="Resize an image to fit a size" output="false">
		<cfargument name="fileLocation" type="string" required="yes" hint="The image location">
		<cfargument name="resizeWidth" type="numeric" required="no" hint="The width to resize">
		<cfargument name="resizeHeight" type="numeric" required="no" hint="The height to resize">
		<cfargument name="forceScaling" type="boolean" required="no" default="false" hint="true: always attempt to scale and throw error when attempting to scale up an image. flase: when the image size is unchanged or smaller than then scale size, just ignore and return no error">
		<cfset var result = StructNew()>
		<cfset var image = "">
		<cfset var imgRatio = "">
		<cfset var resizeRatio = "">
		<cfset var resizeWidth = "">
		<cfset var resizeHeight = "">
		<cfset result.error = "">
		
		<!--- Is there a size passed in? --->
		<cfif NOT StructKeyExists(arguments, "resizeWidth") AND NOT StructKeyExists(arguments, "resizeHeight")>
			<cfset result.error = "Either width or height is required to resize the image">
			<cfreturn result>
		</cfif>
		
		<!--- Is this actually an image? --->
		<cfif NOT isImageFile(arguments.fileLocation) OR NOT isImage(ImageNew(arguments.fileLocation))>
			<cfset result.error = "The file '#getFileFromPath(arguments.fileLocation)#' is a not valid image.">
			<cfreturn result>
		</cfif>
			
		<!--- Get original image size --->
		<cfimage action="read" source="#arguments.fileLocation#" name="image">
		<cfset imgRatio = image.width / image.height>
			
		<!--- Get the height from width or vice versa --->
		<cfif NOT StructKeyExists(arguments, "resizeHeight") OR NOT val(arguments.resizeHeight)>
			<cfset resizeWidth = val(arguments.resizeWidth)>
			<cfset resizeHeight = resizeWidth / imgRatio>
		<cfelseif NOT StructKeyExists(arguments, "resizeWidth") OR NOT val(arguments.resizeWidth)>
			<cfset resizeHeight = val(arguments.resizeHeight)>
			<cfset resizeWidth = resizeHeight * imgRatio>
		<cfelse>
			<cfset resizeWidth = val(arguments.resizeWidth)>
			<cfset resizeHeight = val(arguments.resizeHeight)>
		</cfif>
			
		<cfset resizeRatio = resizeWidth / resizeHeight>
	
		<!--- Which ratio is bigger? --->
		<cfif resizeRatio gt imgRatio>
			<!--- Will fit as long as height fits => get resizeWidth from resizeHeight --->
			<cfset resizeWidth = resizeHeight * imgRatio>
		<cfelseif resizeRatio lt imgRatio>
			<!--- will fit as long as width fits => get resizeHeight from resizeWidth --->
			<cfset resizeHeight = resizeWidth / imgRatio>
		</cfif>
		
		<!--- Resize to 0? --->
		<cfif resizeWidth le 0 OR resizeHeight le 0>
			<cfset result.error = "Cannot resize an image to 0 size">
			<cfreturn result>
		
		<!--- Scale up? --->
		<cfelseif resizeWidth gt image.width OR resizeHeight gt image.height>
			<!--- Force scaling? Return error --->
			<cfif arguments.forceScaling>
				<cfset result.error = "Cannot scale up the image">
			</cfif>
			<cfreturn result>
		
		<!--- Image size unchanged? --->
		<cfelseif resizeWidth eq image.width OR resizeHeight eq image.height>
			<!--- Force scaling? Return error --->
			<cfif arguments.forceScaling>
				<cfset result.error = "The size is unchanged. Nothing to resize">
			</cfif>
			<cfreturn result>
		</cfif>
		
		<cfimage action="resize" height="#resizeHeight#" width="#resizeWidth#" source="#arguments.fileLocation#" destination="#arguments.fileLocation#" overwrite="yes">
		
		<cfreturn result>
			
	</cffunction>


	<!--- Upload and resize image --->
	<cffunction name="uploadAndResize" displayname="uploadAndResize" access="public" returntype="struct" hint="Upload and resize image" output="false">
		<cfargument name="formField" type="string" required="yes" hint="The name of the form field that contains the image">
		<cfargument name="destinationFolder" type="string" required="yes" hint="The path to the folder where the images are uploaded to">
		<cfargument name="resizeWidth" type="numeric" required="no" hint="The width to resize">
		<cfargument name="resizeHeight" type="numeric" required="no" hint="The height to resize">
		<cfargument name="fileName" type="string" required="no" hint="Rename the file to this specific file name">
		<cfargument name="keepClientFileName" type="string" required="no" default="false" hint="true: keep the client file name">
		<cfargument name="overwrite" type="boolean" required="no" default="true" hint="true: overwrite existing file">
		<cfset var result = StructNew()>
		<cfset var destFolder = "">
		<cfset var nameconflict = "">
		<cfset var newFileName = "">
		<cfset var newFileLocation = "">
		<cfset var renameResult = "">
		<cfset var resizeResult = "">
		<cfset result.error = "">
		<cfset result.clientFile = "">
		<cfset result.uploadedFolder = "">
		<cfset result.uploadedFile = "">
		<cfset result.uploadedLocation = "">
		<cfset result.clientFileExists = true>
		<cfset result.fileExisted = false>
		
		<!--- Set the destination folder --->
		<cfif directoryExists(arguments.destinationFolder)>
			<cfset destFolder = arguments.destinationFolder>
		<cfelse>
			<cfset destFolder = application.FilePath & arguments.destinationFolder & application.separator>
			<cfset destFolder = reReplace(destFolder, "\#application.oppSeparator#", application.separator, "ALL")>
			<cfset destFolder = reReplace(destFolder, "\#application.separator#{2,}", application.separator, "ALL")>
		</cfif>
		
		<cftry>
			<!--- Overwrite? --->
			<cfif arguments.overwrite>
				<cfset nameconflict = "overwrite">
			<cfelse>
				<cfset nameconflict = "error">
			</cfif>
		
			<cfset application.directory.create(destFolder)>
			<cffile action="upload" fileField="#arguments.formField#" destination="#destFolder#" accept="image/jpg,image/gif,image/png,image/jpeg" nameconflict="#nameconflict#" result="uploadResult">
			
			<cfset result.fileExisted = uploadResult.fileExisted>
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
	<cffunction name="generateQRCode" displayname="generateQRCode" access="public" returntype="struct" hint="Generate qr code image" output="false">
		<cfargument name="destinationFolder" type="string" required="yes" hint="The path to the folder where the images are saved to">
		<cfargument name="fileName" type="string" required="yes" hint="The file name of the qr code image">
		<cfargument name="imageSize" type="numeric" required="yes" hint="The width and height of the image">
		<cfargument name="content" type="string" required="yes" hint="The content to be generated in this qr code">
		<cfset var result = StructNew()>
		<cfset var destFolder = "">
		<cfset var createDirResult = "">
		<cfset result.error = "">

		<!--- Get the qr code image folder and file name --->
		<cfset destFolder = application.FilePath & arguments.destinationFolder & application.separator>
		<cfset destFolder = reReplace(destFolder, "\#application.separator#{2,}", application.separator, "ALL")>
		
		<!--- Create the folder --->
		<cfset createDirResult = application.directory.create(destFolder)>
		
		<!--- Generate and save qr code image --->
		<cfimage action="write" source="http://chart.apis.google.com/chart?cht=qr&chs=#arguments.imageSize#x#arguments.imageSize#&chl=#URLEncodedFormat(arguments.content)#" destination="#destFolder##arguments.fileName#" overwrite="yes">
		
		<cfreturn result>
				
	</cffunction>
	
	
	<!--- Create a thumbnail for the image --->
	<cffunction name="cropAndResize" displayname="cropAndResize" returntype="struct" hint="Crop and Resize an image to fit a size" output="false">
	
		<cfargument name="fileLocation" type="string" required="yes" hint="The image location">
		<cfargument name="newFileLocation" type="string" required="no" hint="The new (resized) image location. Do not pass this in to save it into the same location">
		<cfargument name="resizeWidth" type="numeric" required="no" hint="The width to resize">
		<cfargument name="resizeHeight" type="numeric" required="no" hint="The height to resize">
		<cfargument name="forceScaling" type="boolean" required="no" default="false" hint="true: always attempt to scale and throw error when attempting to scale up an image. flase: when the image size is unchanged or smaller than then scale size, just ignore and return no error">
		<cfset var result = StructNew()>
		<cfset var image = "">
		<cfset var imgRatio = "">
		<cfset var resizeRatio = "">
		<cfset var resizeWidth = "">
		<cfset var resizeHeight = "">
		<cfset var cropWidth = "">
		<cfset var cropHeight = "">
		<cfset result.error = "">
		
		<!--- Is there a size passed in? --->
		<cfif NOT StructKeyExists(arguments, "resizeWidth") AND NOT StructKeyExists(arguments, "resizeHeight")>
			<cfset result.error = "Either width or height is required to resize the image">
			<cfreturn result>
		</cfif>
		
		<!--- Is this actually an image? --->
		<cfif NOT isImageFile(arguments.fileLocation) OR NOT isImage(ImageNew(arguments.fileLocation))>
			<cfset result.error = "The file '#getFileFromPath(arguments.fileLocation)#' is a not valid image.">
			<cfreturn result>
		</cfif>
			
		<!--- Get original image size --->
		<cfimage action="read" source="#arguments.fileLocation#" name="image">
		<cfset imgRatio = image.width / image.height>
		
		<!--- Get the height from width or vice versa --->
		<cfif NOT StructKeyExists(arguments, "resizeHeight") OR NOT val(arguments.resizeHeight)>
			<cfset resizeWidth = val(arguments.resizeWidth)>
			<cfset resizeHeight = resizeWidth / imgRatio>
		<cfelseif NOT StructKeyExists(arguments, "resizeWidth") OR NOT val(arguments.resizeWidth)>
			<cfset resizeHeight = val(arguments.resizeHeight)>
			<cfset resizeWidth = resizeHeight * imgRatio>
		<cfelse>
			<cfset resizeWidth = val(arguments.resizeWidth)>
			<cfset resizeHeight = val(arguments.resizeHeight)>
		</cfif>
		<cfset resizeRatio = resizeWidth / resizeHeight>
		
		
		<!--- ==================== CROP ==================== --->
		
		<!--- Anything to crop? --->
		<cfif resizeRatio neq imgRatio>
			<!--- Get the crop size --->
			<cfif resizeRatio gt imgRatio>
				<cfset cropWidth = image.width>
				<cfset cropHeight = cropWidth / resizeRatio>
			<cfelse>
				<cfset cropHeight = image.height>
				<cfset cropWidth = cropHeight * resizeRatio>
			</cfif>
		
			<!--- Crop now --->
			<cfset imageCrop(image, 1, 1, cropWidth, cropHeight)>
			<cfset imgRatio = image.width / image.height>
		</cfif>


		<!--- ==================== RESIZE ==================== --->
		
		<!--- Get the resize size --->
		<cfif resizeRatio gt imgRatio>
			<cfset resizeWidth = resizeHeight * imgRatio>
		<cfelseif resizeRatio lt imgRatio>
			<cfset resizeHeight = resizeWidth / imgRatio>
		</cfif>

		<!--- Resize to 0? --->
		<cfif resizeWidth le 0 OR resizeHeight le 0>
			<cfset result.error = "Cannot resize an image to 0 size">
			<cfreturn result>
		
		<!--- Scale up? --->
		<cfelseif resizeWidth gt image.width OR resizeHeight gt image.height>
			<!--- Force scaling? Return error --->
			<cfif arguments.forceScaling>
				<cfset result.error = "Cannot scale up the image">
			</cfif>
			<cfreturn result>
		
		<!--- Image size unchanged? --->
		<cfelseif resizeWidth eq image.width OR resizeHeight eq image.height>
			<!--- Force scaling? Return error --->
			<cfif arguments.forceScaling>
				<cfset result.error = "The size is unchanged. Nothing to resize">
			</cfif>
			<cfreturn result>
		</cfif>
		<cfset imageResize(image, resizeWidth, resizeHeight)>
		
		<!--- Save the image --->
		<cfif StructKeyExists(arguments, "newFileLocation")>
			<cfset application.directory.createForFile(arguments.newFileLocation)>
		<cfelse>
			<cfset arguments.newFileLocation = arguments.fileLocation>
		</cfif>
		<cfimage action="write" source="#image#" destination="#arguments.newFileLocation#" overwrite="yes">
		
		<cfreturn result>
			
	</cffunction>
	
</cfcomponent>