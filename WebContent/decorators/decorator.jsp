<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="f" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="java.util.*,
				architecture.community.page.Page, 
				architecture.community.user.*, 
				architecture.community.util.SecurityHelper, 
				architecture.community.util.CommunityContextHelper, 
				architecture.community.web.model.json.*,
				architecture.community.web.util.ServletUtils" %>
<%
	Page __page = (Page)request.getAttribute("__page");
	User __user = SecurityHelper.getUser();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<meta name="viewport" content="width=device-width, user-scalable=no">
	<title><%= __page.getTitle()  %></title>
	<!-- CSS, SCRIPT LOADER  --> 
	<script type="text/javascript" src="<spring:url value="/js/yepnope/1.5.4/yepnope.min.js"/>"></script>
	<script data-pace-options='{ "ajax": false }' src='<spring:url value='/js/pace/pace.min.js' />' ></script>
	<script type="text/javascript"> 
	yepnope([{
		load: [
			"css!<spring:url value='/css/kendo/2018.3.1017/kendo.common-material.min.css'/>",
			"css!<spring:url value='/css/kendo/2018.3.1017/kendo.material.min.css'/>",
			"css!<spring:url value='/css/kendo/2018.3.1017/kendo.material.mobile.min.css'/>",
			"css!<spring:url value='/fonts/font-awesome.min.css'/>",
			"<spring:url value='/js/jquery/jquery-3.1.1.min.js'/>",
			"<spring:url value='/js/kendo/2018.3.1017/kendo.all.min.js'/>",
			"<spring:url value='/js/kendo.extension/kendo.ko_KR.js'/>",
			"<spring:url value='/js/kendo/2018.3.1017/cultures/kendo.culture.ko-KR.min.js'/>",
			"<spring:url value='/js/community.ui/community.ui.core.js'/>",
			"<spring:url value='/js/community.ui/community.data.js'/>"
		],
		complete: function() {
			kendo.culture("ko-KR");
			
			if( community.ui.defined( setup ))
				setup();
			
		}
	}]);
	</script>
	<style> 
	.pace {
	  -webkit-pointer-events: none;
	  pointer-events: none;
	  -webkit-user-select: none;
	  -moz-user-select: none;
	  user-select: none;
	}
	
	.pace-inactive {
	  display: none;
	}
	
	.pace .pace-progress {
	  background: #dd2766;
	  position: fixed;
	  z-index: 2000;
	  top: 0;
	  right: 100%;
	  width: 100%;
	  height: 2px;
	} 
	
	</style>
	<!-- 페이지별 스크립트 -->
	<sitemesh:write property='head' />
</head>
<body onload="<sitemesh:write property='body.onload' />">
	<!-- 본문 -->
	<sitemesh:write property='body' />
	<!-- //본문 -->
</body>
</html>