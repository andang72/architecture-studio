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
    		
	<!-- Professional Kendo UI --> 	
	<link href="<@spring.url "/css/kendo/2018.3.1017/kendo.bootstrap-v4.min.css"/>" rel="stylesheet" type="text/css" />	
	
   <!-- Bootstrap Theme CSS -->
	<link href="<@spring.url "/fonts/nanumgothic.min.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />	
    
    <link href="<@spring.url "/css/animate/animate.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/assets/vendor/icon-line-pro/style.css"/>" rel="stylesheet" type="text/css" />
	 
    <link href="<@spring.url "/css/bootstrap.theme/unify-admin/vendor/hs-admin-icons/hs-admin-icons.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/css/bootstrap.theme/unify-admin/unify-admin.css"/>" rel="stylesheet" type="text/css" />	
  	     
 	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js"/>' ></script>
 	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>

 	<!-- Application JavaScript
    		================================================== -->    	
	<script>
	var __pageId = <#if RequestParameters.pageId?? >${RequestParameters.pageId}<#else>0</#if>;
	
	require.config({
		shim : {
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
	        "community.ui.admin" 		: { "deps" :['jquery', 'jquery.cookie', 'community.ui.core', 'community.data'] },	
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
			"ace" 						: "<@spring.url "/js/ace/ace"/>"
		}
	});
	require([  "jquery", "bootstrap", "community.data", "kendo.messages.min", "community.ui.admin", "ace"], function($, kendo ) { 
	
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
			page : new community.model.Page(), 
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
				$this.loadPage(__pageId);
			},
			back : function(){
				var $this = this;
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/manage-pages" />");
				return false;
			},
			cancle : function(){
				var $this = this;
				if( $this.page.get('pageId') > 0 ){
					$this.set('editable', false );	
					getCodeEditor().setReadOnly(true);
				}else{
					$this.back();
				}		 	
			},
			edit : function(){
				var $this = this;
				console.log("edit..");
				$this.set('editable', true );	
				getCodeEditor().setReadOnly(false);
			},
			editor : {
				source : null,
				warp : true
			},
			openSecurityModal : function(){
				var $this = this;
				openSecurityModal($this);
				return false;
			},
			openPropertyModal : function(){
				var $this = this;
				openPropsModal($this);
				return false;
			},
			editTemplateContents : function(e){
				var $this = this;
				if($this.page.template != null && $this.page.template.length > 1 ){
					community.ui.progress($('.code-editor'), true);	
					community.ui.ajax( "<@spring.url "/data/api/mgmt/v1/pages/get_template_content.json" />" ,{
						data : { path: $this.page.template , pageId : $this.page.pageId },
						success : function(response){
							getCodeEditor().setValue( response.fileContent );
						}
					}).always( function () { community.ui.progress($('.code-editor'), false);
					});
				}
			},	
			editPageContents : function(e){
				var $this = this;
				if( $this.page.bodyContent.bodyText != null )
					getCodeEditor().setValue( $this.page.bodyContent.bodyText );
				else
					getCodeEditor().setValue( "" );
			},		
			saveOrUpdate : function(e){ 
				var $this = this;
				var saveOrUpdateUrl = '<@spring.url "/data/api/mgmt/v1/pages/save-or-update.json" />'; 
				if( $this.get('editor.source' ) == 'page' ){
					if( getCodeEditor().getValue().length > 0 || $this.page.bodyContent.bodyText != null ){
						console.log('update contents');
						$this.page.bodyContent.bodyText = getCodeEditor().getValue();
						saveOrUpdateUrl = saveOrUpdateUrl + '?fields=bodyContent';
					}
				}
				community.ui.progress($('#features'), true);	
				community.ui.ajax( saveOrUpdateUrl, {
					data: community.ui.stringify($this.page),
					contentType : "application/json",
					success : function(response){
						$this.setSource( new community.model.Page( response.data.item ) );
					}
				}).always( function () {
					community.ui.progress($('#features'), false); 
				});							
			},					
			setSource : function( data ){
				var $this = this;		
				console.log( community.ui.stringify(data) );		
				if( data.get('pageId') > 0 ){
					data.copy( $this.page );
					$this.set('editable', false );
					getCodeEditor().setReadOnly(true);
					$this.set('isNew', false );
				}else{
					$this.set('editable', true );	
					$this.set('isNew', true );
					getCodeEditor().setReadOnly(false);
				}
				$this.set('formatedCreationDate' , community.data.getFormattedDate( $this.page.creationDate) );
				$this.set('formatedModifiedDate' , community.data.getFormattedDate( $this.page.modifiedDate) ); 
				if( !$this.get('visible') ) 
					$this.set('visible' , true );
			},
			loadPage : function(pageId){
				var $this = this;		
				if( pageId > 0 ){
					community.ui.progress($('#features'), true);	
					community.ui.ajax('<@spring.url "/data/api/mgmt/v1/pages/"/>' + pageId + '/get.json?content=true', {
						success: function(data){	
							$this.setSource( new community.model.Page(data) );
						}	
					}).always( function () {
						community.ui.progress($('#features'), false);
					});	
				}else{
					$this.setSource( new community.model.Page() );
				}	

			} 
		});
		observable.bind("change", function(e) {
			if( e.field === 'editor.source' ){
		    	if(observable.get('editor.source') === 'template'){
		    		observable.editTemplateContents();
		    	}
		    	if(observable.get('editor.source') === 'page'){
		    		observable.editPageContents();
		    	}
		    }else if ( e.field === 'editor.warp' ){
		    	console.log(observable.get('editor.warp'));
		    	getCodeEditor().getSession().setUseWrapMode(observable.get('editor.warp'));
		    }
		});
		
		community.ui.bind( $('#js-header') , observable );        
		
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	    
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	  
	     
		var renderTo = $('#features');
		community.ui.bind( renderTo , observable );
		
		createCodeEditor(observable);
		
	});
	
	function getCodeEditor(){
		var renderTo = $("#htmleditor");
		return ace.edit(renderTo.attr("id"))
	}
	
	function createCodeEditor( observable ){
		var renderTo = $("#htmleditor");
		if( renderTo.contents().length == 0 ){ 
			var editor = ace.edit(renderTo.attr("id"));		
			editor.getSession().setMode("ace/mode/ftl");
			editor.getSession().setUseWrapMode(observable.get('editor.warp'));
		}
	}
	function openPropsModal(observable){
		var renderTo = $('#pages-props-modal');
		if( !renderTo.data("model") ){ 
			var listview = community.ui.listview( $('#pages-props-listview'), {
				dataSource : community.ui.datasource_v2({
					transport: { 
						read : 		{ url:'<@spring.url "/data/api/mgmt/v1/pages/"/>'+  observable.page.get('pageId') + '/properties/list.json',   type:'post', contentType : "application/json" },
						create : 	{ url:'<@spring.url "/data/api/mgmt/v1/pages/"/>'+  observable.page.get('pageId') + '/properties/update.json', type:'post', contentType : "application/json" },
						update : 	{ url:'<@spring.url "/data/api/mgmt/v1/pages/"/>'+  observable.page.get('pageId') + '/properties/update.json', type:'post', contentType : "application/json" },
						destroy : 	{ url:'<@spring.url "/data/api/mgmt/v1/pages/"/>'+  observable.page.get('pageId') + '/properties/delete.json', type:'post', contentType : "application/json" },
						parameterMap: function (options, operation){	 
							if (operation !== "read" && options.models) { 
								return community.ui.stringify(options.models);
							}
						}
					},
					batch: true, 
					schema: {
						model: community.model.Property
					}						
				}),
				dataBound: function() {
					if( this.items().length == 0)
						$('#pages-props-listview').html('<tr class="g-height-50"><td colspan="3" class="align-middle g-font-weight-300 g-color-black text-center">조건에 해당하는 데이터가 없습니다.</td></tr>');
				},				
				template: community.ui.template($("#property-template").html()),
				editTemplate: community.ui.template($("#property-edit-template").html())
			}); 
			console.log('creating properties listview: ' + listview ); 
			// fix for k-widget css problems.	
			$('#pages-props-listview').removeClass('k-widget');
			
			var models = new community.ui.observable({ 	
				create : function(){
					listview.add();
					return false;
				},
				setSource : function(){	
				
				}
			});
			renderTo.data("model", models );
			community.ui.bind(renderTo, models );
		}
		renderTo.data("model").setSource(observable);
		renderTo.modal('show');
	}
	
	function openSecurityModal(observable){
		var renderTo = $('#pages-security-modal');
		if( !renderTo.data("model") ){
			console.log('creating permission acl listview.');
			var listview = community.ui.listview( $('#pages-perms-listview'), {
				dataSource : community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/security/permissions/14/"/>'+ observable.page.get('pageId') +'/list.json' , {
					schema: {
						total: "totalCount",
						data: "items",
						model: community.model.ObjectAccessControlEntry
					}
				}),	
				template: community.ui.template($("#perms-template").html()),
				dataBound: function() {
					if( this.items().length == 0)
						$('#pages-perms-listview').html('<tr class="g-height-50"><td colspan="4" class="align-middle g-font-weight-300 g-color-black text-center">조건에 해당하는 데이터가 없습니다.</td></tr>');
				}
			}); 
			
			$('#pages-perms-listview').removeClass('k-widget');
			
			var models = new community.ui.observable({ 	
				permissionToType : "",  
				enabledSelectRole : false,
				permissionToDisabled	: true,	
				enabledSelectRole : false,			
				accessControlEntry: new community.model.ObjectAccessControlEntry(),
				rolesDataSource: community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/security/roles/list.json" />' , {
					schema: {
						total: "totalCount",
						data: "items"
					}
				}),
				permsDataSource: community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/security/permissions/list.json" />' , {
					schema: {
						total: "totalCount",
						data: "items"
					}
				}),
				addPermission : function (e){
					var $this = this;
					if( $this.accessControlEntry.get('grantedAuthorityOwner').length > 0  && $this.accessControlEntry.get('permission').length > 0 ){
						community.ui.progress(renderTo, true);	
						community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/security/permissions/14/" />' + observable.page.get('pageId') +'/add.json' , {
							data: community.ui.stringify($this.accessControlEntry),
							contentType : "application/json",
							success : function(response){
								listview.dataSource.read();
							}
						}).always( function () {
							community.ui.progress(renderTo, false);
						});							
						$this.resetAccessControlEntry();
					}
					return false;
				},
				removePermission : function (data) {
					var $this = this;
					community.ui.progress(renderTo, true);	
					community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/security/permissions/14/" />' + observable.page.get('pageId') +'/remove.json', {
						data:community.ui.stringify(data),
						contentType : "application/json",
						success : function(response){
							listview.dataSource.read();
						}
					}).always( function () {
						community.ui.progress(renderTo, false);
					});	
					return false;	
				},
				setSource : function(){
 			
				},
				resetAccessControlEntry : function(e){
					var $this = this;
					$this.set('permissionToType', 'user');
					$this.set('permissionToDisabled' , false);
					$this.set('enabledSelectRole', false);
					$this.accessControlEntry.set('id' , 0);	
					$this.accessControlEntry.set('grantedAuthority' , "USER");					
					$this.accessControlEntry.set('grantedAuthorityOwner' , "");			
					$this.accessControlEntry.set('permission' , "");		
					$this.accessControlEntry.set('domainObjectId' , observable.page.pageId);					
				},
			}); 
			models.bind("change", function(e){						
				if( e.field == "permissionToType" ){
					if( this.get(e.field) == 'anonymous'){
						models.set('permissionToDisabled', true);
						models.set('enabledSelectRole', false);
						models.accessControlEntry.set('grantedAuthority', "USER");
						models.accessControlEntry.set('grantedAuthorityOwner', "ANONYMOUS");
					}else if (this.get(e.field) == 'role'){
						models.set('permissionToDisabled', false);
						models.set('enabledSelectRole', true);						
						models.accessControlEntry.set('grantedAuthority', "ROLE");
						models.accessControlEntry.set('grantedAuthorityOwner', "");
					}else{
						models.set('enabledSelectRole', false);
					 	models.set('permissionToDisabled', false);	
					 	models.accessControlEntry.set('grantedAuthority', "USER");
						models.accessControlEntry.set('grantedAuthorityOwner', "");
					}					
				}
        		}); 			
			renderTo.data("model", models );
			community.ui.bind(renderTo, models );
		}
		renderTo.data("model").setSource(observable);
		renderTo.modal('show');
	}
	
	</script>
	<style>
	#htmleditor {
		min-height:577px;
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
						<span class="g-valign-middle">페이지</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">페이지 관리</h1>
				<!-- Content Body -->
				<div id="features" class="container-fluid" data-bind="visible:visible" style="display:none;" >
					<div class="row g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
						<div class="col-12 g-mb-20">
							<div class="media-md align-items-center g-mb-30">
		              			<div class="d-flex g-mb-15 g-mb-0--md">
									<header class="g-mb-10">
						            	<div class="u-heading-v6-2 text-uppercase" >
						              <h2 class="h4 u-heading-v6__title g-font-weight-300" data-bind="text:page.name"></h2>
						            	</div>
						            	<div class="g-pl-90">
						              <p data-bind="text:page.title"></p>
						            	</div>
						          	</header>		                				
		             	 		</div>	
								<div class="media d-md-flex align-items-center ml-auto">
					                <a class="d-flex align-items-center u-link-v5 g-color-lightblue-v3 g-color-primary--hover g-ml-15 g-ml-45--md" href="#!" data-bind="click:back">
					                  	<i class="community-admin-angle-left g-font-size-18"></i>
					                 	<span class="g-hidden-sm-down g-ml-10">뒤로가기</span>
					                </a>			
					                <a class="d-flex align-items-center u-link-v5 g-color-lightblue-v3 g-color-primary--hover g-ml-15 g-ml-45--md" href="#!" data-action="refresh" data-object-type="menu" data-object-id="0" data-bind="invisible:isNew" style="display:none;" >
					                  	<i class="community-admin-reload g-font-size-18"></i>
					                 	<span class="g-hidden-sm-down g-ml-10">새로고침</span>
					                </a>
								</div>
		            			</div>
	                  	</div>					
					</div>
					<div class="row">
						<div class="col-lg-9 g-mt-20 g-mb-10">
							<div class="form-group g-mb-30">
	                    			<label class="g-mb-10 g-font-weight-600" for="input-page-name">이름 <span class="text-danger">*</span></label>
		                    		<div class="g-pos-rel">
			                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
				                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
				                		</span>
		                      		<input id="input-page-name" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="파일명을 입력하세요" data-bind="value: page.name, enabled:editable" autofocus>
		                    			<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">
		                    			이 페이지를 호출할때 사용되는 이름입니다. ex) /display/pages/<span data-bind="text: page.name"></span> 
		                    			</small>
		                    		</div>
	                  		</div>
							<div class="form-group g-mb-30">
	                    			<label class="g-mb-10 g-font-weight-600" for="input-page-name">패턴</label>
		                    		<div class="g-pos-rel">
			                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
				                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
				                		</span>
		                      		<input id="input-page-name" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="패턴을 입력하세요" data-bind="value: page.pattern, enabled:editable">
		                    			<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">
		                    			패턴을 기반으로 페이지를 호출합니다. ex) /display/pages<span data-bind="text: page.pattern"></span> 
		                    			</small>
		                    		</div>
	                  		</div>	                  		
 							<div class="form-group">
	                    			<label class="g-mb-10 g-font-weight-600" for="input-page-title">페이지 타이틀 <span class="text-danger">*</span></label>
		                    		<div class="g-pos-rel">
			                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
				                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
				                		</span>
		                      		<input id="input-page-title" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="파일명을 입력하세요" placeholder="페이지 타이틀을 입력하세요." data-bind="value: page.title, enabled:editable">
		                    			<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">페이지를 제목으로 사용되는 이름입니다.</small>
		                    		</div>
	                  		</div>  
							<div class="form-group">
			                   	<label class="g-mb-10 g-font-weight-600" for="input-page-description">설명</label>			
			                    	<textarea id="input-page-description" class="form-control form-control-md g-resize-none g-rounded-4" rows="3" placeholder="간략하게 페이지에 대한 설명을 입력하세요." data-bind="value:page.description, enabled:editable"></textarea>
							</div>	                  		          	                  		          
 							<div class="form-group">
	                    			<label class="g-mb-10 g-font-weight-600" for="input-page-template">템플릿 <span class="text-danger">*</span></label>
		                    		<div class="g-pos-rel">
			                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
				                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
				                		</span>
		                      		<input id="input-page-template" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="템플릿으로 사용할 파일 경로를 입력하세요" data-bind="value: page.template, enabled:editable">
		                    		</div>
	                  		</div> 
	 						<div class="form-group">
	                    			<label class="g-mb-10 g-font-weight-600" for="input-page-template">서버 스크립트<span class="text-danger">*</span></label>
		                    		<div class="g-pos-rel">
			                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
				                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
				                		</span>
		                      		<input id="input-page-script" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="서버 스크립트 파일 경로를 입력하세요" data-bind="value: page.script, enabled:editable">
		                    		</div>
	                  		</div> 
	                  		<!-- EDITOR START-->
									<div class="card g-brd-gray-light-v7 g-rounded-3 g-brd-top-1 g-mb-30">
					                  <header class="card-header g-bg-transparent g-brd-gray-light-v7 g-px-15 g-px-30--sm g-pt-15 g-pt-20--sm g-pb-10 g-pb-15--sm">
					 					<div class="media">
					 						<a href="#!" class="btn u-btn-outline-darkgray g-mr-5 g-mb-0" data-bind="click:editTemplateContents">템플릿 파일 읽기</a>
					 						 
							 				<div class="btn-group btn-group-toggle btn-group-xs" data-toggle="buttons">
											  <label class="btn u-btn-outline-blue">
											    <input type="radio" name="options-contents" value="template" autocomplete="off" data-bind="checked: editor.source" > 템플릿
											  </label>
											  <label class="btn u-btn-outline-blue">
											    <input type="radio" name="options-contents" value="page"  autocomplete="off" data-bind="checked: editor.source"> 콘텐츠
											  </label>
											</div>                  
					                      	<div class="media-body d-flex justify-content-end">      
												<h3 class="d-flex align-self-center text-uppercase g-font-size-12 g-font-size-default--md g-color-black g-mr-10 g-mt-5 g-mb-0 g-width-300">                      
							                      	<label class="d-flex align-items-center justify-content-between g-mb-0">
														<span class="g-pr-20 g-font-weight-300">에디터 줄바꿈 설정/해지</span>
														<div class="u-check">
															<input class="g-hidden-xs-up g-pos-abs g-top-0 g-right-0" name="useWarp" value="true" data-bind="checked: editor.warp" type="checkbox">
															<div class="u-check-icon-radio-v8">
																<i class="fa" data-check-icon=""></i>
															</div>
														</div>
													</label>
						                      	</h3>
					                      	</div>
					                    </div>                  
					                  </header>
					                  <div class="card-block code-editor g-pa-0" >
					              		<div id="htmleditor"></div>	                                                         
					                  </div>
					                </div>
	                  		<!-- EDITOR END -->
						</div>
						<div class="g-brd-left--lg g-brd-gray-light-v4 col-md-3 g-mb-10 g-mb-0--md">
							<section class="g-mb-10 g-mt-20">							
								<div class="g-brd-around g-brd-gray-light-v7 g-rounded-4 g-pa-15 g-mb-15">
									<div class="form-group">
			                    			<label class="g-mb-10 g-font-weight-600">버전</label>
				                    		<div class="g-pos-rel">
					                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
						                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
						                		</span>
				                      		<input class="form-control" data-role="numerictextbox" placeholder="버전" data-min="0" data-max="100" data-bind="value: page.versionId, enabled:editable"  style="width: 100%"/>
				                    		</div>
			                  		</div>  
									<div class="form-group">
			                    			<label class="g-mb-10 g-font-weight-600">상태</label>
				                    		<div class="g-pos-rel">
					                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
						                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
						                		</span>
											<select class="form-control g-pos-rel" data-role="dropdownlist" data-bind="value: page.pageState, enabled:editable" style="width: 100%">
											  <option value="INCOMPLETE">INCOMPLETE</option>
											  <option value="APPROVAL">APPROVAL</option>
											  <option value="PUBLISHED">PUBLISHED</option>
											  <option value="REJECTED">REJECTED</option>
											  <option value="ARCHIVED">ARCHIVED</option>
											  <option value="DELETED">DELETED</option>
											  <option value="NONE">NONE</option>
											</select>
				                    			<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">PUBLISHED 상태인 경우에 페이지가 게시됩니다.</small>
				                    		</div>
			                  		</div> 								  
								</div>											
							
			 					<div class="media g-mb-20">
			                        <div class="d-flex align-self-center">
			                          <img class="g-width-36 g-height-36 rounded-circle g-mr-15" data-bind="attr:{ src: userAvatarSrc }" src="<@spring.url "/images/no-avatar.png"/>" alt="Image description">
			                        </div>
			                        <div class="media-body align-self-center text-left" data-bind="text:userDisplayName"></div>
								</div> 
								<p>
								생성일 : <span class="g-color-gray-dark-v4 " data-bind="text: formatedCreationDate"> </span>
								</p>
								<p data-bind="invisible:isNew" >
								수정일 : <span class="g-color-gray-dark-v4" data-bind="text: formatedModifiedDate"> </span>
								</p>							
								<button class="btn u-btn-outline-blue g-mr-10 g-mb-15" type="button" role="button" data-bind="click:edit, invisible:editable">수정</button>
								<button class="btn u-btn-outline-darkgray g-mr-5 g-mb-15" type="button" role="button" data-bind="click:cancle, visible:editable" style="display:none;">최소</button>
								<button class="btn u-btn-outline-blue g-mr-10 g-mb-15" type="button" role="button" data-bind="click:saveOrUpdate, visible:editable" style="display:none;">확인</button>
							</section>
							<!-- options setting -->
							<section data-bind="invisible:isNew">
                    				<ul class="list-unstyled mb-0">
		                      		<li class="g-brd-top g-brd-gray-light-v7 mb-0 ms-hover">
		                        			<a class="d-flex align-items-center u-link-v5 g-parent g-py-15" href="#!" data-bind="click:openPropertyModal" >
		                          			<span class="g-font-size-18 g-color-gray-light-v6 g-color-lightred-v3--parent-hover g-color-lightred-v3--parent-active g-mr-15">
												<i class="community-admin-view-list-alt"></i>
											</span>
		                          			<span class="g-color-gray-dark-v6 g-color-lightred-v3--parent-hover g-color-lightred-v3--parent-active">속성</span>
		                       			</a>
		                      		</li>
		                      		<li class="g-brd-top g-brd-gray-light-v7 mb-0 ms-hover">
		                        			<a class="d-flex align-items-center u-link-v5 g-parent g-py-15" href="#!" data-bind="click:openSecurityModal">
		                          			<span class="g-font-size-18 g-color-gray-light-v6 g-color-lightred-v3--parent-hover g-color-lightred-v3--parent-active g-mr-15">
												
												<i class="community-admin-lock"></i>
											</span>
		                          			<span class="g-color-gray-dark-v6 g-color-lightred-v3--parent-hover g-color-lightred-v3--parent-active">접근 권한 설정</span>
		                       			</a>
		                      		</li>                      
		                    		</ul>
		                  	</section>	
		                  	<!-- options setting end -->						
						</div>		
					</div>												
					<div class="row"> 
						<div id="items-treelist"></div>
						<!-- menu listview -->
						<div class="table-responsive g-mb-0" style="display:none;">						
						<table class="table u-table--v3 g-color-black">
							<thead>
								<tr class="g-bg-gray-light-v8">
									<th class="g-valign-middle g-width-100 g-px-30 sorting" data-kind="menu" data-action="sort" data-dir="asc" data-field="MENU_ITEM_ID" >
										<div class="media">
											<div class="d-flex align-self-center">ID.</div>
											<div class="d-flex align-self-center ml-auto">
												<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
												<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
												<i class="community-admin-angle-up"></i>
												</a>
												<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
												<i class="community-admin-angle-down"></i>
												</a>
												</span>
											</div>
										</div>	
									</th>
									<th class="g-valign-middle g-width-100" > 부모 ID </th>
									<th class="g-valign-middle g-px-30 g-width-300 sorting" data-kind="menu" data-action="sort" data-dir="asc" data-field="NAME">
										<div class="media">
											<div class="d-flex align-self-center">이름</div>
											<div class="d-flex align-self-center ml-auto">
												<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
														<i class="community-admin-angle-up"></i>
													</a>
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
														<i class="community-admin-angle-down"></i>
													</a>
												</span>
											</div>
										</div>
									</th>
									<th class="g-valign-middle g-px-30" > 설명 </th>
									<th class="g-valign-middle g-px-30 g-width-150 sorting" data-kind="menu" data-action="sort" data-dir="asc" data-field="CREATION_DATE">
										<div class="media">
											<div class="d-flex align-self-center">생성일</div>
											<div class="d-flex align-self-center ml-auto">
												<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
												<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
												<i class="community-admin-angle-up"></i>
												</a>
												<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
												<i class="community-admin-angle-down"></i>
												</a>
												</span>
											</div>
										</div>
									</th>
									<th class="g-valign-middle g-px-30 g-width-150 sorting" data-kind="menu" data-action="sort" data-dir="asc" data-field="MODIFIED_DATE">
										<div class="media">
											<div class="d-flex align-self-center">수정일</div>
											<div class="d-flex align-self-center ml-auto">
												<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
												<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
												<i class="community-admin-angle-up"></i>
												</a>
												<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
												<i class="community-admin-angle-down"></i>
												</a>
												</span>
											</div>
										</div>
									</th>
									<th class="g-valign-middle g-px-30 g-width-100"></th>	
								</tr>	
							</thead>
							<tbody id="items-listview" class="u-listview g-brd-none">
							</tbody>
						</table>
						</div>					
						<div id="items-listview-pager" class="g-brd-top-none" style="width:100%;"></div>
            				<!-- menu listview end -->
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
	<!-- editor modal -->
	<div class="modal fade" id="pages-props-modal" tabindex="-1" role="dialog" aria-labelledby="pages-props-modal-labal" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">				
				<div class="modal-header">
					<h2 class="modal-title">속성 변경</h2>
			        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
			          	<i aria-hidden="true" class="icon-svg icon-svg-sm icon-svg-ios-close m-t-xs"></i>
			        </button> 
			    </div><!-- /.modal-header -->
				<div class="modal-body">		    		

					<!-- .alert -->
							<div class="alert alert-dismissible fade show g-bg-gray-dark-v2 g-color-white rounded-0" role="alert">
								<button type="button" class="close u-alert-close--light" data-dismiss="alert" aria-label="Close">
                          			<span class="g-color-white" aria-hidden="true">×</span>
                        			</button>
                        			<div class="media">
									<span class="d-flex g-mr-10 g-mt-5"><i class="icon-question g-font-size-25"></i></span>
                          			<span class="media-body align-self-center">
                            			<strong>주의!</strong> 속성값은 임의로 수정하거나 추가하는 경우 오류의 원인이 될 수 있습니다.
                          			</span>
                        			</div>
							</div>  
					<!-- /.alert -->		
															
					<div class="media g-mb-20">
              			<div class="d-flex align-self-center align-items-center">	
						</div>
              			<div class="media-body align-self-center g-ml-10 g-ml-0--md">
                				<div class="input-group g-pos-rel g-max-width-170 float-right">
                  				<a href="#!" class="btn btn-md u-btn-3d u-btn-pink g-mr-10 g-mb-15" data-bind="click:create">새로운 프로퍼티 생성</a>
                				</div>
              			</div>
            			</div>
					<!-- properties listview -->						
					<div class="table-responsive">
						<table class="table w-100 g-mb-25">
							<thead class="g-hidden-sm-down g-color-gray-dark-v6">
								<tr>
									<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black">이름</th>
									<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black">값</th>
									<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-color-black g-width-120">&nbsp;</th>
								</tr>
							</thead>
							<tbody id="pages-props-listview" data-object-id="0">
							</tbody>
						</table>
					</div>
					<!-- ./properties listview -->	 	
				</div><!-- /.modal-body -->	     
		      	<!-- .modal-footer -->	
		      	<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-dismiss="modal">확인</button>
				</div> <!-- /.modal-footer -->					 	
		    </div>
		    <!-- /.modal-content -->
		</div>
	</div>			
	<div class="modal fade" id="pages-security-modal" tabindex="-1" role="dialog" aria-labelledby="pages-security-modal-labal" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">	
		      	<div class="modal-header">
		      		<h2 class="modal-title">접근권한설정</h2>
			        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
			          	<i aria-hidden="true" class="icon-svg icon-svg-sm icon-svg-ios-close m-t-xs"></i>
			        </button>
		      	</div><!-- /.modal-header -->		      	
		    		<div class="modal-body">		
					<!-- .alert -->
					<div class="alert alert-dismissible fade show g-bg-gray-dark-v2 g-color-white rounded-0" role="alert">
						<button type="button" class="close u-alert-close--light" data-dismiss="alert" aria-label="Close">
							<span class="g-color-white" aria-hidden="true">×</span>
						</button>
						<div class="media">
							<span class="d-flex g-mr-10 g-mt-5"><i class="icon-question g-font-size-25"></i></span>
							<span class="media-body align-self-center">
								<strong>주의!</strong> 페이지 접근제어 사용 상태가 ON 경우에 부여된 권한에 따라 페이지 접근제어가 적용됩니다.
							</span>
						</div>
					</div>  
					<!-- /.alert -->		
            			<div class="g-ma-20"> 			    		 
						<div class="form-group">
		                    <label class="d-flex align-items-center justify-content-between">
		                      <span>페이지 접근제한 활성화</span>
		                      <div class="u-check">
		                        <input class="g-hidden-xs-up g-pos-abs g-top-0 g-right-0" name="pages-options-acl-enabled" checked="" type="checkbox">
		                        <div class="u-check-icon-radio-v8">
		                          <i class="fa" data-check-icon=""></i>
		                        </div>
		                      </div>
		                    </label>
		                  </div>
	                  </div>
					 					<!-- permission listview -->						
										<div class="g-mt-20"> 							
											<table class="table w-100 g-mb-25">
												<thead class="g-hidden-sm-down g-color-gray-dark-v6">
													<tr>
														<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-width-150 ">유형</th>
														<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-width-150">대상</th>
														<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-min-width-150">권한</th>
														<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-width-150">&nbsp;</th>
													</tr>
												</thead>
												<tbody id="pages-perms-listview" class="g-font-size-default g-color-black g-brd-0"></tbody>
											</table>
										</div>
										<!-- ./permission listview -->	         
										
										                            
		                                	<p>익명사용자, 특정회원 또는 롤에 게시판에 대한 권한을 부여할 수 있습니다. 먼저 권한를 부여할 대상을 선택하세요. 마지막으로 권한추가를 클릭하면 권한이 부여됩니다.</p>
		                                	<div class="g-mb-15">
					                    <label class="form-check-inline u-check g-pl-25 ml-0 g-mr-25">
					                      <input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" name="permissionToType" checked="" value="anonymous" type="radio" data-bind="checked: permissionToType">
					                      <div class="u-check-icon-radio-v4 g-absolute-centered--y g-left-0 g-width-18 g-height-18">
					                        <i class="g-absolute-centered d-block g-width-10 g-height-10 g-bg-primary--checked"></i>
					                      </div>
					                      익명
					                    </label>
					
					                    <label class="form-check-inline u-check g-pl-25 ml-0 g-mr-25">
					                      <input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" name="permissionToType" type="radio" value="user" data-bind="checked: permissionToType">
					                      <div class="u-check-icon-radio-v4 g-absolute-centered--y g-left-0 g-width-18 g-height-18">
					                        <i class="g-absolute-centered d-block g-width-10 g-height-10 g-bg-primary--checked"></i>
					                      </div>
					                      회원
					                    </label>
					
					                    <label class="form-check-inline u-check g-pl-25 ml-0 g-mr-25">
					                      <input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" name="permissionToType" type="radio" value="role" data-bind="checked: permissionToType">
					                      <div class="u-check-icon-radio-v4 g-absolute-centered--y g-left-0 g-width-18 g-height-18">
					                        <i class="g-absolute-centered d-block g-width-10 g-height-10 g-bg-primary--checked"></i>
					                      </div>
					                      롤
					                    </label>
		
					                  </div>
					<div class="row">
						<div class="col">
							<input data-role="dropdownlist"
												 data-option-label="롤을 선택하세요."
								                 data-auto-bind="false"
								                 data-text-field="name"
								                 data-value-field="name"
								                 data-bind="value: accessControlEntry.grantedAuthorityOwner, source: rolesDataSource, enabled: enabledSelectRole, visible:enabledSelectRole"
								                 style="width: 100%;" />
								               	
							<input type="text" class="form-control" placeholder="권한을 부여할 사용자 아이디(username)을 입력하세요" data-bind="value: accessControlEntry.grantedAuthorityOwner , disabled: permissionToDisabled, invisible:enabledSelectRole">  
						</div>
						<div class="col">
							<input data-role="dropdownlist"
												 data-option-label="권한을 선택하세요."
								                 data-auto-bind="false"
								                 data-text-field="name"
								                 data-value-field="name"
								                 data-bind="value: accessControlEntry.permission, source: permsDataSource"
								                 style="width: 100%;" />
						</div>
					</div>
					<div class="d-flex g-mt-20">
						<a href="#!" class="btn u-btn-outline-darkgray g-mr-10 g-mb-15" data-bind="click:addPermission">권한 추가</a>
                    </div>      	
		      	</div>	
		      	<!-- .modal-footer -->	
		      	<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-dismiss="modal">확인</button>
					<!--<button type="button" class="btn btn-primary" data-bind="{ click: saveOrUpdate }">확인</button>-->
				</div> <!-- /.modal-footer -->	      	
		    </div>
		    <!-- /.modal-content -->
		</div>
	</div>		
	<script type="text/x-kendo-template" id="perms-template">    	 	
	<tr>
		<td class="align-middle text-nowrap g-width-150" >
			#: grantedAuthority #
		</td>
		<td class="align-middle ">
			<div class="d-inline-block">
				<span class="d-flex align-items-center justify-content-center u-tags-v1 g-brd-around g-bg-gray-light-v8 g-brd-gray-light-v8 g-font-size-default g-color-gray-dark-v6 g-rounded-50 g-py-4 g-px-15">
					<span class="u-badge-v2--md g-pos-stc g-transform-origin--top-left g-bg-lightblue-v3 g-mr-8"></span>
					#: grantedAuthorityOwner #
				</span>
            </div>		
		</td>
		<td class="align-middle g-width-150">			
			<span class="u-tags-v1 text-center g-width-110 g-brd-around g-brd-teal-v2 g-bg-teal-v2 g-font-weight-400 g-color-white g-rounded-50 g-py-4 g-px-15">#: permission #</span>
		</td>
		<td class="align-middle text-nowrap text-center g-width-150">
			<a class="g-color-gray-dark-v5 g-text-underline--none--hover g-pa-5" href="\\#!" data-toggle="tooltip" data-placement="top" data-original-title="Delete" data-subject="permission" data-action="delete" data-object-id="#= id #">
				<i class="community-admin-trash g-font-size-18"></i>
			</a>
		</td>
	</tr>			                      
    </script>    
    		
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
					<i class="community-admin-pencil g-font-size-18"></i>
                </a> 
			</div>
		</td>
	</tr>
	</script>

	<!-- porperties template -->
	<script type="text/x-kendo-template" id="property-template">   
	<tr>
		<td class="align-middle">#: name # </td>
		<td class="align-middle">#: value #</td>
		<td class="align-middle text-center">
			<div class="btn-group">
                <a class="btn btn-sm u-btn-outline-bluegray k-edit-button" href="\\#">수정</a>
                <a class="btn btn-sm u-btn-outline-bluegray k-delete-button" href="\\#">삭제</a>
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
			<a class="btn btn-sm u-btn-outline-bluegray k-update-button" href="\\#">확인</a>
            <a class="btn btn-sm u-btn-outline-bluegray k-cancel-button" href="\\#">취소</a>
		</td>
	</td>
	</script>								
</body>
</html>
</#compress>