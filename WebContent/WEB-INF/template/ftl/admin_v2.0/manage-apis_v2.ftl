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
	<link href="<@spring.url "/css/kendo/2018.3.1017/kendo.bootstrap-v4.min.css"/>" rel="stylesheet" type="text/css" />	
	

    <!-- Bootstrap Theme CSS -->
	<link href="<@spring.url "/fonts/nanumgothic.min.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />	
    
    <link href="<@spring.url "/css/animate/animate.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/assets/vendor/icon-line-pro/style.css"/>" rel="stylesheet" type="text/css" />
	 
    <link href="<@spring.url "/css/bootstrap.theme/unify-admin/vendor/hs-admin-icons/hs-admin-icons.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/css/bootstrap.theme/unify-admin/unify-admin.css"/>" rel="stylesheet" type="text/css" />	
 
	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js'"/>></script>
	
 	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>

 	<!-- Application JavaScript
    		================================================== -->    	
	<script>
	var observable ;
	require.config({
		shim : {
			<!-- summernote -->
			"summernote-ko-KR" : { "deps" :['summernote.min'] },
			<!-- Bootstrap -->
			"jquery.cookie" 			: { "deps" :['jquery'] },
	        "bootstrap" 				: { "deps" :['jquery'] },
			<!-- Professional Kendo UI -->
			"kendo.web.min" 			: { "deps" :['jquery'] },
	        "kendo.culture.min" 		: { "deps" :['jquery', 'kendo.web.min'] },	   
	        "kendo.messages.min" 		: { "deps" :['jquery', 'kendo.web.min'] },	  
			<!-- community -- >
	        "community.ui.core"			: { "deps" :['jquery', 'kendo.web.min', 'kendo.culture.min' ] },
	        "community.data" 			: { "deps" :['jquery', 'kendo.web.min', 'community.ui.core' ] },
	        "community.ui.admin" 		: { "deps" :['jquery', 'jquery.cookie', 'community.ui.core', 'community.data'] }	    
		},
		paths : {
			"jquery"    					: "<@spring.url "/js/jquery/jquery-3.1.1.min"/>",
			"jquery.cookie"    				: "<@spring.url "/js/jquery.cookie/1.4.1/jquery.cookie"/>",
			"bootstrap" 				: "<@spring.url "/js/bootstrap/4.1.3/bootstrap.bundle.min"/>",
			
			<!-- Professional Kendo UI --> 
			"kendo.web.min"	 			: "<@spring.url "/js/kendo/2018.3.1017/kendo.web.min"/>",
			"kendo.culture.min"			: "<@spring.url "/js/kendo/2018.3.1017/cultures/kendo.culture.ko-KR.min"/>",	
			"kendo.messages.min"		: "<@spring.url "/js/kendo.extension/kendo.messages.ko-KR"/>",	
			
			<!-- community -- >
			"community.ui.core" 		: "<@spring.url "/js/community.ui/community.ui.core"/>",
			"community.data" 			: "<@spring.url "/js/community.ui/community.data"/>",   						
			"community.ui.admin" 		: "<@spring.url "/js/community.ui/community.ui.admin"/>",
			
			"ace" 						 : "<@spring.url "/js/ace/ace"/>",
			"summernote.min"             : "<@spring.url "/js/summernote/summernote.min"/>",
			"summernote-ko-KR"           : "<@spring.url "/js/summernote/lang/summernote-ko-KR"/>",
			"dropzone"					 : "<@spring.url "/js/dropzone/dropzone"/>"			
		}
	});
	require([ "jquery", "bootstrap", "community.data", "kendo.messages.min", "community.ui.admin" ], function($, kendo ) { 
	
		community.ui.setup({
		  	features : {
				accounts: true
		  	},
		  	'features.accounts.authenticate' :function(e){
		  		observable.setUser(e.token);
		  	}
		});
		
		observable = new community.ui.observable({ 
			currentUser : new community.model.User(),
			userAvatarSrc : "<@spring.url "/images/no-avatar.png"/>",
			userDisplayName : "",
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
				
				createApiGrid();
			}
		});
				
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false}); 
		community.ui.bind( $('#js-header') , observable );       
		var renderTo = $('#features');
		community.ui.bind( renderTo , observable );
		
		renderTo.on("click", "button[data-object-type=api], a[data-object-type=api]", function(e){			
			var $this = $(this);
			var actionType = $this.data("action");	
			if (actionType == 'view' || actionType == 'create'  || actionType == 'edit'  ){
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/api-editor_v2" />", { apiId: $this.data("object-id") });
				return false;
			}		
			return false;		
		});	
			 	
	}); 

	function createApiGrid(){
		var renderTo = $('#project-grid');		
		var grid = community.ui.grid( renderTo , {
			dataSource: community.ui.datasource_v2({
				transport:{
					read:{
						contentType : "application/json; charset=utf-8",
						url : '<@spring.url "/data/api/mgmt/v1/pages/api/list.json"/>',
						type : 'POST',
						dataType : 'json'
					},
					parameterMap : function (options, operation){		
						return community.ui.stringify(options);
					} 				
				},		
				schema: {					
					data:  "items",
					total: "totalCount",
					model: community.data.model.Api
				},
				serverPaging: true,
				serverSorting: true,
				serverFiltering:true,
				pageSize: 15
			}), 
			pageable: true, 
			sortable: true,
			filterable: false,
 			height: 900,
			dataBound : function(e){
				//$('[data-toggle="tooltip"]').tooltip();
			},	
			columns: [
				{ field: "API_ID", title: "ID", filterable: false, sortable: true , width : 100 , template:'#= apiId #', attributes:{ class:"text-center" }}, 
				{ field: "API_NAME", title: "이름", filterable: false, sortable: true, template: $('#name-column-template').html()  },  
				{ field: "API_VERSION", title: "버전", filterable: false, sortable: true, width:100, template: '#= apiVersion#', attributes:{ class:"text-center" } }, 
				{ field: "ENABLED", title: "사용여부", filterable: false, sortable: true, width:100, template: $('#enabled-column-template').html(), attributes:{ class:"text-center" } }, 
				{ field: "userId", title: "작성자", filterable: false, sortable: true, width:100, template: $('#user-column-template').html(), attributes:{ class:"text-center" } },
				{ field: "CREATION_DATE", title: "생성일", filterable: false, sortable: true , width : 100 , template:'#= community.data.getFormattedDate( creationDate, "yyyy.MM.dd") #' ,attributes:{ class:"text-center" } } , 
				{ field: "MODIFIED_DATE", title: "수정일", filterable: false, sortable: true , width : 100 , template:'#= community.data.getFormattedDate( modifiedDate, "yyyy.MM.dd") #' ,attributes:{ class:"text-center" } }
			]	
		});	
				 	
	}
	  	
	</script>
	<style>
	.k-grid .u-link-underline > h5, .k-grid .u-link-underline > .u-title{
		border-bottom: 1px solid transparent; 
		padding-bottom: 1.5px;
	}
	
	.k-grid .u-link-underline:hover > h5, .k-grid .u-link-underline:hover > .u-title {
		border-bottom: 1px solid;
		padding-bottom: 1.5px;
	}		
	</style>
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
						<span class="g-valign-middle">API 서비스</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">API 서비스</h1>
			 
				<!-- Content Body -->
				<div id="features" class="container-fluid">
					<div class="row text-center text-uppercase g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
						<div class="col-6 text-left">
						<p class="text-danger g-font-weight-100">RESTful API 을 사용하여 다양한 비즈니스 로직을 구현할 수 있습니다.</p>
						</div>
						<div class="col-6 text-right">
						<a href="javascript:void();" class="btn btn-xl u-btn-3d u-btn-primary g-width-180--md g-mb-10 g-font-size-default g-ml-10" data-action="create" data-object-type="api"  data-object-id="0" >새로운 API 만들기</a>
						</div>
					</div>				
					<div class="row"> 
						<div id="project-grid" class="g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-1"></div>  
					</div>  	
				</div>
				<!-- End Content Body -->
			
			<!-- Footer -->
			<#include "includes/admin-footer.ftl">
			<!-- End Footer -->
		</div>
	</div>
	</section> 
	
    <script type="text/x-kendo-template" id="enabled-column-template"> 
	<em class="d-flex align-self-center align-items-center g-font-style-normal g-color-gray-dark-v6">
		<span class="g-pos-rel g-width-18 g-height-18 g-brd-around #if(enabled){# g-bg-lightblue-v3 g-brd-lightblue-v3 #}else{# g-brd-gray-light-v7 #}#  rounded-circle">
		<i class="hs-admin-check g-absolute-centered g-font-weight-800 g-font-size-8 #if(enabled){# g-color-white #}else{# g-color-gray-light-v7 #}#" title="Enabled"></i>
		</span>
		<span class="g-ml-5 g-hidden-lg-down g-font-weight-300 g-font-size-default #if(enabled){# g-color-lightblue-v3 #}else{# g-color-gray-light-v7 #}#" g-ml-8">#: enabled #</span>		
	</em>
    </script>                       
    <script type="text/x-kendo-template" id="name-column-template">    	
    
		<a class="d-flex align-items-center u-link-v5 u-link-underline g-color-black g-color-lightblue-v3--hover g-color-lightblue-v3--opened" href="\#!" data-action="view" data-object-id="#=apiId#" data-object-type="api">
		<h5 class="g-font-weight-100 g-mb-0">
		#if (secured) { # <i class="hs-admin-lock"></i>  # } else {# <i class="hs-admin-unlock"></i> #}#
		#= apiName # #if(pattern!=null) { ##= pattern ##}#
		</h5> 
		</a>
		<p class="g-font-weight-300 g-color-gray-dark-v6 g-mt-5 g-ml-10 g-mb-0" >#= title #</p>
   
  </script> 	    	    
	<script type="text/x-kendo-template" id="user-column-template">    
			<div class="media">
            		<div class="d-flex align-self-center">
                    <img class="g-width-36 g-height-36 rounded-circle g-mr-15" src="#= community.data.getUserProfileImage(creator) #" >
                </div>
				<div class="media-body align-self-center text-left">#if ( !creator.anonymous && creator.name != null ) {# #: creator.name # #}#</div>
            </div>	
	</script>
</body>
</html>
</#compress>