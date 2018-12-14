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
	var __menuId = <#if RequestParameters.menuId?? >${RequestParameters.menuId}<#else>0</#if>;
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
	require([ "jquery", "jquery.cookie", "bootstrap", "community.data", "kendo.messages.min", "community.ui.admin", "community.ui.professional" ], function($, kendo ) { 
	
		community.ui.setup({
		  	features : {
				accounts: true
		  	},
		  	'features.accounts.authenticate' :function(e){
		  		observable.setUser(e.token);
		  	}
		});
		
		var usingTreeList = true;
 
		var observable = new community.ui.observable({ 
			currentUser : new community.model.User(),
			userAvatarSrc : "/images/no-avatar.png",
			userDisplayName : "",
			menu : new community.model.Menu(), 
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
				$this.load();
			},
			back : function(){
				var $this = this;
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/manage-menus" />");
				return false;
			},
			load : function(){
				var $this = this;		
				community.ui.ajax('<@spring.url "/data/api/mgmt/v1/ui/menus/"/>' + __menuId + '/get.json', {
					success: function(data){	
						var data = new community.model.Menu(data);
						data.copy( $this.menu ); 
						if( usingTreeList )
							createItemsTreeList();
						else
							createItemsListView();
					}	
				}); 		
			} 
		}); 
		community.ui.bind( $('#js-header') , observable );   
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	   
		var renderTo = $('#features');
		community.ui.bind( renderTo , observable ); 
		renderTo.on("click", "button[data-object-type=menu], a[data-object-type=menu], a[data-kind=menu], .sorting[data-kind=menu]", function(e){			
			var $this = $(this);
			var actionType = $this.data("action");	 
			if( actionType == 'sort'){
				if( $this.data('dir') == 'asc' )
					$this.data('dir', 'desc' );
				else if 	( $this.data('dir') == 'desc' )
					$this.data('dir', 'asc' );
				community.ui.listview( $('#items-listview') ).dataSource.sort({ field:$this.data('field'), dir:$this.data('dir') });				
				return false;
			}else if (actionType == 'refresh'){
				if( usingTreeList ){
					community.ui.treelist($('#items-treelist')).dataSource.read();
				}
				return false;		
			} 
			var objectId = $this.data("object-id");		
			var targetObject = new community.model.MenuItem();
			if ( objectId > 0 ) {
				targetObject = community.ui.listview( $('#items-listview') ).dataSource.get( objectId );				
			}
			if( usingTreeList )
				community.ui.treelist($('#items-treelist')).addRow();				
 			else
 				openMenuEditor(targetObject); 
			return false;		
		});	
	});
	
	function createItemsTreeList(){
		var renderTo = $('#items-treelist');	
		if( !community.ui.exists(renderTo)){
			var treelist = community.ui.treelist(renderTo, {
                    dataSource: {
                        transport: {
                            read: {
                            	   	contentType: "application/json; charset=utf-8",
                            		url: '<@spring.url "/data/api/mgmt/v1/ui/menus/"/>' + __menuId + '/items/list.json?widget=treelist' ,
                                	type :'POST',
                                	dataType: 'json'                                
                             },
                             update: {
                                 url: '<@spring.url "/data/api/mgmt/v1/ui/menus/"/>' + __menuId + '/items/save-or-update.json' ,
                                 type :'POST',  
                                 contentType : "application/json", 
                             	dataType: 'json'    
                             },
                             destroy: {
                                 url: '<@spring.url "/data/api/mgmt/v1/ui/menus/"/>' + __menuId + '/items/delete.json' ,
                            		type :'POST',
                            		contentType : "application/json",
                            		dataType: 'json'    
                             },
                             create: {
                                 url: '<@spring.url "/data/api/mgmt/v1/ui/menus/"/>' + __menuId + '/items/save-or-update.json' ,
                             	type :'POST',
                             	contentType : "application/json",
                             	dataType: 'json'    
                             },
							parameterMap: function (options, operation){	 
								if (operation !== "read" && options.models) {
                                     return {models: kendo.stringify(options.models)};
                                 }else{
									return community.ui.stringify(options);
								}
							}
                        },
                        schema: {
							data:  "items",
							model: {
								id: "menuItemId",
								parentId: "parentMenuItemId",
								fields: { 		
									menuItemId: { type: "number", defaultValue: 0 },		
									menuId: { type: "number", defaultValue: 0 },	
									parentMenuItemId: { type: "number", defaultValue: null },	
									name: { type: "string", defaultValue: null },	
									roles: { type: "string", defaultValue: null },	
									sortOrder: { type: "number", defaultValue: 1 },	
									location: { type: "string", defaultValue: null },	
									description: { type: "string", defaultValue: null },
									creationDate:{ type: "date" },			
									modifiedDate:{ type: "date"}
								},	
								expanded: false
							}
 							
                        }
                    },
                   selectable: "row",
                    height: 400,
                    filterable: false,
                    sortable: true,
                    toolbar: [ "create" ],
                    change : function() {
						var selectedRows = this.dataItem(this.select()); 
						console.log( community.ui.stringify(selectedRows) );
						createMenuItemPropertiesGrid(selectedRows);
					}, 
                    editable: {
                    		mode: "inline",
                    		move: true
                    },
                    columns: [
                        { field: "name", expandable: true, title: "메뉴", width: 200 },
                        { field: "description" , title: "설명", sortable: false, width: 250 },
                        { field: "sortOrder" , title: "정렬",  width: 100, attributes: { style: "text-align: center;"  }},
                        { field: "page" , title: "페이지" , sortable : false},
                        { field: "location" , title: "링크" , sortable : false},
                        { field: "roles", title: "권한" , width: 150, sortable : false},
                        { title: " ", command: [ "edit", "destroy" ], width: 200 }
                    ],
                    save: function(e){
				    	community.ui.treelist(renderTo).dataSource.read();
				    }
             });
             community.ui.treelist(renderTo).bind(
				"dragend", function(e){
					console.log("drag ended", community.ui.stringify(e.source), e.destination);
					this.dataSource.sync();
				}
             );   
        }    
	}
	
	function createMenuItemPropertiesGrid( data ){
		var renderTo = $('#item-grid');  
		if( renderTo.data('object-id') != data.get('menuItemId') ){  
			console.log("create grid with " + data.get('menuItemId') );
			if( community.ui.exists( renderTo ) ){
				console.log( "destroy grid...." );
				community.ui.grid(renderTo).destroy();
				console.log( renderTo.data('kendoGrid') );
			} 
			community.ui.grid(renderTo, {
				dataSource: {
					transport: { 
						read : 	{url:'<@spring.url "/secure/data/mgmt/menu/items/"/>' + data.menuItemId + '/properties/list.json', type:'post', contentType: "application/json; charset=utf-8"},
						create : { url:'<@spring.url "/secure/data/mgmt/menu/items/"/>' + data.menuItemId + '/properties/update.json', type:'post', contentType: "application/json; charset=utf-8" },
						update : { url:'<@spring.url "/secure/data/mgmt/menu/items/"/>' + data.menuItemId + '/properties/update.json', type:'post', contentType: "application/json; charset=utf-8" },
						destroy : { url:'<@spring.url "/secure/data/mgmt/menu/items/"/>' + data.menuItemId + '/properties/delete.json', type:'post', contentType: "application/json; charset=utf-8" },       
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
				}, 
				height : 300,
				sortable: true,
				filterable: false,
				pageable: false, 
				editable: true,
				toolbar: ["create", "save", "cancel"],
				columns: [
					{ field: "name", title: "이름", width: 250 , validation: { required: true} },  
					{ field: "value", title: "값" , validation: { required: true} },
					{ command: ["destroy"], title: "&nbsp;", width: 150}
				],
				save : function(){
				}
			});			
			renderTo.data( "object-id" , data.menuItemId );	
		} 
	}
	  
	</script>
	<style>
	.k-grid .k-state-selected td[role=gridcell]{
		font-weight : 500;
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
						<span class="g-valign-middle">메뉴</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">메뉴 관리</h1>
			</div>
				
				<!-- Content Body -->
				<div id="features" class="container-fluid">
					<div class="row g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
						<div class="col-12">
							<div class="media-md align-items-center g-mb-30">
		              			<div class="d-flex g-mb-15 g-mb-0--md">
									<header class="g-mb-10">
						            	<div class="u-heading-v6-2 text-uppercase" >
						              <h2 class="h4 u-heading-v6__title g-font-weight-300" data-bind="text:menu.name"></h2>
						            	</div>
						            	<div class="g-pl-90">
						              <p data-bind="text:menu.description"></p>
						            	</div>
						          	</header>		                				
		             	 		</div>	
								<div class="media d-md-flex align-items-center ml-auto">
					                <a class="d-flex align-items-center u-link-v5 g-color-lightblue-v3 g-color-primary--hover g-ml-15 g-ml-45--md" href="#!" data-bind="click:back">
					                  	<i class="hs-admin-angle-left g-font-size-18"></i>
					                 	<span class="g-hidden-sm-down g-ml-10">뒤로가기</span>
					                </a>			
					                <a class="d-flex align-items-center u-link-v5 g-color-lightblue-v3 g-color-primary--hover g-ml-15 g-ml-45--md" href="#!" data-action="refresh" data-object-type="menu" data-object-id="0"  >
					                  	<i class="hs-admin-reload g-font-size-18"></i>
					                 	<span class="g-hidden-sm-down g-ml-10">새로고침</span>
					                </a>
								</div>
		            			</div>
	                  	</div>
					</div>	
					<div class="row">
						<div id="items-treelist"></div> 
						<div id="item-grid"></div>
					</div>
				</div>
				<!-- End Content Body -->
 
			<!-- Footer -->
			<#include "includes/admin-footer.ftl">
			<!-- End Footer -->
		</div>
	</div>
	</section>
	
	<!-- menu editor modal -->
	<div class="modal fade" id="menu-item-editor-modal" tabindex="-1" role="dialog" aria-labelledby="menu-item-editor-modal-labal" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				
				<!-- .modal-header -->
				<div class="modal-header">
					<h2 class="modal-title">MENU</h2>
			        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
			          	<i aria-hidden="true" class="icon-svg icon-svg-sm icon-svg-ios-close m-t-xs"></i>
			        </button>			       
		      	</div>
			    <!-- /.modal-header -->
			    <!-- .modal-body -->
				<div class="modal-body">
					<div class="form-group g-mb-10">
						<div class="g-pos-rel">
							<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
							<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
							</span>
							<input class="form-control g-rounded-4" type="text" placeholder="파일명을 입력하세요" data-bind="value: item.name,enabled:editable">
							<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">메뉴를 구분하는 이름입니다.</small>
						</div>
					</div>
										
					<div class="form-group g-mb-10">
						<div class="g-pos-rel">
							<textarea class="form-control form-control-md g-resize-none g-rounded-4" rows="3" placeholder="간략하게 메뉴에 대한 설명을 입력하세요." data-bind="value: item.description, enabled:editable"></textarea>
						</div>
					</div>
					<div class="form-group g-mb-10">
						<div class="g-pos-rel">
							<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
							<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
							</span>
							<input class="form-control g-rounded-4" type="text" placeholder="링크" data-bind="value: item.location,enabled:editable">
							<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">메뉴를 클릭할 때 이동할 경로 정보입니다.</small>
						</div>
					</div>					
					<div class="g-brd-around g-brd-gray-light-v7 g-rounded-4 g-pa-15 g-pa-20--md g-mb-15">
					<div class="row">
						<div class="col-md-4">
							<h3 class="d-flex align-self-center text-uppercase g-font-size-12 g-font-size-default--md g-color-blackg-mb-15">부모 ID</h3>
							<div class="form-group">
							<input data-role="numerictextbox"
				                   data-format="n0"
				                   data-min="0"
				                   data-max="100"
				                   data-bind="value: item.parentMenuItemId">
							</div>
						</div>
						<div class="col-md-4">
							<h3 class="d-flex align-self-center text-uppercase g-font-size-12 g-font-size-default--md g-color-black mb-0">정렬순서</h3>
							<div class="form-group">
							<input data-role="numerictextbox"
				                   data-format="n0"
				                   data-min="0"
				                   data-max="100"
				                   data-bind="value: item.sortOrder">
							</div>
						</div>
						<div class="col-md-4" data-bind="visible:editable" style="">
							<header class="media g-mb-20">
							<h3 class="d-flex align-self-center text-uppercase g-font-size-12 g-font-size-default--md g-color-black mb-0">고급설정</h3>
								<div class="media-body d-flex justify-content-end">
								<a class="hs-admin-panel u-link-v5 g-font-size-20 g-color-gray-light-v3 g-color-secondary--hover" href="#!" data-bind="click: showOptions"></a>
								</div>
							</header>
							</div>
						</div>
					</div>		
				</div>
		      	<!-- /.modal-body -->		
		      	<div class="modal-footer">
			        <button type="button" class="btn btn-secondary" data-dismiss="modal">취소</button>
			        <button type="button" class="btn btn-primary" data-bind="click:saveOrUpdate">확인</button>
		      	</div><!-- /.modal-footer --> 				      			      	
				
	    		</div><!-- /.modal-content -->
		</div><!-- /.modal-dialog -->
	</div><!-- /.modal -->	
	<script type="text/x-kendo-template" id="template">    	
	<tr>
		<td class="g-px-30">#: menuItemId # </td>
		<td class="g-px-30">#if( parentMenuItemId < 0 ) {# - #}else{# #:parentMenuItemId # #}#</td>
		<td class="g-px-30">
		<a class="d-flex align-items-center u-link-v5 g-color-black g-color-lightblue-v3--hover g-color-lightblue-v3--opened" href="\#!" data-object-id="#=menuId#" data-object-type="menu">#: name #</a>
		</td>
		<td class="g-px-30">#: description #</td>
		<td class="g-px-30">#: community.data.getFormattedDate( creationDate)  #</td>
		<td class="g-px-30">#: community.data.getFormattedDate( modifiedDate)  #</td>
		<td class="g-px-30">
			<div class="d-flex align-items-center g-line-height-1">
				<a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover g-mr-15" href="\#!" data-action="edit" data-object-type="menu" data-object-id="#= menuId #" >
					<i class="hs-admin-pencil g-font-size-18"></i>
                </a>
                <!--
                <a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover" href="\#!" data-action="delete" data-object-type="menu" data-object-id="#= menuId #" >
                		<i class="hs-admin-trash g-font-size-18"></i>
                </a>-->
			</div>
		</td>
	</tr>
	</script>			
</body>
</html>
</#compress>