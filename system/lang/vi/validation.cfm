<!---
	Project:	cfTrigger
	Summary:	Language settings for site. Language: Vietnamese
	Log:
	
--->
 
<!--- Validation languages --->
<cfset application.defaultValidationLang = StructNew()>
<cfset application.defaultValidationLang.required = "Bạn phải điền vào [field]">
<cfset application.defaultValidationLang.unique = "Một [modelName] với [field] '[value]' đã có rồi">
<cfset application.defaultValidationLang.email = "[field] không hợp lệ">
<cfset application.defaultValidationLang.minLen = "[field] quá ngắn, chiều dài tối thiểu là [args] ký tự">
<cfset application.defaultValidationLang.maxLen = "[field] quá dài, chiều dài tối đa là [args] ký tự">
<cfset application.defaultValidationLang.numeric = "[field] phải là 1 số">
<cfset application.defaultValidationLang.minVal = "[field] quá nhỏ, giá trị tối thiểu là [args]">
<cfset application.defaultValidationLang.maxVal = "[field] quá lớn, giá trị tối đa là [args]">
<cfset application.defaultValidationLang.username = "[field] không hợp lệ. Nó chỉ có thể bao gồm chữ, số hoặc là dấu gạch dưới">
<cfset application.defaultValidationLang.letters = "[field] không hợp lệ. Nó chỉ có thể bao gồm chữ">
<cfset application.defaultValidationLang.digits = "[field] không hợp lệ. Nó chỉ có thể bao gồm số">
<cfset application.defaultValidationLang.url = "[field] không phải là 1 url hợp lệ">
<cfset application.defaultValidationLang.limitChars = "[field] không hợp lệ. Nó chỉ có thể bao gồm: [args]">
<cfset application.defaultValidationLang.localDirectory = "[field] không hợp lệ. Nó phải là 1 đường dẫn thư mục có thật.">
<cfset application.defaultValidationLang.phoneNumber = "[field] không hợp lệ. Nếu bạn dùng số điện thoại nhà, xin đánh luôn số khu vực">
<cfset application.defaultValidationLang.validURLChars = "[field] không hợp lệ. Nó chỉ có thể bao gồm: chữ, số, dấu gạch dưới hoặc là dấu gạch ngang">