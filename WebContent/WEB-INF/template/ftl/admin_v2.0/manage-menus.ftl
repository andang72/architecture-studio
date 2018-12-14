<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html>
<head>	
	<meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    
	<title>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "REPLICANT") } | ADMIN v2.0</title>
	
 	<!-- Bootstrap CSS -->
    <link href="<@spring.url "/css/bootstrap/4.1.3/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />
    		
	<!-- Professional Kendo UI --> 	
	<link href="<@spring.url "/css/kendo/2018.3.1017/kendo.common.min.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/kendo/2018.3.1017/kendo.bootstrap-v4.min.css"/>" rel="stylesheet" type="text/css" />	
	 
     <!-- Bootstrap Theme CSS -->
	<link href="<@spring.url "/fonts/nanumgothic.min.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />	
    
    <link href="<@spring.url "/css/animate/animate.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/assets/vendor/icon-line-pro/style.css"/>" rel="stylesheet" type="text/css" /> 
	
	<link href="<@spring.url "/css/community.ui/community.ui.icons.min.css"/>" rel="stylesheet" type="text/css" />	 
    <link href="<@spring.url "/css/bootstrap.theme/unify-admin/vendor/hs-admin-icons/hs-admin-icons.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/css/bootstrap.theme/unify-admin/unify-admin.css"/>" rel="stylesheet" type="text/css" />	
  	     
 	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js'"/>></script>
 	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>

 	<!-- Application JavaScript
    		================================================== -->    	
	<script>
	require.config({
		shim : {
			"jquery.cookie" 				: { "deps" :['jquery'] },
	        "bootstrap" 					: { "deps" :['jquery'] },
	        "kendo.web.min" 				: { "deps" :['jquery'] },
	        "kendo.culture.min" 			: { "deps" :['jquery', 'kendo.web.min'] },	   
	        "kendo.messages.min" 			: { "deps" :['jquery', 'kendo.web.min'] },	
	        "community.ui.core" 			: { "deps" :['jquery', "kendo.web.min", 'kendo.culture.min', 'kendo.messages.min'] },
	        "community.data" 				: { "deps" :['jquery', 'community.ui.core'] },	 
	        "community.ui.professional" 	: { "deps" :['jquery', 'community.ui.core'] },
	        "community.ui.admin" 			: { "deps" :['jquery', 'community.ui.core', 'community.data'] }
		},
		paths : {
			"jquery"    				: "<@spring.url "/js/jquery/jquery-3.3.1.min"/>",
			"jquery.cookie"    			: "<@spring.url "/js/jquery.cookie/1.4.1/jquery.cookie"/>",
			"bootstrap" 				: "<@spring.url "/js/bootstrap/4.1.3/bootstrap.bundle.min"/>",
			"kendo.web.min"	 			: "<@spring.url "/js/kendo/2018.3.1017/kendo.web.min"/>",
			"kendo.culture.min"			: "<@spring.url "/js/kendo/2018.3.1017/cultures/kendo.culture.ko-KR.min"/>",	
			"kendo.messages.min"		: "<@spring.url "/js/kendo.extension/kendo.messages.ko-KR"/>",	
			"community.ui.core" 		: "<@spring.url "/js/community.ui/community.ui.core"/>",
			"community.ui.professional" : "<@spring.url "/js/community.ui/community.ui.professional"/>",
			"community.data" 			: "<@spring.url "/js/community.ui/community.data"/>",
			"community.ui.admin" 		: "<@spring.url "/js/community.ui/community.ui.admin"/>"
		}
	});
	require([ "jquery", "jquery.cookie", "bootstrap", "community.data", "kendo.messages.min", "community.ui.admin" ], function($, kendo ) { 
	
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
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
				
			}
		});
		
		community.ui.bind( $('#js-header') , observable );        
		
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	  
	     
		var renderTo = $('#features');
	 	renderTo.on("click", "button[data-object-type=menu], a[data-object-type=menu], .sorting[data-kind=menu]", function(e){			
			console.log("--");
			var $this = $(this);
			var actionType = $this.data("action");	
			if (actionType == 'view'){
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/menu-editor" />", { menuId: $this.data("object-id") });
				return false;
			} 
			community.ui.grid( $('#menu-grid') ).addRow(); 
			return false;		
		});	 
		
		createMenuGrid(observable); 
		
	});
	
	
	function createMenuGrid(observable){
		var renderTo = $('#menu-grid');
		if( !community.ui.exists( renderTo ) ){
			community.ui.grid(renderTo, {
				dataSource: {
					transport: { 
						read : { url:'<@spring.url "/data/api/mgmt/v1/ui/menus/list.json"/>', type:'post', dataType:'json', contentType: 'application/json; charset=utf-8' },
						create : { url:'<@spring.url "/data/api/mgmt/v1/ui/menus/save-or-update.json"/>', type:'post', dataType:'json', contentType: 'application/json; charset=utf-8' },
						update : { url:'<@spring.url "/data/api/mgmt/v1/ui/menus/save-or-update.json"/>', type:'post', dataType:'json', contentType: 'application/json; charset=utf-8' },
						destroy : { 
							url:'<@spring.url "/data/api/mgmt/v1/ui/menus/delete.json"/>', 
							type:'post', 
							dataType:'json', 
							contentType: 'application/json; charset=utf-8' },
						parameterMap: function (options, operation){	 
							if (operation !== "read" && options.models) { 
								return community.ui.stringify(options.models);
							}
							return community.ui.stringify(options);
						}
					}, 
					serverPaging: true,
					pageSize: 15	,
					serverSorting: true,
					schema: {
						total: "totalCount",
						data:  "items",
						model: community.model.Menu
					}
				},
				height : 500,
				sortable: true,
				filterable: false, 
				editable: "inline",
				columns: [
					{ field: "menuId", title: "ID", width: 80  },
					{ field: "name", title: "이름", width: 250 , validation: { required: true} , template: $('#column-name-template').html() }, 
					{ field: "description", title: "설명", filterable: false, sortable: false },  
					{ command: ["destroy", "edit"], title: "&nbsp;", width: 250}
				]
			});			
		}		
	}
	
	
	</script>
