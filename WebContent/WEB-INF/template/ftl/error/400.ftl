<#ftl encoding="UTF-8"/>
<!DOCTYPE html>
<html>
<head>
    <title>401</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="Expires" content="-1">
</head>
<body>
	<div class="container">
	<#if SPRING_SECURITY_LAST_EXCEPTION ?? >
	
	<div class="alert alert-danger" role="alert">
	  <strong>Oh Nooooo!</strong> ${ SPRING_SECURITY_LAST_EXCEPTION  }
	</div>
	</#if> 
	</div>
	
</body>
</html>