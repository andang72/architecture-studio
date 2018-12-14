<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="architecture.community.page.Page, 
				architecture.community.user.User, 
				architecture.community.util.SecurityHelper" %>
<%
	
	Page __page = (Page)request.getAttribute("__page");
	User __user = SecurityHelper.getUser();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<script>
/**
 *Application initialize.
 */ 
</script>
</head>
<body>
	<div id="container">
		<div class="contents"> 
			
			<% if( __user.isAnonymous() ) { %>
			<a href="<spring:url value="/accounts/login" htmlEscape="true"/>" >로그인</a>
			<% } %>
			
		</div><!--//content-->
	</div><!--//container-->
</body>
</html>