</head>
    
<body class="">
	<!-- Header -->
	<#include "includes/admin-header-v2.ftl">
	<!-- End Header -->
	
	<section class="container-fluid px-0 g-pt-65">	
	<div class="row no-gutters g-pos-rel g-overflow-x-hidden">
		<!-- Sidebar Nav -->
		<#include "includes/admin-sidebar-v2.ftl">
		<!-- End Sidebar Nav -->		
		<div class="col g-ml-45 g-ml-0--lg g-pb-65--md">
			<!-- Breadcrumb-v1 -->
			<div class="g-hidden-sm-down g-bg-gray-light-v8 g-pa-20">
				<ul class="u-list-inline g-color-gray-dark-v6">
					<li class="list-inline-item g-mr-10">
						<a class="u-link-v5 g-color-gray-dark-v6 g-color-lightblue-v3--hover g-valign-middle" href="#!">리소스</a> <i class="hs-admin-angle-right g-font-size-12 g-color-gray-light-v6 g-valign-middle g-ml-10"></i>
					</li>
					<li class="list-inline-item">
						<span class="g-valign-middle">메뉴</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">메뉴 관리</h1> 
			
 
				<!-- Content Body -->
				<div id="features" class="container-fluid">
					<div class="row text-center text-uppercase g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
						<div class="col-6 text-right"></div>
						<div class="col-6 text-right">
						<a href="javascript:void();" class="btn btn-xl u-btn-3d u-btn-primary g-width-180--md g-mb-10 g-font-size-default g-ml-10" data-action="create" data-object-type="menu" data-object-id="0">새로운 메뉴 만들기</a>
						</div>
					</div>
					<div class="row"> 
						<div id="menu-grid" class="g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-1"></div>  
					</div>
				</div>
				<!-- End Content Body -->
			</div>	
			<!-- Footer -->
			<#include "includes/admin-footer.ftl">
			<!-- End Footer -->
		</div>
	</div>
	</section> 
	 
	<script type="text/x-kendo-template" id="column-name-template">    	
	<a class="d-flex align-items-center u-link-v5 u-link-underline g-color-black g-color-lightblue-v3--hover g-color-lightblue-v3--opened" href="\#!" data-action="view" data-object-id="#=menuId#" data-object-type="menu">
	#: name #
	</a>	
	</script>				
	 
</body>
</html>
</#compress>