<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html>
<head>	
	<meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    
	<title>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "REPLICANT") } | ADMIN v2.0</title>
	
    <!-- Kendoui with bootstrap theme CSS -->			
	<link href="<@spring.url "/css/kendo.ui.core/web/kendo.common-bootstrap.core.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/kendo.ui.core/web/kendo.bootstrap.min.css"/>" rel="stylesheet" type="text/css" />	
	
	<!-- Bootstrap CSS -->
   	<link href="<@spring.url "/css/bootstrap/4.0.0/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />	
    
    <!-- Bootstrap Theme CSS -->
    
    <link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />
    <link href="<@spring.url "/fonts/nanumgothic.min.css"/>" rel="stylesheet" type="text/css" />	 
    <link href="<@spring.url "/css/animate/animate.css"/>" rel="stylesheet" type="text/css" />	
    
    <!-- Community Admin CSS -->
    <link href="<@spring.url "/css/community.ui.admin/community-ui-admin-icons.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/css/community.ui.admin/community.ui.admin.css"/>" rel="stylesheet" type="text/css" />	
  	     
 	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js'"/>></script>
 	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>

 	<!-- Application JavaScript
    		================================================== -->    	
	<script>
	require.config({
		shim : {
			"bootstrap" 					: { "deps" :['jquery'] },
	        "bootstrap" 					: { "deps" :['jquery'] },
	        "kendo.ui.core.min" 			: { "deps" :['jquery'] },
	        "kendo.culture.ko-KR.min" 	: { "deps" :['jquery', 'kendo.ui.core.min'] },
	        "community.ui.core" 			: { "deps" :['jquery', 'kendo.culture.ko-KR.min'] },
	        "community.data" 			: { "deps" :['jquery', 'community.ui.core'] },	 
	        "community.ui.admin" 		: { "deps" :['jquery', 'jquery.cookie', 'community.ui.core', 'community.data'] }	   
		},
		paths : {
			"jquery"    					: "/js/jquery/jquery-3.1.1.min",
			"jquery.cookie"    			: "/js/jquery.cookie/1.4.1/jquery.cookie",
			"bootstrap" 	   				: "/js/bootstrap/4.0.0/bootstrap.bundle.min",
			"kendo.ui.core.min" 			: "/js/kendo.ui.core/kendo.ui.core.min",
			"kendo.culture.ko-KR.min"	: "/js/kendo.ui.core/cultures/kendo.culture.ko-KR.min",
			"community.ui.admin" 		: "/js/community.ui.components/community.ui.admin",
			"community.ui.core" 			: "/js/community.ui/community.ui.core",
			"community.data" 			: "/js/community.ui/community.data"
		}
	});
	require([ "jquery", "jquery.cookie", "bootstrap", "kendo.ui.core.min", "community.ui.core", "community.data", "community.ui.admin"], function($, kendo ) { 

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
			},
			createNewProperty: function(e){
				//var $this = this;			
				community.ui.listview($('#properties-listview')).add();
             	e.preventDefault();
    			}
		});
		
		// This is only for Admin   
		// 1. initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// 2. initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	   
	    				
		community.ui.bind( $('#js-header') , observable ); 
		var renderTo = $('#features');
		community.ui.bind( renderTo , observable );
		createPropertiesListView();
	 	
	});

	function createPropertiesListView(){
		var renderTo = $('#properties-listview');	
		var listview = community.ui.listview( renderTo , {
			dataSource: community.ui.datasource( null, {
				transport: { 
					read : 		{ url:'<@spring.url "/data/api/mgmt/v1/properties/list.json"/>', type:'post', contentType : "application/json" },
					create : 	{ url:'<@spring.url "/data/api/mgmt/v1/properties/update.json"/>', type:'post', contentType : "application/json" },
					update : 	{ url:'<@spring.url "/data/api/mgmt/v1/properties/update.json"/>', type:'post', contentType : "application/json" },
					destroy : 	{ url:'<@spring.url "/data/api/mgmt/v1/properties/remove.json"/>', type:'post', contentType : "application/json" },
					parameterMap: function (options, operation){	 
						if (operation !== "read" && options.models) { 
							return community.ui.stringify(options.models);
						}
						return community.ui.stringify(options);
					}
				},
				batch: true, 
				schema: {
					model: community.model.Property
				}
			}),
			editTemplate: community.ui.template($("#property-edit-template").html()),
			template: community.ui.template($("#property-template").html()),
			dataBound: function() {
				if( this.items().length == 0)
					renderTo.html('<tr class="g-height-50"><td colspan="3" class="align-middle g-font-weight-300 g-color-black text-center">조건에 해당하는 데이터가 없습니다.</td></tr>');
			}			
		}); 			
		community.ui.pager( $("#properties-listview-pager"), {
            dataSource: listview.dataSource
        }); 
	}		
	</script>
