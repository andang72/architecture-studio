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
	        "jquery.slimscroll.min" 	: { "deps" :['jquery'] },
			<!-- community -- >
	        "community.ui.core"			: { "deps" :['jquery', 'kendo.web.min', 'kendo.culture.min' ] },
	        "community.data" 			: { "deps" :['jquery', 'kendo.web.min', 'community.ui.core' ] },
	        "community.ui.admin" 		: { "deps" :['jquery', 'jquery.cookie', 'community.ui.core', 'community.data'] }	    
		},
		paths : {
			"jquery"    					: "<@spring.url "/js/jquery/jquery-3.1.1.min"/>",
			"jquery.cookie"    				: "<@spring.url "/js/jquery.cookie/1.4.1/jquery.cookie"/>",
			"bootstrap" 				: "<@spring.url "/js/bootstrap/4.0.0/bootstrap.bundle.min"/>",
			
			<!-- Professional Kendo UI --> 
			"kendo.web.min"	 			: "<@spring.url "/js/kendo/2018.3.1017/kendo.web.min"/>",
			"kendo.culture.min"			: "<@spring.url "/js/kendo/2018.3.1017/cultures/kendo.culture.ko-KR.min"/>",	
			"kendo.messages.min"		: "<@spring.url "/js/kendo.extension/kendo.messages.ko-KR"/>",	
			
			<!-- community -- >
			"community.ui.core" 		: "<@spring.url "/js/community.ui/community.ui.core"/>",
			"community.data" 			: "<@spring.url "/js/community.ui/community.data"/>",   						
			"community.ui.admin" 		: "<@spring.url "/js/community.ui/community.ui.admin"/>", 
			"ace" 						 : "<@spring.url "/js/ace/ace"/>",
			"jquery.slimscroll.min" 	: "<@spring.url "/js/jquery.slimscroll/1.3.8/jquery.slimscroll.min"/>"	
		}
	});
	require([ "jquery", "bootstrap", "community.data", "kendo.messages.min", "community.ui.admin", "jquery.slimscroll.min", "ace" ], function($, kendo ) { 
	
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
			userAvatarSrc : "<@spring.url "/images/no-avatar.png"/>",
			userDisplayName : "",
			
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
			},
			editable : false,
			source : new community.data.model.FileInfo(),
			openScriptCreateWindow : function(){
				createScriptCreateWindow(this);
				return false;
			},
			setSource : function(data){
				var $this = this;
				var editor = ace.edit("htmleditor");	
				data.copy( observable.source );
				setResourceContent(observable.source, function(response){ 
					editor.setValue( response.fileContent);
					observable.set('editable', true);
				});
			}
		});
		
		var renderTo = $('#features');
		community.ui.bind( renderTo , observable );
		
		createScriptTreeView(observable)
		
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	   
	 	
	});
	
	function createScriptTreeView(observable){
		var renderTo = $('#treeview');
		if( !community.ui.exists( renderTo ) ){   
		
			var editor = ace.edit("htmleditor");		
			editor.getSession().setMode("ace/mode/java");
			editor.getSession().setUseWrapMode(true);  
					
			var treeview = renderTo.kendoTreeView({
				dataSource: new kendo.data.HierarchicalDataSource({						
					transport: {
						read: {
							url : '<@spring.url "/secure/data/mgmt/resources/SCRIPT/list.json"/>',
							dataType: "json"
						}
					},
					schema: {		
						model: {
							id: "path",
							hasChildren: "directory"
						}
					}	
					}),
					template: kendo.template($("#treeview-template").html()),
					dataTextField: "name",
					change: function(e) {
						var $this = this;
						var selectedCells = $this.select();			
						var filePlaceHolder = $this.dataItem( $this.select() );
						if(community.ui.defined( filePlaceHolder )  && !filePlaceHolder.directory){
							observable.setSource(new community.data.model.FileInfo(filePlaceHolder));
						}
					}
			}).data("kendoTreeView"); 
			renderTo.slimScroll({ height: 300, railOpacity: 0.9 }); 
		}
	}
	
	function setResourceContent( data , handler ){
		community.ui.ajax( "<@spring.url "/secure/data/mgmt/resources/SCRIPT/get.json" />" , {
			data : { path:  data.path},
				success : function(response){ 
					handler( response );
				}
			}
		); 	
	}
	
	function createScriptCreateWindow(observable){
		var renderTo = $('#window');
		if( !community.ui.exists( renderTo ) ){ 
			var models = new community.ui.observable({ 	
			
			}); 
			
			community.ui.bind(renderTo, models); 
			
			renderTo.kendoWindow({
				width: "900px",
				title: "스크립트 생성하기",
				visible: false,
				modal: true,
				actions: ["Minimize", "Maximize", "Close"],
				open: function(){
					
				},
				close: function(){
					
				}
			}); 
		}
		renderTo.data("kendoWindow").center().open();
	}
		
	</script>
	<style>
	.k-treeview .k-in.k-state-selected{ 
		border-color: #e81c62; 
		color: #e81c62;
		background-color: #fff; 
    
	}
	#htmleditor {
		min-height:1000px; 
		
	}	
	.g-width-100x {
		width : 100%;
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
						<span class="g-valign-middle">스크립트</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">스크립트 관리</h1>
				<!-- Content Body -->
				<div id="features"  class="container-fluid">
					<div class="row text-center text-uppercase g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
						<div class="col-6 text-left">
							<p class="text-danger g-font-weight-100">스크립트를 추가하여 다양한 비즈니스 로직을 구현할 수 있습니다.</p>
						</div>
						<div class="col-6 text-right">
							<a href="javascript:void();" class="btn btn-xl u-btn-3d u-btn-primary g-width-180--md g-mb-10 g-font-size-default g-ml-10" 
								data-bind="click:openScriptCreateWindow">새로운 스크립트 만들기</a>
						</div>
					</div>
					<div class="row"> 
						<!-- Unify Pink Outline Panel-->
						<div class="card  rounded-0 g-width-100x">
						  <h3 class="card-header h5  rounded-0">
						    <i class="fa fa-folder-open-o g-font-size-default g-mr-5"></i> 
						  </h3> 
						  <div class="card-block g-pa-0 g-min-height-300"> 
							<div id="treeview" style="width:100%!important;"></div> 
						  </div>
						</div>
						<!-- End Unify Pink Outline Panel-->  
					</div> 
					
					<div class="row g-brd-gray-light-v7 g-brd-top-1 g-brd-bottom-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-1">
						<div class="col-12 g-pa-20">
							<div class="media-md align-items-center">
								<div class="media">
									<div class="d-flex align-self-center">
										<img class="g-width-24 g-height-24 rounded-circle g-mr-5" data-bind="attr:{ src: userAvatarSrc }" src="<@spring.url "/images/no-avatar.png"/>" alt="Image description">
									</div>
									<div class="media-body align-self-center text-left g-font-weight-300"><span class="g-font-weight-400" data-bind="text:userDisplayName"></span> 계정으로 작업</div>
								</div>
								<div class="media d-md-flex align-items-center ml-auto"> 
								
									<a class="d-flex align-items-center u-link-v5 g-color-lightblue-v3 g-color-primary--hover g-ml-15 g-ml-45--md" href="#!" data-action="refresh" data-object-type="menu" data-object-id="0" data-bind="invisible:isNew" style="display:none;" >
										<i class="hs-admin-reload g-font-size-18"></i>
										<span class="g-hidden-sm-down g-ml-10">새로고침</span>
									</a>
									
									<button class="btn u-btn-outline-blue g-ml-15 g-ml-45--md" type="button" role="button" data-bind="visible:editable" style="display:none;">업데이트</button>
								</div>
							</div>
	                  	</div>					
					</div> 
					<div class="row" >
						<div class="col-lg-12 g-pa-0"> 
							<div id="htmleditor" class="g-brd-gray-light-v6 g-brd-top-1 g-brd-bottom-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-1 "></div> 	 
						</div>
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
	
	<div id="window" style="display:none;"> 
		<div class="row" >
			<div class="col-lg-8"> 
				<div class="k-block g-ml-15">
					<div class="k-header">스크립트 만들기</div> 
				</div> 
			</div>
			</div> 
		<div class="row" >
			<div class="col-lg-12">
				<div class="g-pa-15">
				
				</div>		 
			</div>
		</div>
	</div>
		
	<script id="treeview-template" type="text/kendo-ui-template">
	#if(item.directory){#<i class="fa fa-folder-open-o"></i> # }else{# <i class="fa fa-file-code-o"></i> #}#
	<span class="g-ml-5">#: item.name # </span>
	# if (!item.items) { #
		<a class='delete-link' href='\#'></a> 
	# } #
    </script>	
</body>
</html>
</#compress>