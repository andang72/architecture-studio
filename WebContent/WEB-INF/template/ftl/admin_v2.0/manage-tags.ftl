<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html>
<head>	
	<meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    
	<title>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "REPLICANT") } | ADMIN v2.0</title>
	
	<!-- Bootstrap CSS -->
   	<link href="<@spring.url "/css/bootstrap/4.0.0/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />	
   			
    <!-- Kendoui with bootstrap theme CSS -->			
	<!-- <link href="<@spring.url "/css/kendo/2018.1.221/kendo.common.min.css"/>" rel="stylesheet" type="text/css" />-->
	<link href="<@spring.url "/css/kendo/2018.1.221/kendo.bootstrap-v4.min.css"/>" rel="stylesheet" type="text/css" />	
	

    
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
	
	var observable ;
	
	require.config({
		shim : {
			"bootstrap" 				: { "deps" :['jquery'] }, 
	        "kendo.core" 				: { "deps" :['jquery' ] },	 
	        "kendo.web.min" 			: { "deps" :['jquery'] },
	        "kendo.culture.min" 		: { "deps" :['jquery', 'kendo.web.min'] },	   
	        "kendo.messages.min" 		: { "deps" :['jquery', 'kendo.web.min'] },	 
	        "community.ui.core"			: { "deps" :['jquery', 'kendo.web.min', 'kendo.culture.min' ] },
	        "community.data" 			: { "deps" :['jquery', 'kendo.web.min', 'community.ui.core' ] },
	        "community.ui.admin" 		: { "deps" :['jquery', 'jquery.cookie', 'community.ui.core', 'community.data'] }	   
		},
		paths : {
			"jquery"    				: "/js/jquery/jquery-3.1.1.min",
			"jquery.cookie"    			: "/js/jquery.cookie/1.4.1/jquery.cookie",
			<!-- bootstrap -->			
			"bootstrap" 	   			: "/js/bootstrap/4.0.0/bootstrap.bundle.min",
						
			<!-- kendoui -->
			"kendo.core"	 			: "/js/kendo/2018.1.221/kendo.core.min",
			"kendo.web.min"	 			: "/js/kendo/2018.1.221/kendo.web.min",
			"kendo.culture.min"			: "/js/kendo/2018.1.221/cultures/kendo.culture.ko-KR.min",	
			"kendo.messages.min"		: "/js/kendo.extension/kendo.messages.ko-KR",	
			<!-- community -- >
			"community.ui.core" 		: "/js/community.ui/community.ui.core",
			"community.data" 			: "/js/community.ui/community.data", 
			"community.ui.admin" 		: "/js/community.ui.components/community.ui.admin"
		}
	});
	require([ "jquery","jquery.cookie",  "bootstrap", "community.data", "community.ui.admin", "kendo.messages.min" ], function($, kendo ) { 
	
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
			userAvatarSrc : "/images/no-avatar.png",
			userDisplayName : "",
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
			},
			createNewTag: function(e){
				//var $this = this;			
				community.ui.grid($('#tag-grid')).addRow(); 
				return false;
    		},
			objectTypeDataSource: community.ui.datasource( '<@spring.url "/data/api/v1/objects/type/list.json" />' , {
                schema : {
                    model: {
                        id: "OBJECT_TYPE"
                    }   
                }
            } ),
		});
		
		community.ui.bind( $('#js-header') , observable );    
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	    
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	  
	     
		var renderTo = $('#features');
		community.ui.bind( renderTo , observable );
		
		observable.objectTypeDataSource.fetch(function(){
			createTagGrid(observable); 
		});
		
	});
	
    // OBJECT TYPE
    function getObjectTypeName( code ) { 
        var item = observable.objectTypeDataSource.get( code );
        if( item != null )
            return item.NAME;
        else
            return '0' ;
    }
        
    
        
    function objectTypeDropDownEditor(container, options) {
        $('<input  name="' + options.field + '"/>')
            .appendTo(container)
            .kendoDropDownList({
            autoBind: true,
            valuePrimitive: true,
            dataTextField: "NAME",
            dataValueField: "OBJECT_TYPE",
            dataSource: observable.objectTypeDataSource
        });
    }
    
   	function getTagName( code ){
   		var renderTo = $('#tag-grid'); 
   		var item = community.ui.grid(renderTo).dataSource.get(code);
   		if( item != null )
            return item.name;
        else
            return '' ;
   	}
   	
	function nonEditor(container, options) {
	    container.text(options.model[options.field]);
	}   
		 		 	
	function createTagGrid(observable){
		var renderTo = $('#tag-grid');  
		if( !community.ui.exists(renderTo) ){  
			community.ui.grid(renderTo, {
				dataSource: {
					transport: { 
						read : { url:'<@spring.url "/data/api/mgmt/v1/tags/list.json"/>', type:'post', contentType: "application/json; charset=utf-8"},
						create : { url:'<@spring.url "/data/api/mgmt/v1/tags/create.json"/>',  type:'post', contentType: "application/json; charset=utf-8"}, 
						parameterMap: function (options, operation){	 
							if (operation !== "read" && options.models) { 
								return community.ui.stringify(options.models);
							}
							return community.ui.stringify(options);
						}
					},  
					serverPaging: false,
					pageSize: 15,
					schema: {
						total: "totalCount",
						data:  "items",
						model: {
							id : "tagId",
							fields :{
								tagId: { type: "number", defaultValue: 0 },
								name: { type: "string", defaultValue: null }
							}
						}
					}
				},
				height : 400,
				sortable: true,
				filterable: false,
				pageable: false, 
				editable: "inline", 
				columns: [
					{ field: "tagId", title: "ID", width:100 , editor: nonEditor },  
					{ field: "name", title: "이름" , validation: { required: true}, template: '<a class="u-link-v5 u-link-underline g-color-primary--hover g-font-weight-400" data-kind="tag" data-object-id="#= tagId #" >#: name #</a>' },
					{ command: ["edit", "destroy"], title: "&nbsp;", width: "250px"}
				]
			});		
			
			var grid2 = createTagObjectGrid(observable);		
			renderTo.on("click", "a[data-kind=tag]", function(e){ 
				var $this = $(this);
				var objectId = $this.data("object-id");	 
				grid2.dataSource.read({ tagId : objectId });
				return false;		
			});	
			
																																					
		}		
	}	 

	function createTagObjectGrid(observable){
		var renderTo = $('#tag-object-grid');  
		if( !community.ui.exists(renderTo) ){  
			community.ui.grid(renderTo, {
				autoBind : false,
				dataSource: {
					transport: { 
						read : { url:'<@spring.url "/data/api/mgmt/v1/tags/object-list.json"/>', type:'post', contentType: "application/json; charset=utf-8"},
						create : { url:'<@spring.url "/data/api/mgmt/v1/tags/create.json"/>',  type:'post', contentType: "application/json; charset=utf-8"}, 
						parameterMap: function (options, operation){	 
							if (operation !== "read" && options.models) { 
								return community.ui.stringify(options.models);
							}
							return community.ui.stringify(options);
						}
					},  
					serverPaging: true,
					pageSize: 15,
					schema: {
						total: "totalCount",
						data:  "items",
						model: {
							id : "key",
							fields :{
								key: { type: "string", defaultValue: null },
								tagId: { type: "number", defaultValue: 0 },
								objectType: { type: "number", defaultValue: 0 },
								objectId: { type: "number", defaultValue: 0 }
							}
						}
					}
				},
				height : 400,
				sortable: false,
				filterable: false,
				pageable: false, 
				editable: "inline", 
				toolbar: ["create"],
				columns: [
					{ field: "tagId", title: "태그", width:300 , editor: nonEditor, template: "#: getTagName(tagId) #" },  
					{ field: "objectType", title: "객체 유형" , validation: { required: true} , editor: objectTypeDropDownEditor, template:"#: getObjectTypeName(objectType) #" },
					{ field: "objectId", title: "객체 ID" , validation: { required: true} },
					{ command: ["edit", "destroy"], title: "&nbsp;", width: "250px"}
				]
			});	  											
		}
		return community.ui.grid(renderTo);		
	}	 
 	
	
	</script>
	<style>
	#tag-grid .k-command-cell a.k-grid-edit {
		display:none;
	}
	</style>
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
						<a class="u-link-v5 g-color-gray-dark-v6 g-color-lightblue-v3--hover g-valign-middle" href="#!">커뮤니티</a> <i class="community-admin-angle-right g-font-size-12 g-color-gray-light-v6 g-valign-middle g-ml-10"></i>
					</li>
					<li class="list-inline-item">
						<span class="g-valign-middle">태그</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">태그 관리</h1>
				<!-- Content Body -->
				<div id="features" class="container-fluid">
					<div class="row text-center text-uppercase g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
					<div class="col-6 text-left">
						<div class="alert alert-dismissible fade show g-bg-gray-dark-v2 g-color-white rounded-0" role="alert">
								<button type="button" class="close u-alert-close--light" data-dismiss="alert" aria-label="Close">
                          			<span class="g-color-white" aria-hidden="true">×</span>
                        			</button>
                        			<div class="media">
									<span class="d-flex g-mr-10 g-mt-5"><i class="icon-question g-font-size-25"></i></span>
                          			<span class="media-body align-self-center">
                            			이름을 클릭하면 태그가 부여된 객체들을 확인할 수 있습니다.
                          			</span>
                        			</div>
						</div>  
					</div>
					<div class="col-6 text-right">
					<a href="javascript:void();" class="btn btn-xl u-btn-3d u-btn-primary g-width-200--md g-mb-15 g-font-size-default g-ml-10" data-bind="click:createNewTag">새로운 태그 만들기</a>
					</div>
					</div>
					<div class="row"> 
						<div id="tag-grid" class="g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3"></div>
						<div id="tag-object-grid" class="g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3"></div> 
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
	
	<!-- menu editor modal -->
	<div class="modal fade" id="menu-editor-modal" tabindex="-1" role="dialog" aria-labelledby="menu-editor-modal-labal" aria-hidden="true">
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
							<i class="community-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
							</span>
							<input class="form-control g-rounded-4" type="text" placeholder="파일명을 입력하세요" data-bind="value: menu.name,enabled:editable">
							<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">외부에서 페이지를 호출할때 사용되는 이름입니다.</small>
						</div>
					</div>
										
					<div class="form-group g-mb-10">
						<div class="g-pos-rel">
							<textarea class="form-control form-control-md g-resize-none g-rounded-4" rows="3" placeholder="간략하게 페이지에 대한 설명을 입력하세요." data-bind="value: menu.description, enabled:editable"></textarea>
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
	<script type="text/x-kendo-template" id="edit-template">    	
	<tr>
		<td class="g-px-30">#: categoryId # </td>
		<td class="">
			<input type="text" class="k-textbox form-control" data-bind="value:name" name="name" required="required" validationMessage="필수 입력 항목입니다." />
		</td>
		<td class="">
			<input type="text" class="k-textbox form-control" data-bind="value:displayName" name="displayName" required="required" validationMessage="필수 입력 항목입니다." />
		</td>		
		<td class="g-px-30">
			<input type="text" class="k-textbox form-control" data-bind="value:description" name="description" required="required" validationMessage="필수 입력 항목입니다." />
		</td>
		<td class="g-px-30">#: community.data.getFormattedDate( creationDate)  #</td>
		<td class="g-px-30">#: community.data.getFormattedDate( modifiedDate)  #</td>
		<td class="">
				<a class="btn btn-sm u-btn-outline-bluegray k-update-button g-mb-0" href="\\#">확인</a>
                <a class="btn btn-sm u-btn-outline-bluegray k-cancel-button g-mb-0" href="\\#">취소</a>
		</td>
	</tr>
	</script>	
		
	<script type="text/x-kendo-template" id="template">    	
	<tr class="u-listview-item">
		<td class="g-px-30">#: categoryId # </td>
		<td class="g-px-30">
		#: name #
		</td>
		<td class="g-px-30">#: displayName #</td>
		<td class="g-px-30">#: description #</td>
		<td class="g-px-30">#: community.data.getFormattedDate( creationDate)  #</td>
		<td class="g-px-30">#: community.data.getFormattedDate( modifiedDate)  #</td>
		<td class="g-px-30">
			<div class="d-flex align-items-center g-line-height-1">
				<a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover g-mr-15 k-edit-button" href="\#!" data-object-id="#= categoryId #" >
					<i class="community-admin-pencil g-font-size-18"></i>
                </a>
                <!--
				<a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover g-mr-15" href="\#!" data-action="edit" data-object-type="category" data-object-id="#= categoryId #" >
					<i class="community-admin-pencil g-font-size-18"></i>
                </a>
                -->
                <!--
                <a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover" href="\#!" data-action="delete" data-object-type="category" data-object-id="#= categoryId #" >
                		<i class="community-admin-trash g-font-size-18"></i>
                </a>-->
			</div>
		</td>
	</tr>
	</script>			
</body>
</html>
</#compress>