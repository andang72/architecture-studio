<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html>
<head>	
	<meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    
	<title>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "REPLICANT") } | ADMIN v2.0</title>
	
    <!-- Kendo UI with bootstrap theme CSS -->	
   	<!--
	<link href="<@spring.url "/css/kendo.ui.core/web/kendo.common-bootstrap.core.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/kendo.ui.core/web/kendo.bootstrap.min.css"/>" rel="stylesheet" type="text/css" />	
	-->
	<!-- Professional Kendo UI --> 	
	<link href="<@spring.url "/css/kendo/2018.1.221/kendo.common.min.css"/>" rel="stylesheet" type="text/css" />	
	
	<link href="<@spring.url "/css/kendo/2018.1.221/kendo.bootstrap-v4.min.css"/>" rel="stylesheet" type="text/css" />	
	
	<!-- Bootstrap CSS -->
    <link href="<@spring.url "/css/bootstrap/4.0.0/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />
    
    <!-- Bootstrap Theme CSS -->
    
    <link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/css/animate/animate.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/fonts/nanumgothic.min.css"/>" rel="stylesheet" type="text/css" />	
    
    <!-- Community Admin CSS -->
    <link href="<@spring.url "/css/community.ui.admin/community-ui-admin-icons.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/css/community.ui.admin/community.ui.admin.css"/>" rel="stylesheet" type="text/css" />	
 
   	 <!-- Summernote Editor CSS -->
	<link href="<@spring.url "/js/summernote/summernote.css"/>" rel="stylesheet" type="text/css" />
	 	      	     
 	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js'"/>></script>
 	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>
 	<!-- Application JavaScript
    		================================================== -->    	
	<script>
	var __announceId = <#if RequestParameters.menuId?? >${RequestParameters.announceId}<#else>0</#if>;
	
	require.config({
		shim : {
			"jquery.cookie" 				: { "deps" :['jquery'] },
	        "bootstrap" 					: { "deps" :['jquery'] },
	        "kendo.web.min" 				: { "deps" :['jquery'] },
	        "kendo.culture.ko-KR.min" 	: { "deps" :['jquery', 'kendo.web.min'] },
	        "kendo.extension.min" 		: { "deps" :['jquery', 'kendo.web.min'] },
	        "community.ui.core" 			: { "deps" :['jquery', "kendo.web.min", 'kendo.culture.ko-KR.min', 'kendo.extension.min'] },
	        "community.data" 			: { "deps" :['jquery', 'community.ui.core'] },	 
	        "community.ui.professional" 	: { "deps" :['jquery', 'community.ui.core'] },
	        "community.ui.admin" 		: { "deps" :['jquery', 'community.ui.core', 'community.data'] },
	        "summernote-ko-KR" : { "deps" :['summernote.min'] }
		},
		paths : {
			"jquery"    					: "/js/jquery/jquery-3.1.1.min",
			"jquery.cookie"    			: "/js/jquery.cookie/1.4.1/jquery.cookie",
			"popper" 	   				: "/js/bootstrap/4.0.0/bootstrap.bundle",
			"bootstrap" 					: "/js/bootstrap/4.0.0/bootstrap",
			/*"kendo.ui.core.min" 		: "/js/kendo.ui.core/kendo.ui.core.min",*/
			/*"kendo.culture.ko-KR.min"	: "/js/kendo.ui.core/cultures/kendo.culture.ko-KR.min",*/
			"kendo.web.min"	 			: "/js/kendo/2018.1.221/kendo.web.min",
			"kendo.culture.ko-KR.min"	: "/js/kendo/2018.1.221/cultures/kendo.culture.ko-KR.min",	
			"kendo.extension.min"		: "/js/kendo.extension/kendo.ko_KR",			
			"community.ui.core" 			: "/js/community.ui/community.ui.core",
			"community.ui.professional" 	: "/js/community.ui.components/community.ui.professional",
			"community.data" 			: "/js/community.ui/community.data",
			"community.ui.admin" 		: "/js/community.ui.components/community.ui.admin",
			"ace" 						: "/js/ace/ace",
			"summernote.min"             : "/js/summernote/summernote.min",
			"summernote-ko-KR"           : "/js/summernote/lang/summernote-ko-KR",
			"dropzone"					: "/js/dropzone/dropzone"			
		}
	});
	require([ "jquery", "jquery.cookie", "popper", "kendo.web.min", "community.ui.core", "community.data", "community.ui.professional", "community.ui.admin", "summernote.min", "summernote-ko-KR", "dropzone" ], function($, kendo ) { 
		
		community.ui.setup({
		  	features : {
				accounts: true
		  	},
		  	'features.accounts.authenticate' :function(e){
		  		observable.setUser(e.token);
		  	}
		});
		
		var observable = new community.ui.observable({ 
			currentUser : new community.model.User(),
			userAvatarSrc : "/images/no-avatar.png",
			userDisplayName : "",
			visible : false,
			editable : false,
			isNew : true,
			formatedCreationDate : "",
			formatedModifiedDate: "",
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
				//$this.load(__announceId);
			},
			back : function(){
				var $this = this;
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/manage-announces" />");
				return false;
			},
			cancle : function(){
				var $this = this;
			},
			edit : function(e){
			 	var $this = this;
		 	},
		 	saveOrUpdate : function(e){				
				var $this = this;						
			},
			setSource : function( data ){
				var $this = this;	
			},
			load : function(objectId){
				var $this = this;						
			} 
		});
		
		community.ui.bind( $('#js-header') , observable );    
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	  
 
	});
	
	</script> 	
</head>
<body class="">
	<!-- Header -->
	<#include "includes/admin-header.ftl">
	<!-- End Header -->
	
	 	
</body>
</html>
</#compress> 	