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
	var __announceId = <#if RequestParameters.announceId?? >${RequestParameters.announceId}<#else>0</#if>;
	
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
			announce : new community.model.Announce(__announceId), 
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
				$this.load(__announceId);
			},
			back : function(){
				var $this = this;
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/manage-announces" />");
				return false;
			},
			cancle : function(){
				var $this = this;
				if( $this.announce.get('announceId') > 0 ){
					$this.set('editable', false );	
				}else{
					$this.back();
					return ;
				}
				var editorTo = $('#announce-body-editor');
			 	editorTo.summernote('destroy');	
			},
			edit : function(e){
			 	var $this = this;
			 	console.log('summernote create.');
			 	$this.set('editable', true );	
			 	var editorTo = $('#announce-body-editor');
			 	editorTo.summernote({
					placeholder: '공지내용을 입력하여 주세요.',
					dialogsInBody: false,
					height: 300,
					callbacks: {
						onImageUpload : function(files, editor, welEditable) {
				            community.data.uploadImageAndInsertLink(files[0], editorTo );
				        }
			        }
				});			 	
				editorTo.summernote('code', $this.announce.get('body'));	
		 	},
		 	saveOrUpdate : function(e){				
				var $this = this;		
						
				var validator = community.ui.validator($("#announce-edit-form"), {});								
				if (validator.validate()) {	
					var editorTo = $('#announce-body-editor');
					if( editorTo.summernote('code') == null || editorTo.summernote('code').length == 0 ){
						editorTo.summernote('focus');
						return ;
					}
					console.log("now save or update.");
					community.ui.progress($('#features'), true);						
					$this.announce.set('body', editorTo.summernote('code') );	
					community.ui.ajax( '<@spring.url "/data/api/v1/announces/save-or-update.json" />', {
						data: community.ui.stringify($this.announce),
						contentType : "application/json",						
						success : function(response){
							// do after create new announce !
							var newAnnounce = new community.model.Announce(response);
							$this.setSource( newAnnounce );
							
							var editorTo = $('#announce-body-editor');
			 				editorTo.summernote('destroy');	 
			 				
							if($this.get('isNew')){
								$this.set('isNew', false );
							}
						}
					}).always( function () {
						community.ui.progress($('#features'), false);
					});
				}					
			},
			setSource : function( data ){
				var $this = this;		
				if( data.get('announceId') > 0 ){
					data.copy( $this.announce );
					$this.set('editable', false );
					$this.set('isNew', false );
				}else{
					$this.set('editable', true );	
					$this.set('isNew', true );
					$this.edit();
				}
				$this.set('formatedCreationDate' , community.data.getFormattedDate( $this.announce.creationDate) );
				$this.set('formatedModifiedDate' , community.data.getFormattedDate( $this.announce.modifiedDate) );
								
				if( !$this.get('visible') ) 
					$this.set('visible' , true );
			},
			load : function(announceId){
				var $this = this;		
				if( announceId > 0){
					community.ui.ajax('<@spring.url "/data/api/v1/announces/"/>' + announceId + '/get.json', {
						success: function(data){	
							var data = new community.model.Announce(data);
							$this.setSource( data );
						}	
					});
				}else{
					$this.setSource( new community.model.Announce() );
				}	
			} 
		});
		
		community.ui.bind( $('#js-header') , observable );        
		
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	  
	     
		
		var renderTo = $('#features');		
		community.ui.bind( renderTo , observable );
	});
	
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
						<a class="u-link-v5 g-color-gray-dark-v6 g-color-lightblue-v3--hover g-valign-middle" href="#!">커뮤니티</a> <i class="community-admin-angle-right g-font-size-12 g-color-gray-light-v6 g-valign-middle g-ml-10"></i>
					</li>
					<li class="list-inline-item">
						<span class="g-valign-middle">공지</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">공지 관리</h1>
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
					<div class="row" id="announce-edit-form">
						<div class="col-lg-9 g-mt-20 g-mb-10">
							<div class="form-group g-mb-30">
	                    			<label class="g-mb-10 g-font-weight-600" for="input-page-name">제목 <span class="text-danger">*</span></label>
		                    		<div class="g-pos-rel">
			                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
				                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
				                		</span>
		                      		<input id="input-page-name" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="제목을 입력하세요" 
		                      			data-bind="value: announce.subject, enabled:editable" required validationMessage="제목을 입력하여주세요.">
		                    		</div>
	                  		</div>
	      

	                  		
							<div class="row g-mb-15">
								<div class="col-md-6">
									<label class="g-mb-10 g-font-weight-600">객체유형  <span class="text-danger">*</span></label>
									<div class="form-group g-rounded-4 mb-0">
										<input data-role="numerictextbox" placeholder="객체유형" data-min="-1" data-max="100"  data-format="###" data-bind="value:announce.objectType, enabled:editable" style="width: 100%"/>
									</div>
								</div>
								<div class="col-md-6">
									<label class="g-mb-10 g-font-weight-600">객체 ID <span class="text-danger">*</span></label>
									<div class="form-group g-rounded-4 mb-0">
										<input data-role="numerictextbox" placeholder="객체 ID" data-min="-1" data-format="###" data-bind="value:announce.objectId, enabled:editable" style="width: 100%"/>
									</div>
								</div>
							</div>	                  		
	                  		            		
							<div class="row g-mb-15">
								<div class="col-md-6">
									<label class="g-mb-10 g-font-weight-600">시작일  <span class="text-danger">*</span></label>
			                    		<div class="g-pos-rel">
				                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
					                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
					                		</span>
			                      		<input data-role="datetimepicker" style="width: 100%" data-bind="value:announce.startDate, enabled:editable" placeholder="시작일" required validationMessage="시작일을 입력하여주세요.">
			                      		<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">시작일을 기준으로 공지가 보여집니다.</small>
			                    		</div>
								</div>
								<div class="col-md-6">
									<label class="g-mb-10 g-font-weight-600">종료일 <span class="text-danger">*</span></label>
			                    		<div class="g-pos-rel">
				                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
					                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
					                		</span>
			                      		<input data-role="datetimepicker" style="width: 100%" data-bind="value:announce.endDate, enabled:editable" placeholder="종료일" required validationMessage="종료일을 입력하여주세요.">
			                      		<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">종료일을 까지 공지가 보여집니다.</small>
			                    		</div>
								</div>
							</div> 
								                  		          
 							<!-- EDITOR -->
 							<div class="g-mb-30">     
								<div class="u-heading-v1-4 g-bg-main g-brd-gray-light-v2 g-mb-14">
					          		<h2 class="h4 u-heading-v1__title g-mt-0 g-font-size-14">내용</h2>
								</div>
								<div id="announce-body-editor" class="d-none"></div>
								<section class="g-mb-15 g-brd-2 g-brd-gray-dark-v6 g-rounded-5 g-brd-around--lg g-pa-15" data-bind="html:announce.body, invisible:editable" ></section>
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
		                    		</ul>
		                  	</section>	
		                  	<!-- options setting end -->						
						</div>		
					</div>												
					<div class="row"> 
						
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
							<i class="community-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
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
							<i class="community-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
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
								<a class="community-admin-panel u-link-v5 g-font-size-20 g-color-gray-light-v3 g-color-secondary--hover" href="#!" data-bind="click: showOptions"></a>
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
					<i class="community-admin-pencil g-font-size-18"></i>
                </a>
                <!--
                <a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover" href="\#!" data-action="delete" data-object-type="menu" data-object-id="#= menuId #" >
                		<i class="community-admin-trash g-font-size-18"></i>
                </a>-->
			</div>
		</td>
	</tr>
	</script>			
</body>
</html>
</#compress>