</head>
    
<body class="">
	<!-- Header -->
	<#include "includes/admin-header.ftl">
	<!-- End Header -->
	
	<section class="container-fluid px-0 g-pt-65">	
	<div class="row no-gutters g-pos-rel g-overflow-x-hidden">
		<!-- Sidebar Nav -->
		<#include "includes/admin-sidebar.ftl">
		<!-- End Sidebar Nav -->		
		<div class="col g-ml-45 g-ml-0--lg g-pb-65--md">
			<!-- Breadcrumb-v1 -->
			<div class="g-hidden-sm-down g-bg-gray-light-v8 g-pa-20">
				<ul class="u-list-inline g-color-gray-dark-v6">
					<li class="list-inline-item g-mr-10">
						<a class="u-link-v5 g-color-gray-dark-v6 g-color-lightblue-v3--hover g-valign-middle" href="#!">설정</a> 
						<i class="community-admin-angle-right g-font-size-12 g-color-gray-light-v6 g-valign-middle g-ml-10"></i>
					</li>
					<li class="list-inline-item">
						<span class="g-valign-middle">시스템 프로퍼티</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">시스템 프로퍼티</h1>
				<!-- Content Body -->
				<div id="features" class="container-fluid">

					<div class="row text-center text-uppercase g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
						<div class="col-6">
							<div class="alert alert-dismissible fade show g-bg-gray-dark-v2 g-color-white rounded-0" role="alert">
								<button type="button" class="close u-alert-close--light" data-dismiss="alert" aria-label="Close">
                          			<span class="g-color-white" aria-hidden="true">×</span>
                        			</button>
                        			<div class="media">
									<span class="d-flex g-mr-10 g-mt-5"><i class="icon-question g-font-size-25"></i></span>
                          			<span class="media-body align-self-center">
                          			<strong>주의!</strong>
                            			 속성값은 임의로 수정하거나 추가하는 경우 오류의 원인이 될 수 있습니다.
                          			</span>
                        			</div>
							</div>  
						</div>
						<div class="col-6 text-right">
						<a href="javascript:void();" class="btn btn-xl u-btn-primary g-width-180--md g-mb-10 g-font-size-default g-ml-10" data-bind="click:createNewProperty" >새로운 프로퍼티 만들기</a>
						</div>
					</div>			
					<div class="row">
                		<div class="table-responsive">
						<table class="table table-bordered js-editable-table u-table--v1 u-editable-table--v1 g-color-black g-mb-0">
							<thead class="g-hidden-sm-down g-color-gray-dark-v6">
								<tr class="g-height-50">
									<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black">속성</th>
									<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-width-50x">값</th>
									<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-width-120">&nbsp;</th>
								</tr>
							</thead>
							<tbody id="properties-listview"></tbody>
						</table>
					</div>
					<div id="properties-listview-pager" class="g-brd-top-none" style="width:100%;"></div>
            										
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
	
	<script type="text/x-kendo-template" id="property-template">   
	<tr>
		<td class="align-middle">#: name # </td>
		<td class="align-middle">#: value #</td>
		<td class="align-middle text-center">
			<div class="btn-group">
                <a class="btn btn-sm u-btn-outline-blue k-edit-button g-mb-0" href="\\#">수정</a>
                <a class="btn btn-sm u-btn-outline-blue k-delete-button g-mb-0" href="\\#">삭제</a>
            </div>
		</td>
	</td>
	</script>   
	
	<script type="text/x-kendo-template" id="property-edit-template">   
	<tr>
		<td class="align-middle">
			<input type="text" class="k-textbox form-control" data-bind="value:name" name="name" required="required" validationMessage="필수 입력 항목입니다." />
			<span data-for="name" class="k-invalid-msg"></span>
		</td>
		<td class="align-middle">
			<input type="text" class="k-textbox form-control" data-bind="value:value" name="value" required="required" validationMessage="필수 입력 항목입니다." />
			<span data-for="value" class="k-invalid-msg"></span>		
		</td>
		<td class="align-middle text-center">
			<div class="btn-group">
                <a class="btn btn-sm u-btn-outline-bluegray k-update-button g-mb-0" href="\\#">확인</a>
                <a class="btn btn-sm u-btn-outline-bluegray k-cancel-button g-mb-0" href="\\#">취소</a>
            </div>
		</td>
	</td>
	</script>		
</body>
</html>
</#compress>