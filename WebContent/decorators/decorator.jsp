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
				architecture.community.web.util.ServletUtils,
				architecture.community.menu.*" %>
<%
	Page __page = (Page)request.getAttribute("__page");
	User __user = SecurityHelper.getUser();
	
	MenuItemTreeWalker operatorMenuTree = CommunityContextHelper.getMenuService().getTreeWalker("OPERATOR_SIDE_MENU"); //운영자 메뉴목록
	MenuItemTreeWalker userMenuTree = CommunityContextHelper.getMenuService().getTreeWalker("USER_SIDE_MENU"); //학습자 메뉴목록
	MenuItemTreeWalker professorMenuTree = CommunityContextHelper.getMenuService().getTreeWalker("PROFESSOR_SIDE_MENU"); //교수 메뉴목록
	
	List<MenuItem> userMenuItems = userMenuTree.getChildren();
	List<MenuItem> professorMenuItems = professorMenuTree.getChildren();
	List<MenuItem> operatorMenuItems = operatorMenuTree.getChildren();
	
	if(SecurityHelper.isUserInRole("ROLE_OPERATOR")) {
		request.setAttribute("adminYN", "m_admin");
		request.setAttribute("menuTree", operatorMenuTree);
		request.setAttribute("menuItems", operatorMenuItems);
	} else if(SecurityHelper.isUserInRole("ROLE_PROFESSOR")) {
		request.setAttribute("adminYN", "");
		request.setAttribute("menuTree", professorMenuTree);
		request.setAttribute("menuItems", professorMenuItems);
	} else if(SecurityHelper.isUserInRole("ROLE_USER")) {
		request.setAttribute("adminYN", "");
		request.setAttribute("menuTree", userMenuTree);
		request.setAttribute("menuItems", userMenuItems);
	}
	
	DataSourceRequest dataSourceRequest = new DataSourceRequest();
	dataSourceRequest.setStatement("COMMUNITY_UI.COUNT_SERVICE_BY_REQUEST");
	Integer score = CommunityContextHelper.getCustomQueryService().queryForObject(dataSourceRequest, Integer.class);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<meta name="viewport" content="width=device-width, user-scalable=no">
	<title><%= __page.getTitle()  %></title>
	<!-- CSS, SCRIPT LOADER  -->
	<link href="<spring:url value='/css/layout.css'/>" rel="stylesheet" type="text/css" />
	<script type="text/javascript" src="<spring:url value="/js/yepnope/1.5.4/yepnope.min.js"/>"></script>
	<script data-pace-options='{ "ajax": false }' src='<spring:url value='/js/pace/pace.min.js' />' ></script>
	<script type="text/javascript"> 
	yepnope([{
		load: [
			"css!<spring:url value='/css/kendo/2018.3.1017/kendo.common-material.min.css'/>",
			"css!<spring:url value='/css/kendo/2018.3.1017/kendo.material.min.css'/>",
			"css!<spring:url value='/css/kendo/2018.3.1017/kendo.material.mobile.min.css'/>",
			"css!<spring:url value='/fonts/font-awesome.min.css'/>",
			"css!<spring:url value='/css/layout.css'/>",
			"<spring:url value='/js/jquery/jquery-3.1.1.min.js'/>",
			"<spring:url value='/js/common/TweenMax.min.js'/>",
			"<spring:url value='/js/community.ui/community.ui.decorator.js'/>",
			"<spring:url value='/js/kendo/2018.3.1017/kendo.all.min.js'/>",
			"<spring:url value='/js/kendo.extension/kendo.ko_KR.js'/>",
			"<spring:url value='/js/kendo.extension/kendo.messages.ko-KR.js'/>",
			"<spring:url value='/js/kendo/2018.3.1017/cultures/kendo.culture.ko-KR.min.js'/>",
			"<spring:url value='/js/community.ui/community.ui.core.js'/>",
			"<spring:url value='/js/community.ui/community.data.js'/>",
			"<spring:url value='/js/common/common.js'/>"
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
	<!-- wrap -->
	<div id="wrap">
		<header id="js-header">
			<div class="headerWrap">
				<h1>
					<a href="<%= ServletUtils.getContextPath(request) %>"><img src="<%= ServletUtils.getContextPath(request) %>/images/common/top_logo.png" alt="이화여자대학교" id="logo_img" />
					<span class="blind">이화여대</span></a>
				</h1>
				<div class="head_inner">
					<div class="my_info">
						<div class="photo_wrap"><div class="profile_bg"></div><img data-bind="attr:{ src: userAvatarSrc }" src="<spring:url value='/images/no-avatar.png'/>" alt="이화여자대학교" id="profile_img" />
							<span class="profile_id"><%= __user.getName() %> (<%= __user.getUsername() %>)</span>
						</div>
						<strong><span class="score_num"></span><em>78</em>점</strong>
					</div>
					<div class="home">
						<a class="tooltip tooltip-effect-1" href="<%= ServletUtils.getContextPath(request) %>">
							<span class="tooltip-content">
								<span class="tooltip_txt">HOME</span>
								<span class="tooltip-front"></span>
								<span class="tooltip-back"></span>
							</span>
						</a>
					</div>
					<div class="login_state ic_logout">
						<a class="tooltip tooltip-effect-1" href="<%= ServletUtils.getContextPath(request) %>/accounts/logout">
							<span class="tooltip-content">
								<span class="tooltip_txt">로그아웃</span>
								<span class="tooltip-front"></span>
								<span class="tooltip-back"></span>
							</span>
						</a>
					</div>
					<!--<div class="login_state ic_login">
						<a class="tooltip tooltip-effect-1" href="#"><i class="fa fa-fw fa-camera-retro"></i>
							<span class="tooltip-content">
								<span class="tooltip_txt">로그인</span>
								<span class="tooltip-front"></span>
								<span class="tooltip-back"></span>
							</span>
						</a>
					</div> 로그인할때	-->
					<div class="sitemap">
						<a class="tooltip tooltip-effect-1" href="#">
							<span class="tooltip-content">
								<span class="tooltip_txt">SITEMAP</span>
								<span class="tooltip-front"></span>
								<span class="tooltip-back"></span>
							</span>
						</a>
					</div>
				</div>
			</div>
		</header>
		
		<!-- 메뉴네비게이션 -->
		<div id="leftGnb">
			<ul class="accordion-menu">
			<% if( __user.isAnonymous() ) { %>
			
			<% } else { %>
				<c:if test="${!empty menuItems}">
					<c:forEach items="${menuItems}" var="menuItem" varStatus="status">
					<li>
						<div class="dropdownlink m0${status.index + 1} ${adminYN}">
							<span>${menuItem.name}</span>${menuItem.name}
							<i class="fa fa-chevron-down" aria-hidden="true"></i>
						</div>
						<c:if test="${menuTree.getChildCount(menuItem) > 0}">
						<ul class="submenuItems">
							<c:forEach items="${menuTree.getChildren(menuItem)}" var="childMenuItem" varStatus="status">
							<li><a href="<%= ServletUtils.getContextPath(request) %>${childMenuItem.page}" data-page="${childMenuItem.page}">${childMenuItem.name}</a></li>
							</c:forEach>
						</ul>
						</c:if>
					</li>
					</c:forEach>
				</c:if>
			<% } %>
			</ul>
		</div>
		<!--//메뉴네비게이션-->
		
		<!-- 본문 -->
		<sitemesh:write property='body' />
		<!-- //본문 -->
		
		<footer>
		</footer>
		
	</div><!--//wrap-->
</body>
</html>