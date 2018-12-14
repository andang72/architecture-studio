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
 
   	 <!-- Summernote Editor CSS -->
	<link href="<@spring.url "/js/summernote/summernote.css"/>" rel="stylesheet" type="text/css" />
	 	      	     
 	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js'"/>></script>
 	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>
 	<!-- Application JavaScript
    		================================================== -->    	
	<script>
	var __userId = <#if RequestParameters.userId?? >${RequestParameters.userId}<#else>0</#if>;
	
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
	        "summernote-ko-KR" : { "deps" :['summernote.min'] }
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
			"dropzone"					: "<@spring.url "/js/dropzone/dropzone"/>",
			"summernote.min"             : "<@spring.url "/js/summernote/summernote.min"/>",
			"summernote-ko-KR"           : "<@spring.url "/js/summernote/lang/summernote-ko-KR"/>"		
		}
	});
	require([ "jquery", "bootstrap", "community.data", "kendo.messages.min", "community.ui.admin", "summernote.min", "summernote-ko-KR", "dropzone" ], function($, kendo ) { 
		
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
			visible : false,
			editable : false,
			isNew : true,
			user : new community.model.User(),
			selectedUserAvatarSrc : "/images/no-avatar.png",
			selectedUserDisplayName : "",
			formatedCreationDate : "",
			formatedModifiedDate: "",
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
			},
			back : function(){
				var $this = this;
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/manage-users" />");
				return false;
			},
			cancle : function(){
				var $this = this;
				if( $this.user.get('userId') > 0 ){
					$this.set('editable', false );	 
				}else{
					$this.back();
				}	
			},
			edit : function(e){
			 	var $this = this;
			 	$this.set('editable', true );
		 	},
		 	editUserRole : function(e){
		 		$this = this;
		 		openUserRoleModal($this);
		 		return false;
		 	},
		 	editUserProperty : function(e){
		 		$this = this;
		 		openUserPropertyModal($this);
		 		return false;
		 	},
		 	saveOrUpdate : function(e){		
		 		$this = this;		
				community.ui.progress(renderTo, true);	
				
				if( $this.user.userId == 0 ){
					$this.user.set('password', '1234');
				}
				
				community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/security/users/save-or-update.json" />', {
					data: community.ui.stringify($this.user),
					contentType : "application/json",
					success : function(response){
						
						var newUser =  new community.model.User( response.data.item ) ;
						if( $this.isNew ){
							$this.setSource( newUser );
							createAvatarDropzone($this);
						}else{
							$this.setSource( newUser );
						}
						
					}
				}).always( function () {
					community.ui.progress(renderTo, false); 
				});																
			},
			setSource : function( data ){
				var $this = this;
				if( data.get('userId') > 0 ){
					data.copy( $this.user ); 	
					$this.set('editable', false ); 
					$this.set('isNew', false );
					$this.set('selectedUserAvatarSrc', community.data.getUserProfileImage( $this.user ) );
					$this.set('selectedUserDisplayName', community.data.getUserDisplayName( $this.user ) );					
				}else{
					$this.set('editable', true );	
					$this.set('isNew', true ); 
				}
				$this.set('formatedCreationDate' , community.data.getFormattedDate( $this.user.creationDate) );
				$this.set('formatedModifiedDate' , community.data.getFormattedDate( $this.user.modifiedDate) );
				if( !$this.get('visible') ) 
					$this.set('visible' , true );
			},
			load : function(objectId){
				var $this = this;		
				if( objectId > 0 ){
					community.ui.progress($('#features'), true);	
					community.ui.ajax('<@spring.url "/data/api/mgmt/v1/security/users/"/>' + objectId + '/get.json', {
						success: function(data){	
							$this.setSource( new community.model.User(data) );
							createAvatarDropzone(observable);
						}	
					}).always( function () {
						community.ui.progress($('#features'), false);
					});	
				}else{
					$this.setSource( new community.model.User() );
				}								
			},
			refresh : function (){
				var $this = this;	
				$this.set('selectedUserAvatarSrc', community.data.getUserProfileImage( $this.user ) );
				$this.set('selectedUserDisplayName', community.data.getUserDisplayName( $this.user ) );		
			}			
		});
		
		community.ui.bind( $('#js-header') , observable );    
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	  
 
		$.getScript( "<@spring.url "/js/kendo.extension/kendo.messages.ko-KR.js"/>" , function () {
			observable.load(__userId);
		});
		  
 		var renderTo = $('#features');
		community.ui.bind( renderTo , observable );
		
	});
	
	function createAvatarDropzone(observable){
		var myDropzone = new Dropzone('#dropzoneForm', {
			url: '<@spring.url "/data/api/mgmt/v1/security/users/"/>'  + observable.user.userId + '/avatar/upload.json' ,
			paramName: 'file',
			maxFilesize: 5,
			acceptedFiles: 'image/*'	,
			previewsContainer: '#dropzoneForm .dropzone-previews'	,
			previewTemplate: '<div class="dz-preview dz-file-preview"><div class="dz-progress"><span class="dz-upload" data-dz-uploadprogress></span></div></div>'
		});
		myDropzone.on("addedfile", function(file) {
		  console.log('start');
		  community.ui.progress($('#dropzoneForm'), true);
		});
		
		myDropzone.on("complete", function() {
		  community.ui.progress($('#dropzoneForm'), false);
		  console.log('done');
		  observable.refresh();
		});			
	}
	
	/** Role Modal **/
	function openUserRoleModal(observable){
		var renderTo = $('#user-role-modal');
		if( !renderTo.data("model") ){  
			var model = new community.ui.observable({ 	
				availableUserRoleDataSource : community.ui.datasource_v2({ data: [], schema:{ model:community.model.Role}}),
				selectedUserRoleDataSource : community.ui.datasource_v2({ data: [], schema:{ model:community.model.Role} }), 
				rolesDataSource: community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/security/roles/list.json" />' , {
					schema: {
						total: "totalCount",
						data: "items",
						model: community.model.Role
					}
				}),				
				setUserRoles : function (e){
					console.log("set user roles.");
					var $this = this;					
					community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/security/users/" />' + observable.user.userId + '/roles/list.json', {
						//data: community.ui.stringify($this.user),
						contentType : "application/json",
						success : function(response){
							var roles = $this.rolesDataSource.view();							
							$this.selectedUserRoleDataSource.data( response.items );
							$this.availableUserRoleDataSource.data(roles);
							$.each( response.items , function (index, value) {
								var data = $this.availableUserRoleDataSource.get( value.roleId );
								$this.availableUserRoleDataSource.remove( data);
							} );
						}
					}).always( function () { });		
				},
				saveOrUpdate:function(e){
					var $this = this;
					community.ui.progress(renderTo.find('.modal-content'), true);	
					community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/security/users/" />' + observable.user.userId + '/roles/save-or-update.json' , {
						data: community.ui.stringify($this.selectedUserRoleDataSource.data()),
						contentType : "application/json",
						success : function(response){
							$this.setUserRoles();
						}
					}).always( function () {
						community.ui.progress(renderTo.find('.modal-content'), false);
						renderTo.modal('hide');
					}); 
				},				
				setSource : function(data){	
					var $this = this;
					$this.setUserRoles();
				}
			});
			
			model.rolesDataSource.fetch();
			renderTo.data("model", model );
			community.ui.bind(renderTo, model );
		}
		renderTo.data("model").setSource(observable);
		renderTo.modal('show');
	}			
	/** Property Modal **/
	function openUserPropertyModal(observable){
		var renderTo = $('#user-props-modal');
		if( !renderTo.data("model") ){ 
			var listview = community.ui.listview( $('#user-props-listview'), {
				dataSource : community.ui.datasource_v2({
					transport: { 
						read : 		{ url:'<@spring.url "/data/api/mgmt/v1/security/user/"/>'+  observable.user.get('userId') + '/properties/list.json',   type:'post', contentType : "application/json" },
						create : 	{ url:'<@spring.url "/data/api/mgmt/v1/security/user/"/>'+  observable.user.get('userId') + '/properties/update.json', type:'post', contentType : "application/json" },
						update : 	{ url:'<@spring.url "/data/api/mgmt/v1/security/user/"/>'+  observable.user.get('userId') + '/properties/update.json', type:'post', contentType : "application/json" },
						destroy : 	{ url:'<@spring.url "/data/api/mgmt/v1/security/user/"/>'+  observable.user.get('userId') + '/properties/delete.json', type:'post', contentType : "application/json" },
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
			$('#user-props-listview').removeClass('k-widget');
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
	</script> 	
	<style>
    .modal-body .k-listbox {
        width: 236px;
        height: 310px;
    }

    .modal-body .k-listbox:first-of-type {
            width: 270px;
            margin-right: 1px;
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
						<a class="u-link-v5 g-color-gray-dark-v6 g-color-lightblue-v3--hover g-valign-middle" href="#!">보안</a> <i class="hs-admin-angle-right g-font-size-12 g-color-gray-light-v6 g-valign-middle g-ml-10"></i>
					</li>
					<li class="list-inline-item">
						<span class="g-valign-middle">사용자</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">사용자 관리</h1>
				<!-- Content Body -->
				<div id="features" class="container-fluid" data-bind="visible:visible" style="display:none;" >
					<div class="row g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
						<div class="col-12 g-mb-20">
							<div class="media-md align-items-center g-mb-30">
		              			<div class="d-flex g-mb-15 g-mb-0--md">
									<header class="g-mb-10">
						            	<div class="u-heading-v6-2 text-uppercase" >
						              <h2 class="h4 u-heading-v6__title g-font-weight-300" data-bind="text:project.name"></h2>
						            	</div>
						            	<div class="g-pl-90">
						              <p data-bind="text:project.title"></p>
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
							<div class="form-group">
	                    		<label class="g-mb-10 g-font-weight-600" for="input-username">아이디<span class="text-danger">*</span></label>
		                    	<div class="g-pos-rel">
			                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success"><i class="community-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i></span>
		                      		<input id="input-username" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="아이디를 입력하세요" data-bind="value: user.username, enabled:editable">
		                    	</div>
	                  		</div>  
							<div class="form-group">
			                   	<label class="g-mb-10 g-font-weight-600">이름<span class="text-danger">*</span></label>	
			                	<div class="g-pos-rel">
		                      	<input class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="이름을 입력하세요" data-bind="value: user.name, enabled:editable">
		                    	</div>
			                </div>	
							<div class="form-group">
			                   	<label class="g-mb-10 g-font-weight-600">메일<span class="text-danger">*</span></label>	
			                	<div class="g-pos-rel">
			                	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success"><i class="community-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i></span>
		                      	<input class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="email" placeholder="메일주소를 입력하세요" data-bind="value: user.email, enabled:editable">
		                    	</div>
			                </div>				                	                  		 
	                  		<!-- EDITOR START-->	                  		
							<div class="card g-brd-gray-light-v7 g-rounded-3 g-mb-30">
			                  <div class="card-block g-pa-15" >
							 <div class="row g-mb-15" >
			            			<div class="col-md-6">	
										<label class="g-mb-10 g-font-weight-600">정보공개</label><br/>
										<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6">체크하면 해당 정보를 누구나 볼수 있게 됩니다.</small>				
										<div class="form-group g-mt-10 g-mb-10 g-mb-0--md">
											<label class="u-check g-pl-25">
												<input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" type="checkbox" data-bind="checked:user.nameVisible, enabled:editable">
												<div class="u-check-icon-checkbox-v4 g-absolute-centered--y g-left-0">
													<i class="fa" data-check-icon=""></i>
												</div>이름
											</label>
										</div>
										<div class="form-group g-mb-10 g-mb-0--md">							
											<label class="u-check g-pl-25">
												<input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" type="checkbox" data-bind="checked:user.emailVisible, enabled:editable">
													<div class="u-check-icon-checkbox-v4 g-absolute-centered--y g-left-0">
														<i class="fa" data-check-icon=""></i>
													</div>메일주소
											</label>
										</div>
				                    </div>             			
		                			<div class="col-md-6">
		                				<label class="g-mb-10 g-font-weight-600">상태</label>
		                				<div class="form-group g-rounded-4 mb-0">
											<select class="form-control" data-bind="value: user.status, enabled:editable" style="width: 180px">
											  <option value="NONE">NONE</option>
											  <option value="APPROVED">APPROVED</option>
											  <option value="REJECTED">REJECTED</option>
											  <option value="VALIDATED">VALIDATED</option>
											  <option value="REGISTERED">REGISTERED</option>
											</select>
		                				</div>		
		                			</div> 
			            		</div> 
			                  </div>
			                </div>	 
	                  		<!-- EDITOR END -->
						</div>
						<div class="g-brd-left--lg g-brd-gray-light-v4 col-md-3 g-mb-10 g-mb-0--md">
							<section class="g-mb-10 g-mt-20">			
								<div class="media g-mb-20">
			                        <div class="d-flex align-self-center">
			                          <img class="g-width-36 g-height-36 rounded-circle g-mr-15" data-bind="attr:{ src: userAvatarSrc }" src="/images/no-avatar.png" alt="Image description">
			                        </div>
			                        <div class="media-body align-self-center text-left" data-bind="text:userDisplayName"></div>
								</div> 
								
								<section data-bind="invisible:isNew">
								<hr class="g-brd-style-dashed"/>	
								<div class="d-inline-block g-pos-rel g-mb-30" >
			                      <a class="u-badge-v2--lg u-badge--bottom-right g-width-32 g-height-32 g-bg-lightblue-v3 g-bg-primary--hover g-mb-20 g-mr-20" href="#!">
			                        <i class="community-admin-pencil g-absolute-centered g-font-size-16 g-color-white"></i>
			                      </a>
			                      <img class="rounded-circle" data-bind="attr:{ src: selectedUserAvatarSrc }" src="/images/no-avatar.png" alt="Image description" width="100" height="100">
			                      <form action="" method="post" enctype="multipart/form-data" id="dropzoneForm" class="u-dropzone">
			                       	 <div class="dz-default dz-message">
			                       	 	<a class="u-badge-v2--lg u-badge--bottom-right g-width-32 g-height-32 g-bg-lightblue-v3 g-bg-primary--hover g-mb-20 g-mr-20" href="#!">
					                        <i class="community-admin-upload g-absolute-centered g-font-size-16 g-color-white"></i>
					                      </a>
			                       	 </div>       
		                       	 	<div class="dropzone-previews"></div>                 
									 <div class="fallback">
									     <input name="file" type="file" multiple style="display:none;"/>
									 </div>
								</form> 
			                    </div>	
	                    		</section>
	                    								
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
		                      		<!--
		                      		<li class="g-brd-top g-brd-gray-light-v7 mb-0 ms-hover">
		                        			<a class="d-flex align-items-center u-link-v5 g-parent g-py-15" href="#!" data-bind="click:editUserProperty" >
		                          			<span class="g-font-size-18 g-color-gray-light-v6 g-color-lightred-v3--parent-hover g-color-lightred-v3--parent-active g-mr-15">
												<i class="community-admin-view-list-alt"></i>
											</span>
		                          			<span class="g-color-gray-dark-v6 g-color-lightred-v3--parent-hover g-color-lightred-v3--parent-active">속성</span>
		                       			</a>
		                      		</li>
		                      		-->
		                      		<li class="g-brd-top g-brd-gray-light-v7 mb-0 ms-hover">
		                        			<a class="d-flex align-items-center u-link-v5 g-parent g-py-15" href="#!" data-bind="click:editUserRole">
		                          			<span class="g-font-size-18 g-color-gray-light-v6 g-color-lightred-v3--parent-hover g-color-lightred-v3--parent-active g-mr-15">
												
												<i class="community-admin-lock"></i>
											</span>
		                          			<span class="g-color-gray-dark-v6 g-color-lightred-v3--parent-hover g-color-lightred-v3--parent-active">권한 설정</span>
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
	<div class="modal fade" id="user-role-modal" tabindex="-1" role="dialog" aria-labelledby="user-role-modal-labal" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">				
				<div class="modal-header">
					<h2 class="modal-title">권한 변경</h2>
			        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
			          	<i aria-hidden="true" class="icon-svg icon-svg-sm icon-svg-ios-close m-t-xs"></i>
			        </button> 
			    </div><!-- /.modal-header -->
				<div class="modal-body">	 				
					<p>부여된 롤을 추가하거나 삭제할 수 있습니다.</p>
			      	<p class="text-danger">저장 버튼을 클릭해야 부여된 롤이 변경 됩니다.</p>		 			
					<div class="k-content wide">
								        		
								            <select id="listbox1" data-role="listbox" 
								            
								                data-text-field="name"
								                data-value-field="name" 
								                data-toolbar='{tools: [ "transferTo", "transferFrom", "transferAllTo", "transferAllFrom"]}'
								                data-connect-with="listbox2"
								                data-bind="source:availableUserRoleDataSource">
								            </select>
								
								            <select id="listbox2" data-role="listbox" 
								            		data-bind="source:selectedUserRoleDataSource"
								            		data-connect-with="listbox1"
								            		data-text-field="name"
								                data-value-field="name">
								            </select> 	      			 	
					</div> 			
				</div><!-- /.modal-body -->	     
		      	<!-- .modal-footer -->	
		      	<div class="modal-footer">
		      		<button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal" data-bind="click:saveOrUpdate">확인</button>
				</div> <!-- /.modal-footer -->					 	
		    </div>
		    <!-- /.modal-content -->
		</div>
	</div>	
	<div class="modal fade" id="user-props-modal" tabindex="-1" role="dialog" aria-labelledby="user-props-modal-labal" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">				
				<div class="modal-header">
					<h2 class="modal-title">속성 변경</h2>
			        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
			          	<i aria-hidden="true" class="icon-svg icon-svg-sm icon-svg-ios-close m-t-xs"></i>
			        </button> 
			    </div><!-- /.modal-header -->
				<div class="modal-body">	 				
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
							<tbody id="user-props-listview" data-object-id="0"></tbody>
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