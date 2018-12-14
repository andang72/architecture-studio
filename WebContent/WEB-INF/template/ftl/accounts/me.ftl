<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <title><#if __page?? >${__page.title}</#if></title> 
    
    <#include "/community/includes/header_globle_site_tag.ftl">
    
	<!-- Bootstrap core CSS -->
   	<link href="<@spring.url "/css/bootstrap/4.0.0/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />	
   	
	<!-- Professional Kendo UI --> 	
	<link href="<@spring.url "/css/bootstrap.theme/unify-bootstrap-v4/all.css"/>" rel="stylesheet" type="text/css" />	
		
   	<!-- Fonts & Icons CSS -->
	<link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/fonts/nanumgothic.min.css"/>" rel="stylesheet" type="text/css" />		
	<link href="<@spring.url "/css/community.ui/community.ui.icons.min.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/animate/animate.min.css"/>" rel="stylesheet" type="text/css" />	
		
	<!-- Dzsparallaxer CSS -->
	<link href="<@spring.url "/assets/vendor/dzsparallaxer/dzsparallaxer.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/assets/vendor/dzsparallaxer/dzsscroller/scroller.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/assets/vendor/dzsparallaxer/advancedscroller/plugin.css"/>" rel="stylesheet" type="text/css" />	
			
	<!-- summernote CSS -->		
	<link rel="stylesheet" href="<@spring.url "/js/summernote/summernote-bs4.css"/>">
					
	<!-- CSS Bootstrap Theme Unify -->		    
    <link href="<@spring.url "/assets/vendor/icon-hs/style.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/assets/vendor/hs-megamenu/src/hs.megamenu.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/assets/vendor/hamburgers/hamburgers.min.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/assets/vendor/icon-line/css/simple-line-icons.css"/>" rel="stylesheet" type="text/css" />			 
	<link href="<@spring.url "/assets/vendor/icon-line-pro/style.css"/>" rel="stylesheet" type="text/css" />
	
	<link rel="stylesheet" href="<@spring.url "/css/bootstrap.theme/unify/unify-core.css"/>">
	<link rel="stylesheet" href="<@spring.url "/css/bootstrap.theme/unify/unify-components.css"/>">
	<link rel="stylesheet" href="<@spring.url "/css/bootstrap.theme/unify/unify-globals.css"/>"> 
	
	<link rel="stylesheet" href="<@spring.url "/css/bootstrap.theme/unify/custom.css"/>">
		
	<!-- Page landing js -->	   	
	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js"/>'></script>    	
	<!-- Requirejs for js loading -->
	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>
	<!-- Application JavaScript
    		================================================== -->    
	<script> 
    var __observable; 
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
	        <!-- Unify -- > 			
			"hs.core" : { "deps" :['jquery', 'bootstrap'] },
			"hs.header" : { "deps" :['jquery', 'hs.core'] },
			"hs.tabs" : { "deps" :['jquery', 'hs.core'] },
			"hs.hamburgers" : { "deps" :['jquery', 'hs.core'] },
			"hs.dropdown" : { "deps" :['jquery', 'hs.core'] },
	        "dzsparallaxer" : { "deps" :['jquery'] },
	        "dzsparallaxer.dzsscroller" : { "deps" :['jquery', 'dzsparallaxer' ] },
			"dzsparallaxer.advancedscroller" : { "deps" :['jquery', 'dzsparallaxer' ] }	
	    },
		paths : {
			"jquery"    				: "/js/jquery/jquery-3.1.1.min",
			"jquery.cookie"    			: "/js/jquery.cookie/1.4.1/jquery.cookie",
			"bootstrap" 				: "/js/bootstrap/4.0.0/bootstrap.bundle.min",
			<!-- Professional Kendo UI --> 
			"kendo.web.min"	 			: "/js/kendo/2018.1.221/kendo.web.min",
			"kendo.culture.min"			: "/js/kendo/2018.1.221/cultures/kendo.culture.ko-KR.min",	
			"kendo.messages.min"		: "/js/kendo.extension/kendo.messages.ko-KR",	
			<!-- summernote -->
			"summernote.min"             : "/js/summernote/summernote-bs4.min",
			"summernote-ko-KR"           : "/js/summernote/lang/summernote-ko-KR"	,
			"dropzone"					: "/js/dropzone/dropzone",			
			<!-- community -- >
			"community.ui.core" 		: "/js/community.ui/community.ui.core",
			"community.data" 			: "/js/community.ui/community.data",   
			"ace" 						: "/js/ace/ace",
			<!-- Unify -->
	    	"hs.core" 	   					: "/js/bootstrap.theme/unify/hs.core",
			"hs.header" 	   				: "/js/bootstrap.theme/unify/components/hs.header",
			"hs.tabs" 	   					: "/js/bootstrap.theme/unify/components/hs.tabs",
			"hs.hamburgers"   				: "/js/bootstrap.theme/unify/helpers/hs.hamburgers",
			"hs.dropdown" 	   				: "/assets/js/components/hs.dropdown",
			<!-- Dzsparallaxer -->		
			"dzsparallaxer"           			: "/assets/vendor/dzsparallaxer/dzsparallaxer",
			"dzsparallaxer.dzsscroller"			: "/assets/vendor/dzsparallaxer/dzsscroller/scroller",
			"dzsparallaxer.advancedscroller"	: "/assets/vendor/dzsparallaxer/advancedscroller/plugin"
		}
	});
	
	require([ 
		"jquery", "bootstrap", 
		"community.data", "kendo.messages.min", "ace",
		"hs.header", "hs.tabs", "hs.hamburgers", 'dzsparallaxer.advancedscroller', 'hs.dropdown', 'dropzone'
	], function($, kendo ) {	

		// init header 
		$.HSCore.components.HSHeader.init($('#js-header'));	
		$.HSCore.components.HSTabs.init('[role="tablist"]');
		$.HSCore.helpers.HSHamburgers.init('.hamburger');

		// initialization of HSDropdown component
      	$.HSCore.components.HSDropdown.init($('[data-dropdown-target]')); 
      					
		$(window).on('resize', function () {
		    setTimeout(function () {
		    	$.HSCore.components.HSTabs.init('[role="tablist"]');
		    }, 200);
		});
 	
		community.ui.setup({
		  	features : {
				accounts: true
		  	},
		  	'features.accounts.authenticate' :function(e){
		  		if( !e.token.anonymous ){
		  			__observable.setUser(e.token);
		    	}
		  	}
		});	        
 			
        var featuresTo = $('#features');    
		__observable = new community.ui.observable({  
			userAvatarSrc : '<@spring.url '/download/avatar/${currentUser.username}?height=120&amp;width=120'/>',
			currentUser : new community.model.User(),		 
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
			},
			refresh : function (){
				var $this = this;	
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
			},
			back : function(){
				var $this = this;
				window.history.back();
				return false;			
			},	
			showChangePasswordWindow : function () {
				createOrOpenPasswordUpdater();
			}
    	}); 
		community.ui.bind(featuresTo, __observable ); 
		createImageDropzone(__observable); 	 
	});  		
	
	function createOrOpenPasswordUpdater (data){ 
		var renderTo = $('#password-change-modal');
		if( !renderTo.data("model") ){
			var observable = new community.ui.observable({  
				user :{
					name : null,
					verifyPassword : null,
					newPassword : null,
					rePassword : null
				},
				cancle : function(){
					var $this = this;
					$this.set('user.name', __observable.currentUser.name );
					$this.set('user.verifyPassword', null );
					$this.set('user.newPassword', null );
					$this.set('user.rePassword', null );
					$('form[name=pw-form]')[0].reset();
					validator.hideMessages();
				},
				saveOrUpdate : function(){
					var $this = this;
					if (validator.validate()) { 
						community.ui.progress(renderTo, true);				
						community.ui.ajax("<@spring.url "/data/v1/me/profile/save-or-update.json"/>", {
							contentType : "application/json",
							data: community.ui.stringify( $this.user ),
							success : function( response ) { 
								if( response.success ){
									alert('비밀번호가 변경되었습니다. 다시 로그인하여 주십시오.');
									//community.ui.ajax("<@spring.url "/accounts/logout"/>", {});
									//community.ui.send("<@spring.url "/accounts/login"/>", {});
								}else{
									if( !response.data.verify ){
										alert('비밀번호가 일치하지 않습니다.');
										$this.set('user.verifyPassword', null );
									}
								}	
							},	
							complete: function(jqXHR, textStatus ){
								community.ui.progress(renderTo, false);		
							}
						});	
					}
				},				
				setSource : function( data ){
			 		var $this = this;
			 	}
			});
			community.ui.bind( renderTo, observable );	
				
			var validator = $('form[name=pw-form]').kendoValidator({
				rules : { 
					customRule1 : function(input){
						if( input.is( '[name=rePassword]' )) {
							return $.trim( input.val() ) === observable.user.newPassword ;
						}
						return true;
					}
				},
				messages : {
						customRule1: "입력하신 비밀번호가 일치하지 않습니다."
				},	
				errorTemplate: "<p class='text-danger g-font-size-15 g-mt-10 g-font-weight-300'><i class='fa fa-info-circle'></i> #=message#</p>" 
			}).data("kendoValidator");	 	
							
			renderTo.on('show.bs.modal', function (e) {	
				observable.cancle();
			});
		}	
		if( community.ui.defined(data) ) 
			renderTo.data("model").setSource(data);
		renderTo.modal('show');	
	}
	
	function createImageDropzone (observable){
		var myDropzone = new Dropzone('#dropzoneForm', {
			url: '<@spring.url "/data/v1/me/upload_avatar_image.json"/>',
			paramName: 'file',
			maxFilesize: 1,
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
													
	</script>	
	<style>
 
	</style>	
</head>
<body class="landing-page no-skin-config">
   	<#include "/community/includes/header.ftl"> 
    <!-- Promo Block -->
    <section id="features" class="dzsparallaxer auto-init height-is-based-on-content use-loading mode-scroll loaded dzsprx-readyall g-bg-cover g-color-white" data-options='{direction: "reverse", settings_mode_oneelement_max_offset: "150"}'>
		
		<#if (__page.getBooleanProperty( "header.image.random", false) ) >
		<div class="divimage dzsparallaxer--target w-100 g-bg-pos-top-center" style="height: 120%; background-image: url( '<@spring.url "/download/images/" />${ CommunityContextHelper.getCustomQueryService().queryForString("COMMUNITY_CS.SELECT_IMAGE_ID_RANDOMLY" ) }' );"></div>
		<#else>
		<div class="divimage dzsparallaxer--target w-100 g-bg-pos-top-center" 
			style="height: 120%; background-image: url(  /images/bg/endless_streets_by_andreasrocha-d3fhbhg.jpg );"></div>
		</#if>
     	<div class="container g-bg-cover__inner g-py-50 g-mt-50 g-mb-0">
			<header class="g-mb-20">
				<#if ( __page.getLongProperty( "pages.parent.pageId",0 ) > 0 ) > 
				<h3 class="h5 g-font-weight-300 g-mb-5">${ CommunityContextHelper.getPageService().getPage(  __page.getLongProperty( "pages.parent.pageId",0 )  ).getTitle() }</h3>
				</#if>
				<h2 class="h1 g-font-weight-400 text-uppercase" >
				<#if __project?? >${__project.name}</#if>
		        <span class="g-color-primary"></span>
				</h2>
				<div data-bind="visible: visible" style="display:none;" class="animated fadeIn"> 
				<#if SecurityHelper.isUserInRole("ROLE_DEVELOPER") >	 
				<div class="btn-group" role="group">
					<a class="btn btn-md u-btn-3d u-btn-darkpurple g-px-25 g-py-13" href="#!" style="display:none;" role="button" 
					data-toggle="tooltip" data-placement="top" data-original-title="프로젝트 관련 정보를 확인할 수 있습니다." data-bind="click:displayProjectInfo,visible:isDeveloper">정보보기</a>
				</div>
				</#if>	 
				</div>
			</header> 

			<div class="g-mb-0">
              <div class="row">
                <div class="col-lg-5 g-mb-40 g-mb-0--lg">
                  	<!-- User Image -->
                  	<div class="d-flex justify-content-start">
                      <!-- Figure Image --> 
					<div class="d-inline-block g-pos-rel g-mb-20 g-mr-20">
					<a class="u-badge-v2--lg u-badge--bottom-right g-width-32 g-height-32 g-bg-lightblue-v3 g-bg-primary--hover g-mb-20 g-mr-20" href="#!">
					<i class="icon-media-123 u-line-icon-pro g-absolute-centered g-font-size-16 g-color-white"></i>
					</a>
					<img class="rounded-circle" data-bind="attr:{ src: userAvatarSrc }" src="/images/no-avatar.png" alt="Image description" width="120" height="120">
					<form action="" method="post" enctype="multipart/form-data" id="dropzoneForm" class="u-dropzone dz-clickable">
						<div class="dz-default dz-message">
							<a class="u-badge-v2--lg u-badge--bottom-right g-width-40 g-height-40 g-brd-around g-bg-primary--hover g-pa-5 g-mb-20 g-mr-20 btn-link" href="#!">
								<i class="icon-media-123 u-line-icon-pro g-absolute-centered g-font-size-24 g-color-white"></i>
							</a>
						</div>
						<div class="dropzone-previews"></div>
					</form>
					</div>

                      <!-- Figure Image -->

                      <div class="g-ml-20 g-mt-20 d-block">
                        <!-- Figure Info -->
                        <div class="g-mb-5">
                          <h4 class="h5 g-mb-1"><#if !currentUser.anonymous >${ currentUser.name }</#if></h4>
                          <em class="d-block g-color-gray-dark-v4 g-font-style-normal g-font-size-13"><#if !currentUser.anonymous >${ currentUser.username }</#if></em>
                        </div>
                        <!-- End Figure Info -->

                        <!-- Social Icons -->
                        <!--
                        <ul class="list-inline mb-0">
                          <li class="list-inline-item g-mx-2">
                            <a class="u-icon-v1 u-icon-slide-up--hover g-color-gray-dark-v4 g-color-facebook--hover g-ml-minus-15" href="#!">
                              <i class="g-font-size-default g-line-height-1 u-icon__elem-regular fa fa-facebook"></i>
                              <i class="g-font-size-default g-line-height-0_8 u-icon__elem-hover fa fa-facebook"></i>
                            </a>
                          </li>
                          <li class="list-inline-item g-mx-2">
                            <a class="u-icon-v1 u-icon-slide-up--hover g-color-gray-dark-v4 g-color-twitter--hover" href="#!">
                              <i class="g-font-size-default g-line-height-1 u-icon__elem-regular fa fa-twitter"></i>
                              <i class="g-font-size-default g-line-height-0_8 u-icon__elem-hover fa fa-twitter"></i>
                            </a>
                          </li>
                          <li class="list-inline-item g-mx-2">
                            <a class="u-icon-v1 u-icon-slide-up--hover g-color-gray-dark-v4 g-color-instagram--hover" href="#!">
                              <i class="g-font-size-default g-line-height-1 u-icon__elem-regular fa fa-instagram"></i>
                              <i class="g-font-size-default g-line-height-0_8 u-icon__elem-hover fa fa-instagram"></i>
                            </a>
                          </li>
                        </ul>
                        -->
                        <!-- End Social Icons -->
                      </div>
                    </div> 
					
                  <!-- User Contact Buttons -->
                  <a class="btn g-width-200 u-btn-lightred g-rounded-5 g-py-12 g-mb-10 g-font-size-18 g-font-weight-400" href="#!" data-bind="click:showChangePasswordWindow"> 
                    <i class="icon-finance-135 u-line-icon-pro g-pos-rel g-top-1 g-mr-5"></i> 비밀번호 변경 
                  </a>
                  <!-- End User Contact Buttons -->
                </div>

                <div class="col-lg-5">
 
                  <!-- User Position -->
                  <h4 class="h6 g-font-weight-300 g-mb-10">
                      <i class="icon-badge g-pos-rel g-top-1 g-mr-5 g-color-gray-dark-v5"></i> 
                      <#if !currentUser.anonymous ><#list SecurityHelper.getAuthentication().authorities as grantedAuthority >
                      ${grantedAuthority.authority} <#if grantedAuthority?has_next >,</#if>
                      </#list></#if>
                    </h4>
                  <!-- End User Position --> 
				</div>											
		</div>
    </section>
    <!-- End Promo Block -->   
    
      
	<div class="container-fluid g-pt-70 g-pb-30">
        <div class="row g-pa-20">
            <!-- Links -->
            <!--
            <ul class="list-inline g-brd-bottom--sm g-brd-gray-light-v3 mb-5">
              <li class="list-inline-item g-pb-10 g-pr-10 g-mb-20 g-mb-0--sm">
                <a class="g-brd-bottom g-brd-2 g-brd-primary g-color-main g-color-black g-font-weight-600 g-text-underline--none--hover g-px-10 g-pb-13" href="page-orders-1.html">Orders</a>
              </li>
              <li class="list-inline-item g-pb-10 g-px-10 g-mb-20 g-mb-0--sm">
                <a class="g-brd-bottom g-brd-2 g-brd-transparent g-color-main g-color-gray-dark-v4 g-color-primary--hover g-text-underline--none--hover g-px-10 g-pb-13" href="page-open-orders-1.html">Open Orders</a>
              </li>
              <li class="list-inline-item g-pb-10 g-pl-10 g-mb-20 g-mb-0--sm">
                <a class="g-brd-bottom g-brd-2 g-brd-transparent g-color-main g-color-gray-dark-v4 g-color-primary--hover g-text-underline--none--hover g-px-10 g-pb-13" href="page-cancelled-orders-1.html">Cancelled Orders</a>
              </li>
            </ul>
            -->
            <!-- End Links -->
            
                                
       </div>
   </div>  
	<!-- password changer modal -->
	<div class="modal right fade" id="password-change-modal" tabindex="-1" role="dialog" aria-labelledby="password-change-modal">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content g-brd-0 rounded-0">
				<div class="modal-header">
					<!--<h2 class="modal-title">기술지원요청</h2>-->
			        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
			          	<i aria-hidden="true" class="icon-svg icon-svg-sm icon-svg-ios-close m-t-xs"></i>
			        </button>
		      	</div><!-- /.modal-content -->
		      	<form name="pw-form">
				<div class="modal-body">
				  <!-- Current Password  --> 
                  <div class="form-group g-mb-25 g-mx-25">
                    <label class="d-block g-color-gray-dark-v2">비밀번호 확인</label>
                    <div class="input-group g-brd-primary--focus">
						<input class="form-control form-control-md border-right-0 rounded-0 g-py-13 pr-0" type="password" name="verifyPassword2" placeholder="현재 비밀번호" 
						data-bind="value:user.verifyPassword"
						required  data-required-msg="현재 비밀번호를 입력하여 주십시오.">
						<div class="input-group-append">
							<span class="input-group-text g-bg-white g-color-gray-light-v1 rounded-0"><i class="icon-lock"></i></span>
						</div>
					</div>
                     <span class="k-invalid-msg g-mt-10" data-for="verifyPassword2"></span> 	 
                  </div>
                  <!-- End Current Password -->

                  <!-- New Password -->
                  <div class="form-group g-mb-25 g-mx-25">
                    <label class="d-block g-color-gray-dark-v2">새로운 비밀번호</label>
                    <div class="input-group g-brd-primary--focus">
						<input class="form-control form-control-md border-right-0 rounded-0 g-py-13 pr-0" type="password" name="newPassword" placeholder="비밀번호" 
							data-bind="value:user.newPassword" required  data-required-msg="비밀번호를 입력하여 주십시오." pattern="^(?=.*).{4,}$" 
                    		validationmessage="비밀번호가 비밀번호 정책 요구 사항을 충족하지 못합니다.">
						<div class="input-group-append">
							<span class="input-group-text g-bg-white g-color-gray-light-v1 rounded-0"><i class="icon-lock"></i></span>
						</div>
					</div>
					<small class="form-text text-muted g-font-size-default g-font-weight-300 g-mt-10">
						<strong>비밀번호 정책:</strong> 비밀번호는 최소 4자 이상이어야 합니다.</small>
                     <span class="k-invalid-msg g-mt-10" data-for="newPassword"></span> 	 
                  </div>
                  <!-- End New Password -->

                  <!-- Verify Password -->
                  <div class="form-group g-mb-25 g-mx-25">
                    <label class="d-block g-color-gray-dark-v2">새로운 비밀번호</label>
                    <div class="input-group g-brd-primary--focus">
						<input class="form-control form-control-md border-right-0 rounded-0 g-py-13 pr-0" type="password" name="rePassword" placeholder="비밀번호 확인" 
						data-bind="value:user.rePassword"
						required  data-required-msg="비밀번호를 입력하여 주십시오.">
						<div class="input-group-append">
							<span class="input-group-text g-bg-white g-color-gray-light-v1 rounded-0"><i class="icon-lock"></i></span>
						</div>
					</div>

                     <span class="k-invalid-msg g-mt-10" data-for="rePassword"></span> 	 
                  </div>
                  <!-- End Verify Password -->
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-md u-btn-3d u-btn-blue g-px-25 g-py-13" data-bind="click:saveOrUpdate">저장</button>
					<button type="button" class="btn btn-md u-btn-3d u-btn-darkgray g-px-25 g-py-13" data-dismiss="modal">취소</button>
				</div>
				</form>		
			</div>
		</div>
	</div>
	    	
</body>     		 
</html>
</#compress>
